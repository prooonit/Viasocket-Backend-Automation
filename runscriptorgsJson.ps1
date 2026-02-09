$COLLECTION="collection/viacollection.json"
$ENV="environment/env.json"

newman run $COLLECTION -e $ENV --folder "createorg" `
-d data/org/create-org.json `
-r json `
--reporter-json-export reportsJson/01-create-org.json

newman run $COLLECTION -e $ENV --folder "get all organization" `
-r json `
--reporter-json-export reportsJson/02-get-all-org.json

newman run $COLLECTION -e $ENV --folder "get users of an organization" `
-r json `
--reporter-json-export reportsJson/03-get-users-org.json

newman run $COLLECTION -e $ENV --folder "update an organization" `
-d data/org/update-org.json `
-r json `
--reporter-json-export reportsJson/04-update-org.json

newman run $COLLECTION -e $ENV --folder "switch org" `
-d data/org/switch-org.json `
-r json `
--reporter-json-export reportsJson/05-switch-org.json

newman run $COLLECTION -e $ENV --folder "add user to org" `
-d data/org/add-user-org.json `
-r json `
--reporter-json-export reportsJson/06-add-user-org.json

newman run $COLLECTION -e $ENV --folder "remove user" `
-d data/org/remove-user-org.json `
-r json `
--reporter-json-export reportsJson/07-remove-user-org.json

newman run $COLLECTION -e $ENV --folder "Beta Status" `
-d data/org/beta-status.json `
-r json `
--reporter-json-export reportsJson/08-beta-status.json

Write-Host "✅ ALL ORG APIs EXECUTED & json reportsJson GENERATED"
