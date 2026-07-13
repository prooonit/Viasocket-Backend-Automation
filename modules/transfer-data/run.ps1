# ============================================================
# Module: transfer-data
# Usage:  .\modules\transfer-data\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\transfer-data.postman_collection.json"
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

Write-Host "Running TRANSFER-DATA API tests..."
Invoke-Newman "Get All Transfer Data"  (Join-Path $DATA_DIR "get-all-transfer-data.data.json")  "01-get-all-transfer-data"
Invoke-Newman "Start Transfer Data"    (Join-Path $DATA_DIR "start-transfer.data.json")        "02-start-transfer"
Invoke-Newman "Get Transfer Status"    (Join-Path $DATA_DIR "get-transfer-status.data.json")   "03-get-transfer-status"
Invoke-Newman "Stop Transfer"          (Join-Path $DATA_DIR "stop-transfer.data.json")         "04-stop-transfer"

Write-Host ""
Write-Host "TRANSFER-DATA complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
