$projectId = "car-dealer-00"
$databaseId = "cardb"
$rulesFile = "firestore.rules"

Write-Host "Reading rules from $rulesFile..."
$rulesContent = Get-Content $rulesFile -Raw

$token = firebase login:ci --no-localhost 2>&1 | Select-String -Pattern "Access token" -Context 0,1
if (-not $token) {
    Write-Host "Error: Could not get access token. Please run: firebase login:ci" -ForegroundColor Red
    Write-Host "Then copy the token and use it in the API call below."
    exit 1
}

Write-Host ""
Write-Host "To deploy rules via REST API, use this curl command:" -ForegroundColor Yellow
Write-Host ""
Write-Host "curl -X POST \"https://firebaserules.googleapis.com/v1/projects/$projectId/releases?databaseId=$databaseId\" \"
Write-Host "  -H \"Authorization: Bearer YOUR_ACCESS_TOKEN\" \"
Write-Host "  -H \"Content-Type: application/json\" \"
Write-Host "  -d '{\"ruleset\": {\"source\": {\"files\": [{\"content\": \"$($rulesContent -replace '"', '\"')}\"}]}}}'"
Write-Host ""


