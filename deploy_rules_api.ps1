$projectId = "car-dealer-00"
$databaseId = "cardb"
$rulesFile = "firestore.rules"

Write-Host "=== Firebase Rules Deployment Script ===" -ForegroundColor Green
Write-Host ""

Write-Host "Step 1: Get access token" -ForegroundColor Yellow
Write-Host "Run this command to get your access token:"
Write-Host "firebase login:ci" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 2: After you get the token, run this curl command:" -ForegroundColor Yellow
Write-Host ""

$rulesContent = Get-Content $rulesFile -Raw
$escapedRules = $rulesContent -replace '\$', '`$' -replace '"', '\"'

Write-Host "curl -X POST `"https://firebaserules.googleapis.com/v1/projects/$projectId/rulesets`" \"
Write-Host "  -H `"Authorization: Bearer YOUR_TOKEN_HERE`" \"
Write-Host "  -H `"Content-Type: application/json`" \"
Write-Host "  -d '{"
Write-Host "    `"source`": {"
Write-Host "      `"files`": [{"
Write-Host "        `"content`": `"$escapedRules`""
Write-Host "      }]"
Write-Host "    }"
Write-Host "  }'"
Write-Host ""
Write-Host "Step 3: Then deploy the ruleset to the database:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Replace RULESET_NAME with the name from step 2 response, then:"
Write-Host ""
Write-Host "curl -X POST `"https://firebaserules.googleapis.com/v1/projects/$projectId/releases?databaseId=$databaseId`" \"
Write-Host "  -H `"Authorization: Bearer YOUR_TOKEN_HERE`" \"
Write-Host "  -H `"Content-Type: application/json`" \"
Write-Host "  -d '{"
Write-Host "    `"rulesetName`": `"projects/$projectId/rulesets/RULESET_NAME`""
Write-Host "  }'"


