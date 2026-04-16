$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/scripts"
$JSON_DIR   = "reportsJson/scripts"

# Create report directories if they do not exist
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $JSON_DIR   | Out-Null

Write-Host "Running SCRIPTS API tests..."

Write-Host "[1/8] Create Script"
npx newman run $COLLECTION -e $ENV --folder "Create Script" `
  -d data/scripts/create-script.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/01-create-script.html" `
  --reporter-json-export "$JSON_DIR/01-create-script.json"

Write-Host "[2/8] Get All Scripts"
npx newman run $COLLECTION -e $ENV --folder "Get All Scripts" `
  -d data/scripts/get-all-scripts.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/02-get-all-scripts.html" `
  --reporter-json-export "$JSON_DIR/02-get-all-scripts.json"

Write-Host "[3/8] Get One Script"
npx newman run $COLLECTION -e $ENV --folder "Get One Script" `
  -d data/scripts/get-one-script.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/03-get-one-script.html" `
  --reporter-json-export "$JSON_DIR/03-get-one-script.json"

Write-Host "[4/8] Update Script"
npx newman run $COLLECTION -e $ENV --folder "Update Script" `
  -d data/scripts/update-script.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/04-update-script.html" `
  --reporter-json-export "$JSON_DIR/04-update-script.json"

Write-Host "[5/8] Change Script Status"
npx newman run $COLLECTION -e $ENV --folder "Change Script Status" `
  -d data/scripts/change-script-status.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/05-change-script-status.html" `
  --reporter-json-export "$JSON_DIR/05-change-script-status.json"

Write-Host "[6/8] Duplicate Script"
npx newman run $COLLECTION -e $ENV --folder "Duplicate Script" `
  -d data/scripts/duplicate-script.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/06-duplicate-script.html" `
  --reporter-json-export "$JSON_DIR/06-duplicate-script.json"

Write-Host "[7/8] Publish Script"
npx newman run $COLLECTION -e $ENV --folder "publish script" `
  -d data/scripts/publish-script.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/07-publish-script.html" `
  --reporter-json-export "$JSON_DIR/07-publish-script.json"

Write-Host "[8/8] Revert Script"
npx newman run $COLLECTION -e $ENV --folder "revert script" `
  -d data/scripts/revert-script.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/08-revert-script.html" `
  --reporter-json-export "$JSON_DIR/08-revert-script.json"


Write-Host "SCRIPTS API tests complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
