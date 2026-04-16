# ============================================================
# ViaSocket Backend Automation - Master Run Script
# ============================================================
# This is the ONE file you need to run all API tests.
# Usage:  .\run.ps1
#         .\run.ps1 -Suite org
#         .\run.ps1 -Suite projects
#         .\run.ps1 -Suite all
# ============================================================

param(
    [ValidateSet("org", "projects", "all")]
    [string]$Suite = "all"
)

$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"

# ── Check prerequisites ──────────────────────────────────────
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js / npx is not installed. Download from https://nodejs.org" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
}

if (-not (Test-Path $COLLECTION)) {
    Write-Host "ERROR: Collection file not found at $COLLECTION" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ENV)) {
    Write-Host "ERROR: Environment file not found at $ENV" -ForegroundColor Red
    exit 1
}

# ── Create output directories ────────────────────────────────
New-Item -ItemType Directory -Force -Path "reports/projects"    | Out-Null
New-Item -ItemType Directory -Force -Path "reportsJson"         | Out-Null
New-Item -ItemType Directory -Force -Path "reportsJson/projects"| Out-Null

# ── Helper function ──────────────────────────────────────────
function Run-Test {
    param(
        [string]$Label,
        [string]$Folder,
        [string]$HtmlOut,
        [string]$JsonOut,
        [string]$DataFile = ""
    )

    Write-Host ""
    Write-Host "Running: $Label" -ForegroundColor Cyan

    $dataArg = if ($DataFile) { "-d $DataFile" } else { "" }

    $htmlCmd = "npx newman run $COLLECTION -e $ENV --folder `"$Folder`" $dataArg -r html --reporter-html-export `"$HtmlOut`""
    $jsonCmd = "npx newman run $COLLECTION -e $ENV --folder `"$Folder`" $dataArg -r json --reporter-json-export `"$JsonOut`""

    Invoke-Expression $htmlCmd
    Invoke-Expression $jsonCmd

    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $Label" -ForegroundColor Red
    } else {
        Write-Host "PASSED: $Label" -ForegroundColor Green
    }
}

# ── Org Tests ────────────────────────────────────────────────
function Run-OrgTests {
    Write-Host ""
    Write-Host "==============================" -ForegroundColor Yellow
    Write-Host " ORG API TESTS" -ForegroundColor Yellow
    Write-Host "==============================" -ForegroundColor Yellow

    Run-Test "Create Org"                "createorg"                    "reports/01-create-org.html"         "reportsJson/01-create-org.json"         "data/org/create-org.json"
    Run-Test "Get All Organizations"     "get all organization"         "reports/02-get-all-org.html"        "reportsJson/02-get-all-org.json"
    Run-Test "Get Users of an Org"       "get users of an organization" "reports/03-get-users-org.html"      "reportsJson/03-get-users-org.json"
    Run-Test "Update an Organization"    "update an organization"       "reports/04-update-org.html"         "reportsJson/04-update-org.json"         "data/org/update-org.json"
    Run-Test "Switch Org"                "switch org"                   "reports/05-switch-org.html"         "reportsJson/05-switch-org.json"         "data/org/switch-org.json"
    Run-Test "Add User to Org"           "add user to org"              "reports/06-add-user-org.html"       "reportsJson/06-add-user-org.json"       "data/org/add-user-org.json"
    Run-Test "Remove User"               "remove user"                  "reports/07-remove-user-org.html"    "reportsJson/07-remove-user-org.json"    "data/org/remove-user-org.json"
    Run-Test "Beta Status"               "Beta Status"                  "reports/08-beta-status.html"        "reportsJson/08-beta-status.json"        "data/org/beta-status.json"
}

# ── Project Tests ────────────────────────────────────────────
function Run-ProjectTests {
    Write-Host ""
    Write-Host "==============================" -ForegroundColor Yellow
    Write-Host " PROJECT API TESTS" -ForegroundColor Yellow
    Write-Host "==============================" -ForegroundColor Yellow

    Run-Test "Create Project"         "Create Project"         "reports/projects/01-create-project.html"         "reportsJson/projects/01-create-project.json"         "data/projects/create-project.json"
    Run-Test "Get All Projects"       "Get All projects"       "reports/projects/02-get-all-projects.html"       "reportsJson/projects/02-get-all-projects.json"
    Run-Test "Update Project"         "Update Project"         "reports/projects/03-update-project.html"         "reportsJson/projects/03-update-project.json"         "data/projects/update-project.json"
    Run-Test "Change Project Status"  "Change Project Status"  "reports/projects/04-change-project-status.html"  "reportsJson/projects/04-change-project-status.json"  "data/projects/change-project-status.json"
}

# ── Execute based on -Suite param ────────────────────────────
switch ($Suite) {
    "org"      { Run-OrgTests }
    "projects" { Run-ProjectTests }
    "all"      { Run-OrgTests; Run-ProjectTests }
}

Write-Host ""
Write-Host "==============================" -ForegroundColor Green
Write-Host " ALL DONE" -ForegroundColor Green
Write-Host " HTML reports  → reports/" -ForegroundColor Green
Write-Host " JSON reports  → reportsJson/" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
