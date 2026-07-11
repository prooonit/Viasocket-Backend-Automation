# ============================================================
# Module: template
# Usage:  .\modules\template\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\template.postman_collection.json"
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

Write-Host "Running TEMPLATE API tests..."
Invoke-Newman "Get all Templates"         (Join-Path $DATA_DIR "get-all-templates.data.json")         "01-get-all-templates"
Invoke-Newman "Get Template By Id"        (Join-Path $DATA_DIR "get-template-by-id.data.json")        "02-get-template-by-id"
Invoke-Newman "Update template category"  (Join-Path $DATA_DIR "update-template-category.data.json")  "03-update-template-category"

Write-Host ""
Write-Host "TEMPLATE complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
