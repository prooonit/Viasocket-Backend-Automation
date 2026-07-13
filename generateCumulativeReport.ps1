# ============================================================
# Cumulative Report Generator
# Aggregates all newman JSON reports across modules/*/reportsJson
# Usage: .\generateCumulativeReport.ps1
# ============================================================

$ROOT       = $PSScriptRoot
$MODULES    = Join-Path $ROOT "modules"
$OUT_DIR    = Join-Path $ROOT "cumulative-report"
New-Item -ItemType Directory -Force -Path $OUT_DIR | Out-Null

$OUT_JSON = Join-Path $OUT_DIR "summary.json"
$OUT_HTML = Join-Path $OUT_DIR "summary.html"

$rows            = @()
$totalRequests   = 0
$totalAssertions = 0
$totalFailed     = 0
$totalFailures   = 0

$jsonFiles = Get-ChildItem -Path $MODULES -Recurse -Filter *.json |
             Where-Object { $_.FullName -match [regex]::Escape("\reportsJson\") }

foreach ($file in $jsonFiles) {
  try {
    $report = Get-Content $file.FullName -Raw | ConvertFrom-Json
    $stats  = $report.run.stats
    $module = ($file.FullName -replace [regex]::Escape($MODULES + "\"), "") -split "\\" | Select-Object -First 1

    $reqTotal    = [int]$stats.requests.total
    $assrTotal   = [int]$stats.assertions.total
    $assrFailed  = [int]$stats.assertions.failed
    $failCount   = [int]$report.run.failures.Count

    $totalRequests   += $reqTotal
    $totalAssertions += $assrTotal
    $totalFailed     += $assrFailed
    $totalFailures   += $failCount

    $rows += [pscustomobject]@{
      module           = $module
      reportName       = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
      collection       = $report.collection.info.name
      requests         = $reqTotal
      assertions       = $assrTotal
      failedAssertions = $assrFailed
      failures         = $failCount
      avgResponseMs    = [int]$report.run.timings.responseAverage
      success          = ($failCount -eq 0)
    }
  } catch {
    Write-Host "Skipped $($file.Name): $($_.Exception.Message)" -ForegroundColor Yellow
  }
}

$summary = [pscustomobject]@{
  generatedAt      = (Get-Date).ToString("s")
  totalReports     = $rows.Count
  totalRequests    = $totalRequests
  totalAssertions  = $totalAssertions
  failedAssertions = $totalFailed
  totalFailures    = $totalFailures
  overallSuccess   = ($totalFailures -eq 0)
  reports          = $rows
}

$summary | ConvertTo-Json -Depth 5 | Out-File $OUT_JSON -Encoding utf8

# ---- HTML summary ----
$statusColor = if ($totalFailures -eq 0) { "#16a34a" } else { "#dc2626" }
$statusText  = if ($totalFailures -eq 0) { "ALL PASSED" } else { "FAILURES DETECTED" }

$rowsHtml = ($rows | ForEach-Object {
  $color = if ($_.success) { "#dcfce7" } else { "#fee2e2" }
  "<tr style='background:$color'><td>$($_.module)</td><td>$($_.reportName)</td><td>$($_.collection)</td><td>$($_.requests)</td><td>$($_.assertions)</td><td>$($_.failedAssertions)</td><td>$($_.failures)</td><td>$($_.avgResponseMs)</td></tr>"
}) -join "`n"

$html = @"
<!doctype html>
<html><head><meta charset='utf-8'><title>Cumulative Test Report</title>
<style>
body{font-family:system-ui,Arial;margin:24px;color:#111}
h1{margin:0 0 6px 0}
.stat{display:inline-block;margin:6px 18px 6px 0;padding:10px 14px;background:#f3f4f6;border-radius:6px}
.stat b{display:block;font-size:22px}
table{border-collapse:collapse;width:100%;margin-top:16px}
th,td{border:1px solid #e5e7eb;padding:8px 10px;text-align:left;font-size:14px}
th{background:#f9fafb}
.badge{display:inline-block;padding:4px 12px;border-radius:4px;color:#fff;background:$statusColor;font-weight:600}
</style></head>
<body>
<h1>Cumulative API Test Report</h1>
<div>Generated: $((Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) &nbsp; <span class='badge'>$statusText</span></div>

<div class='stat'><b>$($rows.Count)</b>Reports</div>
<div class='stat'><b>$totalRequests</b>Requests</div>
<div class='stat'><b>$totalAssertions</b>Assertions</div>
<div class='stat'><b>$totalFailed</b>Failed Assertions</div>
<div class='stat'><b>$totalFailures</b>Failures</div>

<table>
<tr><th>Module</th><th>Report</th><th>Collection</th><th>Requests</th><th>Assertions</th><th>Failed Assert.</th><th>Failures</th><th>Avg Resp (ms)</th></tr>
$rowsHtml
</table>
</body></html>
"@

$html | Out-File $OUT_HTML -Encoding utf8

Write-Host ""
Write-Host "============================================"
Write-Host " CUMULATIVE REPORT"
Write-Host "============================================"
Write-Host " Reports scanned:    $($rows.Count)"
Write-Host " Total requests:     $totalRequests"
Write-Host " Total assertions:   $totalAssertions"
Write-Host " Failed assertions:  $totalFailed"
Write-Host " Failures:           $totalFailures"
Write-Host " Overall status:     $statusText"
Write-Host "--------------------------------------------"
Write-Host " JSON -> $OUT_JSON"
Write-Host " HTML -> $OUT_HTML"
Write-Host "============================================"
