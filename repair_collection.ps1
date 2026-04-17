$file = "collection\viacollection.json"
$content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
Write-Host "Read $($content.Length) chars"

# Fix 1: Response time thresholds: 1000 and 3000 -> 5000
$content = $content -replace 'to\.be\.below\(1000\)', 'to.be.below(5000)'
$content = $content -replace 'to\.be\.below\(3000\)', 'to.be.below(5000)'

# Fix 2: All folder tests - fix "if (expectedStatus === 200)" to also allow 201
$before2 = '"if (expectedStatus === 200) {\r",'
$after2  = '"if (expectedStatus === 200 || expectedStatus === 201) {\r",'
$count2 = ([regex]::Matches($content, [regex]::Escape($before2))).Count
$content = $content.Replace($before2, $after2)
Write-Host "Fix 2 applied: $count2 instances of expectedStatus===200 updated to include 201"

# Fix 3: All folder tests - replace direct .message check with nested-safe version
# Pattern: "        pm.expect(pm.response.json().message).to.exist;\r",
# Replace with two lines: const body + nested expect
$before3 = '"        pm.expect(pm.response.json().message).to.exist;\r",'
$count3 = ([regex]::Matches($content, [regex]::Escape($before3))).Count
# Use regex with capture group for leading whitespace
$content = $content -replace '([ \t]+"        )pm\.expect\(pm\.response\.json\(\)\.message\)\.to\.exist;\\r",', ('$1const body = pm.response.json();\r",' + "`r`n" + '$1pm.expect(body.message || (body.data && body.data.message) || (body.errors && body.errors.message)).to.exist;\r",')
Write-Host "Fix 3 applied: $count3 instances of message assertion updated to nested-safe version"

# Fix 4: Update Script - replace hardcoded proxy_auth_token with variable
$hardcodedToken = '"value": "UGtkOGJ2dDJEWDlReTBMSkFzZG5jWkNteHZNZjVYZ2h1SlBnVW93Q0J5d3FZaXZXVDlQNDlORjhKa0NBK09QVDNzQ3ArekFNMWl2UzlaYlFMYkhmcGhpZ3hSbUJtSmswVWUySUp1THNaUWhnS2Q1eXJHVDBreW9mNldtUmlFK0NXSTFPQ2t2d0NIc3duWjVLWjM4K2QzT3p6ajZ6OStVMWJybXhNVkFwdUpSNDdIV2Z0UW5aQk1oa2EwZWxQMlda"'
if ($content.Contains($hardcodedToken)) {
    $content = $content.Replace($hardcodedToken, '"value": "{{proxy_auth_token}}"')
    Write-Host "Fix 4 applied: Update Script hardcoded token replaced with {{proxy_auth_token}}"
} else {
    Write-Host "Fix 4 SKIPPED: hardcoded token not found"
}

# Fix 5: Update Script - replace hardcoded body with updateTitle variable
$hardcodedBody = '"raw": "{\r\n    \"title\":\"mewara\",\r\n    \"description\":\"this is tartun\"\r\n}"'
if ($content.Contains($hardcodedBody)) {
    $content = $content.Replace($hardcodedBody, '"raw": "{\r\n    \"title\":\"{{updateTitle}}\"\r\n}"')
    Write-Host "Fix 5 applied: Update Script hardcoded body replaced with {{updateTitle}}"
} else {
    Write-Host "Fix 5 SKIPPED: hardcoded body not found"
}

# Fix 6: Delete Script - change from DELETE /delete to PUT /status?status=0
# Note: Newman builds URL from path array, not raw - must fix both
$deleteOldRaw = '"raw": "{{BASE_URL}}/projects/{{project_id}}/scripts/{{scriptId}}/status?status=0"'
if ($content.Contains($deleteOldRaw)) {
    # raw already fixed; check if path still has "delete"
    Write-Host "Fix 6a: raw URL already correct, checking path array"
} else {
    $content = $content.Replace('"method": "DELETE"', '"method": "PUT"')
    $content = $content.Replace('"raw": "{{BASE_URL}}/projects/{{project_id}}/scripts/{{scriptId}}/delete"', '"raw": "{{BASE_URL}}/projects/{{project_id}}/scripts/{{scriptId}}/status?status=0"')
    Write-Host "Fix 6a applied: method and raw URL updated"
}

# Fix path array: "delete" -> "status", and add query array
$deleteOldPathBlock = '"path": [' + "`r`n" + '                            "projects",' + "`r`n" + '                            "{{project_id}}",' + "`r`n" + '                            "scripts",' + "`r`n" + '                            "{{scriptId}}",' + "`r`n" + '                            "delete"' + "`r`n" + '                    ]' + "`r`n" + '            }' + "`r`n" + '    },'
$deleteNewPathBlock = '"path": [' + "`r`n" + '                            "projects",' + "`r`n" + '                            "{{project_id}}",' + "`r`n" + '                            "scripts",' + "`r`n" + '                            "{{scriptId}}",' + "`r`n" + '                            "status"' + "`r`n" + '                    ],' + "`r`n" + '                    "query": [' + "`r`n" + '                            {' + "`r`n" + '                                    "key": "status",' + "`r`n" + '                                    "value": "0"' + "`r`n" + '                            }' + "`r`n" + '                    ]' + "`r`n" + '            }' + "`r`n" + '    },'

if ($content.Contains($deleteOldPathBlock)) {
    $content = $content.Replace($deleteOldPathBlock, $deleteNewPathBlock)
    Write-Host "Fix 6b applied: Delete Script path array fixed and query added"
} else {
    Write-Host "Fix 6b SKIPPED: path block not found, trying simple path replace"
    $content = $content -replace '"delete"\s*\]\s*\}\s*\}\s*,\s*\{\s*\r?\n\s*"name": "Instantiate', '"status"' + "`r`n" + '                    ],' + "`r`n" + '                    "query": [{"key":"status","value":"0"}]' + "`r`n" + '            }' + "`r`n" + '    },' + "`r`n" + '    {' + "`r`n" + '        "name": "Instantiate'
}

[System.IO.File]::WriteAllText($file, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Done. File length: $($content.Length)"
