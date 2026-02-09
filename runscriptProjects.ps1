# ===============================
# CONFIG
# ===============================

$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/projects"

# ===============================
# CREATE REPORT DIRECTORY
# ===============================

if (!(Test-Path $REPORT_DIR)) {
    New-Item -ItemType Directory -Path $REPORT_DIR | Out-Null
}

# ===============================
# 1️⃣ CREATE PROJECT
# ===============================

Write-Host "Running CREATE PROJECT"

newman run $COLLECTION -e $ENV `
 --folder "Create Project" `
 -d data/projects/create-project.json `
 -r html `
 --reporter-html-export "$REPORT_DIR/01-create-project.html"

# ===============================
# 2️⃣ GET ALL PROJECTS
# ===============================

Write-Host "Running GET ALL PROJECTS"

newman run $COLLECTION -e $ENV `
 --folder "Get All projects" `
 -r html `
 --reporter-html-export "$REPORT_DIR/02-get-all-projects.html"

# ===============================
# 3️⃣ UPDATE PROJECT
# ===============================

Write-Host "Running UPDATE PROJECT"

newman run $COLLECTION -e $ENV `
 --folder "Update Project" `
 -d data/projects/update-project.json `
 -r html `
 --reporter-html-export "$REPORT_DIR/03-update-project.html"

# ===============================
# 4️⃣ CHANGE PROJECT STATUS
# ===============================

Write-Host "Running CHANGE PROJECT STATUS"

newman run $COLLECTION -e $ENV `
 --folder "Change Project Status" `
 -d data/projects/change-project-status.json `
 -r html `
 --reporter-html-export "$REPORT_DIR/04-change-project-status.html"

# ===============================
# DONE
# ===============================

Write-Host "ALL PROJECT APIs EXECUTED & REPORTS GENERATED SUCCESSFULLY"
