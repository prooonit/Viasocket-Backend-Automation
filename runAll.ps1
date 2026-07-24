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
  @{ Name = "DBDASH-AUTH-APIS"; Path = "modules\Dbdash-auth-apis\run.ps1" },
  @{ Name = "LOGS";          Path = "modules\logs\run.ps1" },
  @{ Name = "VIASOCKET-AUTH-APIS"; Path = "modules\viasocket-auth-apis\run.ps1" }
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

$NODE_DIR    = Join-Path $ROOT "node"
$PUBLISH_DIR = Join-Path $ROOT "publish"
$PROD_URL    = "https://viasocket-apis-automation-reports.netlify.app"

if (-not (Test-Path (Join-Path $NODE_DIR "node_modules"))) {
  Write-Host "Installing node dependencies..."
  npm install --prefix $NODE_DIR
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host "ERROR: node is not on PATH. Aborting." -ForegroundColor Red
  exit 1
}

# ------------------------------------------------------------
# Step 1: Generate consolidated report (writes summary-report.html + index.html)
# ------------------------------------------------------------
Write-Host ""
Write-Host "---- Generating consolidated HTML summary ----"
$env:REPORTS_ROOT = Join-Path $ROOT "modules"
$env:OUT          = Join-Path $PUBLISH_DIR "summary-report.html"
node (Join-Path $NODE_DIR "generateSummary.js")
if ($LASTEXITCODE -ne 0) {
  Write-Host "ERROR: Report generation failed. Skipping deploy and webhook." -ForegroundColor Red
  exit 1
}
if (-not (Test-Path (Join-Path $PUBLISH_DIR "index.html"))) {
  Write-Host "ERROR: publish/index.html not produced. Skipping deploy and webhook." -ForegroundColor Red
  exit 1
}

# ------------------------------------------------------------
# Step 2: Deploy to Netlify (production)
# ------------------------------------------------------------
function Deploy-LatestReport {
  Write-Host ""
  Write-Host "---- Deploying latest report to Netlify ($PROD_URL) ----"
  if (-not (Get-Command netlify -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: netlify CLI not found. Install with: npm i -g netlify-cli" -ForegroundColor Red
    return $false
  }
  netlify deploy --prod --dir $PUBLISH_DIR
  if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Netlify deployment failed (exit $LASTEXITCODE)." -ForegroundColor Red
    return $false
  }
  Write-Host "Deployment succeeded -> $PROD_URL" -ForegroundColor Green
  return $true
}

$deployOk = Deploy-LatestReport
if (-not $deployOk) {
  Write-Host "Skipping webhook because deployment did not succeed." -ForegroundColor Red
  exit 1
}

# ------------------------------------------------------------
# Step 3: Send webhook with the permanent production URL
# ------------------------------------------------------------
Write-Host ""
Write-Host "---- Sending reports to webhook ----"
$env:REPORTS_ROOT = Join-Path $ROOT "modules"
$env:REPORT_URL   = $PROD_URL
node (Join-Path $NODE_DIR "sendReports.js")

Write-Host ""
Write-Host "============================================"
Write-Host " ALL MODULES COMPLETE"
Write-Host " Per-module HTML -> modules/<module>/reports/"
Write-Host " Consolidated     -> publish/summary-report.html"
Write-Host " Live URL         -> $PROD_URL"
Write-Host "============================================"
