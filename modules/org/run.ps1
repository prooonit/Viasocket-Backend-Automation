# ============================================================
# Module: org
# Usage:  .\modules\org\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\org.postman_collection.json"
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

Write-Host "Running ORG API tests..."
Write-Host "Collection: $COLLECTION"
Write-Host "Env: $ENV"

Invoke-Newman "createorg"                    (Join-Path $DATA_DIR "create-org.json")          "01-create-org"
Invoke-Newman "get all organization"         ""                                                "02-get-all-org"
Invoke-Newman "get users of an organization" ""                                                "03-get-users-org"
Invoke-Newman "update an organization"       (Join-Path $DATA_DIR "update-org.json")          "04-update-org"
Invoke-Newman "get org token"                (Join-Path $DATA_DIR "get-org-token.json")       "05-get-org-token"
Invoke-Newman "global search on org"         (Join-Path $DATA_DIR "global-search-org.json")   "06-global-search-org"
Invoke-Newman "add user to org"              (Join-Path $DATA_DIR "add-user-org.json")        "07-add-user-org"
Invoke-Newman "remove user"                  (Join-Path $DATA_DIR "remove-user-org.json")     "08-remove-user-org"
Invoke-Newman "switch org"                   (Join-Path $DATA_DIR "switch-org.json")          "09-switch-org"
Write-Host "     [restore] Switching back to default org"
Invoke-Newman "switch org"                   (Join-Path $DATA_DIR "switch-back-org.json")     "09b-switch-back-org"
Invoke-Newman "leave org"                    (Join-Path $DATA_DIR "leave-org.json")           "10-leave-org"
Invoke-Newman "Beta Status"                  (Join-Path $DATA_DIR "beta-status.json")         "11-beta-status"

Write-Host ""
Write-Host "ORG complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
