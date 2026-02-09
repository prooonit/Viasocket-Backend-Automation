$COLLECTION="collection/viacollection.json"
$ENV="environment/env.json"

newman run $COLLECTION -e $ENV --folder "createorg" `
-d data/org/create-org.json `
-r json `
--reporter-html-export reports/01-create-org.html

newman run $COLLECTION -e $ENV --folder "get all organization" `
-r html `
--reporter-html-export reports/02-get-all-org.html

newman run $COLLECTION -e $ENV --folder "get users of an organization" `
-r html `
--reporter-html-export reports/03-get-users-org.html

newman run $COLLECTION -e $ENV --folder "update an organization" `
-d data/org/update-org.json `
-r html `
--reporter-html-export reports/04-update-org.html

newman run $COLLECTION -e $ENV --folder "switch org" `
-d data/org/switch-org.json `
-r html `
--reporter-html-export reports/05-switch-org.html

newman run $COLLECTION -e $ENV --folder "add user to org" `
-d data/org/add-user-org.json `
-r html `
--reporter-html-export reports/06-add-user-org.html

newman run $COLLECTION -e $ENV --folder "remove user" `
-d data/org/remove-user-org.json `
-r html `
--reporter-html-export reports/07-remove-user-org.html

newman run $COLLECTION -e $ENV --folder "Beta Status" `
-d data/org/beta-status.json `
-r html `
--reporter-html-export reports/08-beta-status.html

Write-Host "✅ ALL ORG APIs EXECUTED & HTML REPORTS GENERATED"
