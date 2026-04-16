$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/org"
$JSON_DIR   = "reportsJson/org"

# Create report directories if they do not exist
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $JSON_DIR   | Out-Null

Write-Host "Running ORG API tests..."

Write-Host "[1/8] Create Org"
npx newman run $COLLECTION -e $ENV --folder "createorg" `
  -d data/org/create-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/01-create-org.html" `
  --reporter-json-export "$JSON_DIR/01-create-org.json"

Write-Host "[2/8] Get All Organizations"
npx newman run $COLLECTION -e $ENV --folder "get all organization" `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/02-get-all-org.html" `
  --reporter-json-export "$JSON_DIR/02-get-all-org.json"

Write-Host "[3/8] Get Users of an Organization"
npx newman run $COLLECTION -e $ENV --folder "get users of an organization" `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/03-get-users-org.html" `
  --reporter-json-export "$JSON_DIR/03-get-users-org.json"

Write-Host "[4/8] Update an Organization"
npx newman run $COLLECTION -e $ENV --folder "update an organization" `
  -d data/org/update-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/04-update-org.html" `
  --reporter-json-export "$JSON_DIR/04-update-org.json"

Write-Host "[5/8] Switch Org"
npx newman run $COLLECTION -e $ENV --folder "switch org" `
  -d data/org/switch-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/05-switch-org.html" `
  --reporter-json-export "$JSON_DIR/05-switch-org.json"

Write-Host "[6/8] Add User to Org"
npx newman run $COLLECTION -e $ENV --folder "add user to org" `
  -d data/org/add-user-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/06-add-user-org.html" `
  --reporter-json-export "$JSON_DIR/06-add-user-org.json"

Write-Host "[7/8] Remove User"
npx newman run $COLLECTION -e $ENV --folder "remove user" `
  -d data/org/remove-user-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/07-remove-user-org.html" `
  --reporter-json-export "$JSON_DIR/07-remove-user-org.json"

Write-Host "[8/8] Beta Status"
npx newman run $COLLECTION -e $ENV --folder "Beta Status" `
  -d data/org/beta-status.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/08-beta-status.html" `
  --reporter-json-export "$JSON_DIR/08-beta-status.json"

Write-Host "ORG API tests complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
