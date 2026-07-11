# ============================================================
# Module: scripts
# Usage:  .\modules\scripts\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\scripts.postman_collection.json"
$ENV        = Resolve-EnvFile -Root $ROOT
$REPORT_DIR = Join-Path $MODULE_ROOT "reports"
$JSON_DIR   = Join-Path $MODULE_ROOT "reportsJson"
$DATA_DIR   = Join-Path $MODULE_ROOT "data"

New-Item -ItemType Directory -Force -Path $REPORT_DIR, $JSON_DIR | Out-Null
$NODE = Resolve-NodeExe
$NEWMAN_JS = Resolve-NewmanJs -Root $ROOT

function Invoke-Newman {
  param([string]$Folder, [string]$Data = "", [string]$OutName)
  Write-Host ""
  Write-Host "---- $OutName : $Folder ----"
  $args = @($NEWMAN_JS, "run", $COLLECTION, "-e", $ENV, "--folder", $Folder, "-r", "cli,html,json",
    "--reporter-html-export", "$REPORT_DIR\$OutName.html",
    "--reporter-json-export", "$JSON_DIR\$OutName.json")
  if ($Data) { $args += @("-d", $Data) }
  & $NODE @args
}

Write-Host "Running SCRIPTS API tests..."
Invoke-Newman "Create Script"         (Join-Path $DATA_DIR "create-script.data.json")         "01-create-script"
Invoke-Newman "Get All Scripts"       (Join-Path $DATA_DIR "get-all-scripts.data.json")       "02-get-all-scripts"
Invoke-Newman "Get One Script"        (Join-Path $DATA_DIR "get-one-script.data.json")        "03-get-one-script"
Invoke-Newman "Update Script"         (Join-Path $DATA_DIR "update-script.data.json")         "04-update-script"
Invoke-Newman "Change Script Status"  (Join-Path $DATA_DIR "change-script-status.data.json")  "05-change-script-status"
Invoke-Newman "Publish Script"        (Join-Path $DATA_DIR "publish-script.data.json")        "06-publish-script"
Invoke-Newman "Duplicate Script"      (Join-Path $DATA_DIR "duplicate-script.data.json")      "07-duplicate-script"
Invoke-Newman "Revert Script"         (Join-Path $DATA_DIR "revert-script.data.json")         "08-revert-script"
Invoke-Newman "Delete Script"         (Join-Path $DATA_DIR "delete-script.data.json")         "09-delete-script"

Write-Host ""
Write-Host "SCRIPTS complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
