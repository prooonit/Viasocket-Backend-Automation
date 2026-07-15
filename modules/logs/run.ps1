# ============================================================
# Module: logs
# Usage:  .\modules\logs\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\logs.postman_collection.json"
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

Write-Host "Running LOGS API tests..."
Invoke-Newman "Get All Logs By Script Id"  (Join-Path $DATA_DIR "get-all-logs.data.json")          "01-get-all-logs"
Invoke-Newman "Process Bulk Logs"          (Join-Path $DATA_DIR "process-bulk-logs.data.json")     "02-process-bulk-logs"
Invoke-Newman "Get Log By Flow Hit Id"     (Join-Path $DATA_DIR "get-log-by-flowhitid.data.json")  "03-get-log-by-flowhitid"
Invoke-Newman "Get Recent Log"             (Join-Path $DATA_DIR "get-recent-log.data.json")        "04-get-recent-log"

Write-Host ""
Write-Host "LOGS complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
