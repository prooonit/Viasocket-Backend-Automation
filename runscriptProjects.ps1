$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/projects"
$JSON_DIR   = "reportsJson/projects"

# Create report directories if they do not exist
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $JSON_DIR   | Out-Null

Write-Host "Running PROJECT API tests..."

Write-Host "[1/4] Create Project"
npx newman run $COLLECTION -e $ENV --folder "Create Project" `
  -d data/projects/create-project.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/01-create-project.html" `
  --reporter-json-export "$JSON_DIR/01-create-project.json"

Write-Host "[2/4] Get All Projects"
npx newman run $COLLECTION -e $ENV --folder "Get All projects" `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/02-get-all-projects.html" `
  --reporter-json-export "$JSON_DIR/02-get-all-projects.json"

Write-Host "[3/4] Update Project"
npx newman run $COLLECTION -e $ENV --folder "Update Project" `
  -d data/projects/update-project.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/03-update-project.html" `
  --reporter-json-export "$JSON_DIR/03-update-project.json"

Write-Host "[4/4] Change Project Status"
npx newman run $COLLECTION -e $ENV --folder "Change Project Status" `
  -d data/projects/change-project-status.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/04-change-project-status.html" `
  --reporter-json-export "$JSON_DIR/04-change-project-status.json"

Write-Host "PROJECT API tests complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
