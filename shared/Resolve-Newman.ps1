# Shared helpers for module runners. Dot-source from modules/*/run.ps1
# Usage: . "$PSScriptRoot\..\..\shared\Resolve-Newman.ps1"

function Get-AutomationRoot {
  # shared/Resolve-Newman.ps1 lives in <repo>/shared → repo root is parent
  return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Resolve-NodeExe {
  if (Get-Command node -ErrorAction SilentlyContinue) {
    return (Get-Command node).Source
  }
  $candidates = @(
    "$env:LOCALAPPDATA\Programs\cursor\resources\app\resources\helpers\node.exe",
    "C:\Users\sankh\AppData\Local\Programs\cursor\resources\app\resources\helpers\node.exe"
  )
  $found = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $found) { throw "Node.js not found. Install Node.js or open from Cursor." }
  return $found
}

function Resolve-NewmanJs {
  param([string]$Root)
  $newman = Join-Path $Root "node_modules\newman\bin\newman.js"
  if (-not (Test-Path $newman)) { throw "newman not found. Run: npm install (from repo root)" }
  return $newman
}

function Resolve-EnvFile {
  param([string]$Root)
  $candidates = @(
    (Join-Path $Root "shared\environment\env.json"),
    (Join-Path $Root "environment\env.json")
  )
  $found = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $found) { throw "env.json not found under shared/environment or environment/" }
  return $found
}
