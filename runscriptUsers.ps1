$COLLECTION = "collection/viacollection.json"
$ENV        = "environment/env.json"
$REPORT_DIR = "reports/users"
$JSON_DIR   = "reportsJson/users"

# Create report directories if they do not exist
New-Item -ItemType Directory -Force -Path $REPORT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $JSON_DIR   | Out-Null

Write-Host "Running USERS API tests..."

Write-Host "[1/2] Get User Profile"
npx newman run $COLLECTION -e $ENV --folder "Get User Profile" `
  -d data/users/get-user-profile.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/01-get-user-profile.html" `
  --reporter-json-export "$JSON_DIR/01-get-user-profile.json"

Write-Host "[2/2] Update User"
npx newman run $COLLECTION -e $ENV --folder "Update User" `
  -d data/users/update-user.json `
  -r html,json `
  --reporter-html-export "$REPORT_DIR/02-update-user.html" `
  --reporter-json-export "$JSON_DIR/02-update-user.json"

Write-Host "USERS API tests complete. HTML -> $REPORT_DIR | JSON -> $JSON_DIR"
