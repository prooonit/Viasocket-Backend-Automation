# ============================================================
# Module: functions
# Usage:  .\modules\functions\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\functions.postman_collection.json"
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

Write-Host "Running FUNCTIONS API tests..."
Invoke-Newman "Get All Functions"       (Join-Path $DATA_DIR "get-all-functions.data.json")       "01-get-all-functions"
Invoke-Newman "Get One Function"        (Join-Path $DATA_DIR "get-one-function.data.json")        "02-get-one-function"
Invoke-Newman "Get Function by Title"   (Join-Path $DATA_DIR "get-function-by-title.data.json")   "03-get-function-by-title"

Write-Host ""
Write-Host "FUNCTIONS complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
