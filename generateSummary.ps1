# Generate a single consolidated HTML report from every module's reportsJson/*.json
# Usage: .\generateSummary.ps1
$ROOT = $PSScriptRoot
$NODE_DIR = Join-Path $ROOT "node"
if (-not (Test-Path (Join-Path $NODE_DIR "node_modules"))) {
  Write-Host "Installing node dependencies..."
  npm install --prefix $NODE_DIR
}
$env:REPORTS_ROOT = Join-Path $ROOT "modules"
$env:OUT          = Join-Path $ROOT "summary-report.html"
node (Join-Path $NODE_DIR "generateSummary.js")
Write-Host "Open: $env:OUT"
