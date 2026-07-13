# ============================================================
# ViaSocket Backend Automation - Master entry
# ============================================================
# Usage:
#   .\run.ps1
#   .\run.ps1 -Suite org
#   .\run.ps1 -Suite flow-extended
#   .\run.ps1 -Suite all
# ============================================================

param(
    [ValidateSet(
        "org", "projects", "users", "scripts", "functions",
        "flow", "flow-extended", "template", "transfer-data", "invite", "all"
    )]
    [string]$Suite = "all"
)

$ROOT = $PSScriptRoot

$map = @{
    "org"           = "modules\org\run.ps1"
    "projects"      = "modules\projects\run.ps1"
    "users"         = "modules\users\run.ps1"
    "scripts"       = "modules\scripts\run.ps1"
    "functions"     = "modules\functions\run.ps1"
    "flow"          = "modules\flow\run.ps1"
    "flow-extended" = "modules\flow-extended\run.ps1"
    "template"      = "modules\template\run.ps1"
    "transfer-data" = "modules\transfer-data\run.ps1"
    "invite"        = "modules\invite\run.ps1"
}

if ($Suite -eq "all") {
    & (Join-Path $ROOT "runAll.ps1")
    return
}

$script = Join-Path $ROOT $map[$Suite]
if (-not (Test-Path $script)) {
    Write-Host "ERROR: Module runner not found: $script" -ForegroundColor Red
    exit 1
}

Write-Host "Running module: $Suite"
& $script
