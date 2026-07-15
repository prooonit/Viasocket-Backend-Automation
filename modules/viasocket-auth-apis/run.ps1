# ============================================================
# Module: viasocket-auth-apis
# Usage:  .\modules\viasocket-auth-apis\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\viasocket-auth-apis.postman_collection.json"
$ENV_FILE   = Resolve-EnvFile -Root $ROOT
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
  $args = @($NEWMAN_JS, "run", $COLLECTION, "-e", $ENV_FILE, "--folder", $Folder, "-r", "cli,html,json",
    "--reporter-html-export", "$REPORT_DIR\$OutName.html",
    "--reporter-json-export", "$JSON_DIR\$OutName.json")
  if ($Data) { $args += @("-d", $Data) }
  & $NODE @args
}

Write-Host "Running VIASOCKET-AUTH-APIS tests..."
Invoke-Newman "Get All Auths By Org"       (Join-Path $DATA_DIR "01-get-all-auths.data.json")       "01-get-all-auths"
Invoke-Newman "Delete Auth"                (Join-Path $DATA_DIR "02-delete-auth.data.json")         "02-delete-auth"
Invoke-Newman "Update Auth Description"    (Join-Path $DATA_DIR "03-update-auth.data.json")         "03-update-auth"
Invoke-Newman "Get Flows Of Auth"          (Join-Path $DATA_DIR "04-get-flows-of-auth.data.json")   "04-get-flows-of-auth"
Invoke-Newman "Get Auth Info"              (Join-Path $DATA_DIR "05-get-auth-info.data.json")       "05-get-auth-info"
Invoke-Newman "Is Auth Valid"              (Join-Path $DATA_DIR "06-is-auth-valid.data.json")       "06-is-auth-valid"

Write-Host ""
Write-Host "VIASOCKET-AUTH-APIS complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
