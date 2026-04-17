param([string]$suite = "flow", [string]$report = "")

$dir = "reportsJson/$suite"
$files = Get-ChildItem "$dir/*.json" -ErrorAction SilentlyContinue
if ($report) { $files = $files | Where-Object { $_.Name -match $report } }

foreach ($f in $files) {
    $j = Get-Content $f.FullName -Raw | ConvertFrom-Json
    $failures = $j.run.failures
    if ($failures.Count -eq 0) { continue }
    Write-Host "=== $($f.Name) ==="
    foreach ($exe in $j.run.executions) {
        $resp = $exe.response
        if (-not $resp) { continue }
        $code = $resp.code
        $body = [System.Text.Encoding]::UTF8.GetString($resp.stream.data)
        # Only show non-2xx responses
        if ($code -lt 200 -or $code -ge 300) {
            $name = $exe.item.name
            Write-Host "  [$code] $name : $($body.Substring(0, [Math]::Min(300, $body.Length)))"
        }
    }
}
