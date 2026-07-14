# ============================================================
# Standalone runner: dbdash-auth-apis
# Runs the module and sends its JSON reports to the webhook.
# Usage:  .\runscriptDbdashAuth.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$ROOT = $PSScriptRoot

Write-Host ""
Write-Host "============================================"
Write-Host " DBDASH-AUTH-APIS - Standalone Run"
Write-Host "============================================"

$module = Join-Path $ROOT "modules\Dbdash-auth-apis\run.ps1"
if (-not (Test-Path $module)) {
  Write-Host "ERROR: Module runner not found: $module" -ForegroundColor Red
  exit 1
}
& $module

Write-Host ""
Write-Host "---- Sending reports to webhook ----"
$NODE_DIR = Join-Path $ROOT "node"
if (-not (Test-Path (Join-Path $NODE_DIR "node_modules"))) {
  Write-Host "Installing node dependencies..."
  npm install --prefix $NODE_DIR
}
# Only send this module's reports
$env:REPORTS_ROOT = Join-Path $ROOT "modules\Dbdash-auth-apis"
if (Get-Command node -ErrorAction SilentlyContinue) {
  node (Join-Path $NODE_DIR "sendReports.js")
} else {
  Write-Host "Skip webhook: node not on PATH"
}

Write-Host ""
Write-Host "DBDASH-AUTH-APIS standalone complete."
