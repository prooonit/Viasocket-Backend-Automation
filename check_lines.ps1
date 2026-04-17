$lines = Get-Content "collection\viacollection.json" -Encoding UTF8
Write-Host "Total: $($lines.Count)"
# Find Create Step folder (with "item" array = it's a folder not a request)
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '"name":\s*"create step"') {
        Write-Host "=== Found at L$($i+1) ==="
        for ($j = $i; $j -le [Math]::Min($lines.Count-1,$i+80); $j++) {
            Write-Host "L$($j+1): $($lines[$j])"
        }
        Write-Host "---"
        break
    }
}
