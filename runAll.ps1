# ============================================================
# ViaSocket Backend Automation - Run All Modules
# ============================================================
# Usage:
#   .\runAll.ps1
# ============================================================

$ROOT = $PSScriptRoot

Write-Host ""
Write-Host "============================================"
Write-Host " ViaSocket Backend Automation - Full Run"
Write-Host "============================================"
Write-Host " Modules live under: modules/<name>/"
Write-Host " Shared env:         shared/environment/env.json"
Write-Host "============================================"

$modules = @(
  @{ Name = "ORG";           Path = "modules\org\run.ps1" },
  @{ Name = "PROJECTS";      Path = "modules\projects\run.ps1" },
  @{ Name = "SCRIPTS";       Path = "modules\scripts\run.ps1" },
  @{ Name = "USERS";         Path = "modules\users\run.ps1" },
  @{ Name = "FUNCTIONS";     Path = "modules\functions\run.ps1" },
  @{ Name = "FLOW "; Path = "modules\flow\run.ps1" },
  @{ Name = "TEMPLATE";      Path = "modules\template\run.ps1" },
  @{ Name = "TRANSFER-DATA"; Path = "modules\transfer-data\run.ps1" },
  @{ Name = "INVITE";        Path = "modules\invite\run.ps1" },
  @{ Name = "DBDASH-AUTH-APIS"; Path = "modules\Dbdash-auth-apis\run.ps1" }
)

$i = 0
foreach ($m in $modules) {
  $i++
  Write-Host ""
  Write-Host "---- [Suite $i/$($modules.Count)] $($m.Name) ----"
  $script = Join-Path $ROOT $m.Path
  if (-not (Test-Path $script)) {
    Write-Host "MISSING: $script" -ForegroundColor Red
    continue
  }
  & $script
}

Write-Host ""
Write-Host "---- Sending reports to webhook ----"
$NODE_DIR = Join-Path $ROOT "node"
if (-not (Test-Path (Join-Path $NODE_DIR "node_modules"))) {
  Write-Host "Installing node dependencies..."
  npm install --prefix $NODE_DIR
}
# Point sendReports at modules/*/reportsJson
$env:REPORTS_ROOT = Join-Path $ROOT "modules"
if (Get-Command node -ErrorAction SilentlyContinue) {
  node (Join-Path $NODE_DIR "sendReports.js")
} else {
  Write-Host "Skip webhook: node not on PATH"
}

Write-Host ""
Write-Host "============================================"
Write-Host " ALL MODULES COMPLETE"
Write-Host " Reports -> modules/<module>/reports/"
Write-Host "============================================"
