# ============================================================
# ViaSocket Backend Automation - Run All Suites
# ============================================================
# Runs all API test suites one by one, then automatically
# sends the report summary to the configured webhook URL.
#
# Usage:
#   .\runAll.ps1
# ============================================================

$ROOT = $PSScriptRoot

Write-Host ""
Write-Host "============================================"
Write-Host " ViaSocket Backend Automation - Full Run"
Write-Host "============================================"

# ── 1. Org API Tests ────────────────────────────────────────
Write-Host ""
Write-Host "---- [Suite 1/7] ORG ----"
& "$ROOT\runscriptOrg.ps1"

# ── 2. Projects API Tests ────────────────────────────────────
Write-Host ""
Write-Host "---- [Suite 2/7] PROJECTS ----"
& "$ROOT\runscriptProjects.ps1"

# ── 3. Scripts API Tests ─────────────────────────────────────
Write-Host ""
Write-Host "---- [Suite 3/7] SCRIPTS ----"
& "$ROOT\runscriptScripts.ps1"

# ── 4. Users API Tests ───────────────────────────────────────
Write-Host ""
Write-Host "---- [Suite 4/7] USERS ----"
& "$ROOT\runscriptUsers.ps1"

# ── 5. Functions API Tests ───────────────────────────────────
Write-Host ""
Write-Host "---- [Suite 5/7] FUNCTIONS ----"
& "$ROOT\runscriptFunctions.ps1"

# ── 6. Flow API Tests ────────────────────────────────────────
Write-Host ""
Write-Host "---- [Suite 6/7] FLOW ----"
& "$ROOT\runscriptFlow.ps1"

# ── 7. Template API Tests ────────────────────────────────────
Write-Host ""
Write-Host "---- [Suite 7/7] TEMPLATE ----"
& "$ROOT\runscriptTemplate.ps1"

# ── 8. Send Reports to Webhook ───────────────────────────────
Write-Host ""
Write-Host "---- Sending reports to webhook ----"

$NODE_DIR = "$ROOT\node"

if (-not (Test-Path "$NODE_DIR\node_modules")) {
    Write-Host "Installing node dependencies..."
    npm install --prefix $NODE_DIR
}

node "$NODE_DIR\sendReports.js"

# ── Done ─────────────────────────────────────────────────────
Write-Host ""
Write-Host "============================================"
Write-Host " ALL SUITES COMPLETE"
Write-Host " HTML reports -> reports/"
Write-Host " Reports sent to webhook"
Write-Host "============================================"
