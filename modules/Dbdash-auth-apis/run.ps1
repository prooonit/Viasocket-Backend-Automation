# ============================================================
# Module: dbdash-auth-apis
# Usage:  .\modules\Dbdash-auth-apis\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\dbdash-auth-apis.postman_collection.json"
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

Write-Host "Running DBDASH-AUTH-APIS tests..."
Invoke-Newman "Get Plugin"                              (Join-Path $DATA_DIR "01-get-plugin.data.json")                     "01-get-plugin"
Invoke-Newman "Get Private Plugins"                     (Join-Path $DATA_DIR "02-get-private-plugins.data.json")            "02-get-private-plugins"
Invoke-Newman "Get Plugins With Events"                 (Join-Path $DATA_DIR "03-get-plugins-with-events.data.json")        "03-get-plugins-with-events"
Invoke-Newman "Get Plug Data By Id"                     (Join-Path $DATA_DIR "04-get-plug-data-by-id.data.json")            "04-get-plug-data-by-id"
Invoke-Newman "Get Plugin By Query"                     (Join-Path $DATA_DIR "05-get-plugin-by-query.data.json")            "05-get-plugin-by-query"
Invoke-Newman "Get Generic Functions"                   (Join-Path $DATA_DIR "06-get-generic-functions.data.json")          "06-get-generic-functions"
Invoke-Newman "Get After Signup Data"                   (Join-Path $DATA_DIR "07-get-after-signup-data.data.json")          "07-get-after-signup-data"
Invoke-Newman "Get Recommendations"                     (Join-Path $DATA_DIR "08-get-recommendations.data.json")            "08-get-recommendations"
Invoke-Newman "Get Recommendations For Multiple Plugins" (Join-Path $DATA_DIR "09-get-recommendations-multiple.data.json")  "09-get-recommendations-multiple"
Invoke-Newman "Get Recommendations For Next Action"     (Join-Path $DATA_DIR "10-get-recommendations-next-action.data.json") "10-get-recommendations-next-action"
Invoke-Newman "User Onboarding"                         (Join-Path $DATA_DIR "11-user-onboarding.data.json")                "11-user-onboarding"
Invoke-Newman "Get Video Data"                          (Join-Path $DATA_DIR "12-get-video-data.data.json")                 "12-get-video-data"
Invoke-Newman "Get Most Used Triggers"                  (Join-Path $DATA_DIR "13-get-most-used-triggers.data.json")         "13-get-most-used-triggers"
Invoke-Newman "Get Onboarding Data"                     (Join-Path $DATA_DIR "14-get-onboarding-data.data.json")            "14-get-onboarding-data"
Invoke-Newman "Get Learning Hub Features"               (Join-Path $DATA_DIR "15-get-learning-hub-features.data.json")      "15-get-learning-hub-features"
Invoke-Newman "Update Hire An Expert Request"           (Join-Path $DATA_DIR "16-update-hire-an-expert-request.data.json")  "16-update-hire-an-expert-request"
Invoke-Newman "Get Hire An Expert Request"              (Join-Path $DATA_DIR "17-get-hire-an-expert-request.data.json")     "17-get-hire-an-expert-request"

Write-Host ""
Write-Host "DBDASH-AUTH-APIS complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
