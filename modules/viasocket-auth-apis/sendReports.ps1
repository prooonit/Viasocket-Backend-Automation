# Send only the viasocket-auth-apis module Newman JSON reports to the webhook.
# Usage: .\modules\viasocket-auth-apis\sendReports.ps1
$ErrorActionPreference = "Stop"
$MODULE_ROOT = $PSScriptRoot
$ROOT = Resolve-Path (Join-Path $MODULE_ROOT "..\..")
$NODE_DIR = Join-Path $ROOT "node"

if (-not (Test-Path (Join-Path $NODE_DIR "node_modules"))) {
  Write-Host "Installing node dependencies..."
  npm install --prefix $NODE_DIR
}

$env:REPORTS_ROOT = $MODULE_ROOT
Write-Host "REPORTS_ROOT = $env:REPORTS_ROOT"
node (Join-Path $NODE_DIR "sendReports.js")
