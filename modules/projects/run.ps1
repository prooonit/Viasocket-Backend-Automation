# ============================================================
# Module: projects
# Usage:  .\modules\projects\run.ps1
# ============================================================
$ErrorActionPreference = "Continue"
$MODULE_ROOT = $PSScriptRoot
. (Join-Path $MODULE_ROOT "..\..\shared\Resolve-Newman.ps1")

$ROOT       = Get-AutomationRoot
$COLLECTION = Join-Path $MODULE_ROOT "collection\projects.postman_collection.json"
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

Write-Host "Running PROJECTS API tests..."
Invoke-Newman "Create Project"         (Join-Path $DATA_DIR "create-project.json")          "01-create-project"
Invoke-Newman "Get All projects"       ""                                                   "02-get-all-projects"
Invoke-Newman "Update Project"         (Join-Path $DATA_DIR "update-project.json")          "03-update-project"
Invoke-Newman "Change Project Status"  (Join-Path $DATA_DIR "change-project-status.json")   "04-change-project-status"

Write-Host ""
Write-Host "PROJECTS complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
