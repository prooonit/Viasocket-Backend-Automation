$dir = Join-Path $PSScriptRoot "reportsJson"
$rows = @()
Get-ChildItem $dir -Filter *.json | Sort-Object Name | ForEach-Object {
  $r = Get-Content $_.FullName -Raw | ConvertFrom-Json
  $api = $_.BaseName
  foreach ($e in $r.run.executions) {
    $status = $e.response.code
    $reason = $e.response.status
    $failedAssertions = @($e.assertions | Where-Object { $_.error })
    $result = if ($failedAssertions.Count -eq 0) { "PASS" } else { "FAIL" }
    $errs = ($failedAssertions | ForEach-Object { $_.error.message }) -join "; "
    $rows += [pscustomobject]@{
      API    = $api
      HTTP   = "$status $reason"
      Result = $result
      Errors = $errs
    }
  }
}
$rows | Format-Table -AutoSize -Wrap
Write-Host ""
Write-Host ("Total: {0} | PASS: {1} | FAIL: {2}" -f $rows.Count, ($rows | Where-Object Result -eq PASS).Count, ($rows | Where-Object Result -eq FAIL).Count)
