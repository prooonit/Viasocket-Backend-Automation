# ============================================================
# Module: flow-extended
# Usage:  .\modules\flow-extended\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\flow-extended.postman_collection.json"
$ENV        = Resolve-EnvFile -Root $ROOT
$REPORT_DIR = Join-Path $MODULE_ROOT "reports"
$JSON_DIR   = Join-Path $MODULE_ROOT "reportsJson"
$DATA_DIR   = Join-Path $MODULE_ROOT "data"

New-Item -ItemType Directory -Force -Path $REPORT_DIR, $JSON_DIR | Out-Null
Get-ChildItem -Path $JSON_DIR -Filter "*.json" -ErrorAction SilentlyContinue | Remove-Item -Force

$NODE = Resolve-NodeExe
$NEWMAN_JS = Resolve-NewmanJs -Root $ROOT

function Invoke-Newman {
  param([string]$Folder, [string]$Data, [string]$OutName)
  Write-Host ""
  Write-Host "---- $OutName : $Folder ----"
  & $NODE $NEWMAN_JS run $COLLECTION -e $ENV --folder $Folder -d $Data `
    -r cli,html,json `
    --reporter-html-export "$REPORT_DIR\$OutName.html" `
    --reporter-json-export "$JSON_DIR\$OutName.json"
}

Write-Host "Running FLOW EXTENDED API tests (independent prerequest setup)..."
Write-Host "Collection: $COLLECTION"
Write-Host "Node: $NODE"
Write-Host ""

Invoke-Newman "Create Step"                    "$DATA_DIR\create-step.data.json"          "01-create-step"
Invoke-Newman "Update Step"                    "$DATA_DIR\update-step.data.json"          "02-update-step"
Invoke-Newman "Change Step Status"             "$DATA_DIR\change-status.data.json"        "03-change-status"
Invoke-Newman "Reorder Step"                   "$DATA_DIR\reorder-step.data.json"         "04-reorder-step"
Invoke-Newman "If_Block Duplicate Step"        "$DATA_DIR\duplicate-step.data.json"       "05-duplicate-step"
Invoke-Newman "Add / Update Trigger (Webhook)" "$DATA_DIR\trigger.data.json"              "06-trigger"
Invoke-Newman "Add Trigger Preprocess"         "$DATA_DIR\trigger-preprocess.data.json"   "07-trigger-preprocess"
Invoke-Newman "Delete Trigger Preprocess"      "$DATA_DIR\delete-preprocess.data.json"    "08-delete-preprocess"
Invoke-Newman "Add Drafted Trigger"            "$DATA_DIR\draft-trigger.data.json"        "09-draft-trigger"
Invoke-Newman "Get Memory Auth"                "$DATA_DIR\memory-auth.data.json"          "10-memory-auth"
Invoke-Newman "Title & Description (AI)"       "$DATA_DIR\title-description.data.json"    "11-title-description"
Invoke-Newman "Hire an Expert"                 "$DATA_DIR\hire-an-expert.data.json"       "12-hire-an-expert"
Invoke-Newman "Delete Step"                    "$DATA_DIR\delete-step.data.json"          "13-delete-step"
Invoke-Newman "Add Multiple Actions"           "$DATA_DIR\add-multiple-actions.data.json" "14-add-multiple-actions"

$GEN = Join-Path $MODULE_ROOT "generate-detailed-report.js"
if (Test-Path $GEN) {
  Write-Host ""
  Write-Host "Generating DETAILED_REPORT.md ..."
  & $NODE $GEN
}

Write-Host ""
Write-Host "FLOW EXTENDED complete."
Write-Host " HTML   -> $REPORT_DIR"
Write-Host " JSON   -> $JSON_DIR"
Write-Host " Detail -> $REPORT_DIR\DETAILED_REPORT.md"
