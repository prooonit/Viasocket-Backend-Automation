param([string]$suite = "all")

$suites = @("users","scripts","flow","functions","org","template","projects")
if ($suite -ne "all") { $suites = @($suite) }

$totalFail = 0
foreach ($s in $suites) {
    $dir = "reportsJson/$s"
    if (-not (Test-Path $dir)) { Write-Host "[$s] no reports dir"; continue }
    $files = Get-ChildItem "$dir/*.json" -ErrorAction SilentlyContinue
    if (-not $files) { Write-Host "[$s] no reports"; continue }
    foreach ($f in $files) {
        $j = Get-Content $f.FullName -Raw | ConvertFrom-Json
        $stats = $j.run.stats
        $fail = $stats.assertions.failed
        $total = $stats.assertions.total
        $totalFail += $fail
        $status = if ($fail -eq 0) { "OK" } else { "FAIL" }
        Write-Host "[$status] $($f.Name): total=$total fail=$fail"
        if ($fail -gt 0) {
            $failures = $j.run.failures
            foreach ($fl in $failures) {
                Write-Host "  - $($fl.source.name): $($fl.error.message)"
            }
        }
    }
}
Write-Host ""
Write-Host "=== TOTAL FAILURES: $totalFail ==="
