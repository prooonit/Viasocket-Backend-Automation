$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/org"
$JSON_DIR   = "reportsJson/org"

# Create report directories if they do not exist
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $JSON_DIR   | Out-Null

Write-Host "Running ORG API tests..."

Write-Host "[1/11] Create Org"
npx newman run $COLLECTION -e $ENV --folder "createorg" `
  -d data/org/create-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/01-create-org.html" `
  --reporter-json-export "$JSON_DIR/01-create-org.json"

Write-Host "[2/11] Get All Organizations"
npx newman run $COLLECTION -e $ENV --folder "get all organization" `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/02-get-all-org.html" `
  --reporter-json-export "$JSON_DIR/02-get-all-org.json"

Write-Host "[3/11] Get Users of an Organization"
npx newman run $COLLECTION -e $ENV --folder "get users of an organization" `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/03-get-users-org.html" `
  --reporter-json-export "$JSON_DIR/03-get-users-org.json"

Write-Host "[4/11] Update an Organization"
npx newman run $COLLECTION -e $ENV --folder "update an organization" `
  -d data/org/update-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/04-update-org.html" `
  --reporter-json-export "$JSON_DIR/04-update-org.json"

Write-Host "[5/11] Get Org Token"
npx newman run $COLLECTION -e $ENV --folder "get org token" `
  -d data/org/get-org-token.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/05-get-org-token.html" `
  --reporter-json-export "$JSON_DIR/05-get-org-token.json"

Write-Host "[6/11] Global Search on Org"
npx newman run $COLLECTION -e $ENV --folder "global search on org" `
  -d data/org/global-search-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/06-global-search-org.html" `
  --reporter-json-export "$JSON_DIR/06-global-search-org.json"

Write-Host "[7/11] Add User to Org"
npx newman run $COLLECTION -e $ENV --folder "add user to org" `
  -d data/org/add-user-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/07-add-user-org.html" `
  --reporter-json-export "$JSON_DIR/07-add-user-org.json"

Write-Host "[8/11] Remove User"
npx newman run $COLLECTION -e $ENV --folder "remove user" `
  -d data/org/remove-user-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/08-remove-user-org.html" `
  --reporter-json-export "$JSON_DIR/08-remove-user-org.json"

Write-Host "[9/11] Switch Org"
npx newman run $COLLECTION -e $ENV --folder "switch org" `
  -d data/org/switch-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/09-switch-org.html" `
  --reporter-json-export "$JSON_DIR/09-switch-org.json"

# Switch back to default org (19014) so downstream tests run in expected context
Write-Host "     [restore] Switching back to default org (19014)"
npx newman run $COLLECTION -e $ENV --folder "switch org" `
  -d data/org/switch-back-org.json `
  --reporters cli | Out-Null

Write-Host "[10/11] Leave Org"
npx newman run $COLLECTION -e $ENV --folder "leave org" `
  -d data/org/leave-org.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/10-leave-org.html" `
  --reporter-json-export "$JSON_DIR/10-leave-org.json"

Write-Host "[11/11] Beta Status"
npx newman run $COLLECTION -e $ENV --folder "Beta Status" `
  -d data/org/beta-status.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/11-beta-status.html" `
  --reporter-json-export "$JSON_DIR/11-beta-status.json"

Write-Host "ORG API tests complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
