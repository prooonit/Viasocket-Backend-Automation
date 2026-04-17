$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/functions"
$JSON_DIR   = "reportsJson/functions"

# Create report directories if they do not exist
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $JSON_DIR   | Out-Null

Write-Host "Running FUNCTIONS API tests..."

Write-Host "[1/3] Get All Functions"
npx newman run $COLLECTION -e $ENV --folder "Get All Functions" `
  -d data/functions/get-all-functions.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/01-get-all-functions.html" `
  --reporter-json-export "$JSON_DIR/01-get-all-functions.json"

Write-Host "[2/3] Get One Function"
npx newman run $COLLECTION -e $ENV --folder "Get One Function" `
  -d data/functions/get-one-function.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/02-get-one-function.html" `
  --reporter-json-export "$JSON_DIR/02-get-one-function.json"

Write-Host "[3/3] Get Function by Title"
npx newman run $COLLECTION -e $ENV --folder "Get Function by Title" `
  -d data/functions/get-function-by-title.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/03-get-function-by-title.html" `
  --reporter-json-export "$JSON_DIR/03-get-function-by-title.json"

Write-Host "FUNCTIONS API tests complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
