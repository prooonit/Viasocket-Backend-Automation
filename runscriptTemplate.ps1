$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/template"
$JSON_DIR   = "reportsJson/template"

# Create report directories if they do not exist
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $JSON_DIR   | Out-Null

Write-Host "Running TEMPLATE API tests..."

Write-Host "[1/3] Get All Templates"
npx newman run $COLLECTION -e $ENV --folder "Get all Templates" `
  -d data/template/get-all-templates.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/01-get-all-templates.html" `
  --reporter-json-export "$JSON_DIR/01-get-all-templates.json"

Write-Host "[2/3] Get Template by ID"
npx newman run $COLLECTION -e $ENV --folder "Get Template By Id" `
  -d data/template/get-template-by-id.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/02-get-template-by-id.html" `
  --reporter-json-export "$JSON_DIR/02-get-template-by-id.json"

Write-Host "[3/3] Update Template Category"
npx newman run $COLLECTION -e $ENV --folder "Update template category" `
  -d data/template/update-template-category.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/03-update-template-category.html" `
  --reporter-json-export "$JSON_DIR/03-update-template-category.json"

Write-Host "TEMPLATE API tests complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
