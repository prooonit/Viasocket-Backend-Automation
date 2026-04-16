$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/flow"
$JSON_DIR   = "reportsJson/flow"

# Create report directories if they do not exist
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $JSON_DIR   | Out-Null

Write-Host "Running FLOW API tests..."

# Note: "reorder" is skipped — it has a broken URL in the collection ({{script instead of {{scriptId}})

Write-Host "[1/3] Create Step"
npx newman run $COLLECTION -e $ENV --folder "create step" `
  -d data/flow/create-step.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/01-create-step.html" `
  --reporter-json-export "$JSON_DIR/01-create-step.json"

Write-Host "[2/3] Update a Step"
npx newman run $COLLECTION -e $ENV --folder "update a step" `
  -d data/flow/update-step.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/02-update-step.html" `
  --reporter-json-export "$JSON_DIR/02-update-step.json"

Write-Host "[3/3] Delete a Step"
npx newman run $COLLECTION -e $ENV --folder "Delete a step" `
  -d data/flow/delete-step.data.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/03-delete-step.html" `
  --reporter-json-export "$JSON_DIR/03-delete-step.json"

Write-Host "FLOW API tests complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
