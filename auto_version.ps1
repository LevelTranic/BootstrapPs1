# Define the URL to download the JSON file
$jsonUrl = "https://bmclapi2.bangbang93.com/mc/game/version_manifest_v2.json"

# Define the path to the output JSON file
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "version.json"

# Download the JSON content
$jsonContent = Invoke-RestMethod -Uri $jsonUrl

# Filter the versions to include only release types and versions >= 1.8
$releaseVersions = $jsonContent.versions | Where-Object {
    $_.type -eq 'release' -and [version]$_.id -ge [version]"1.8"
} | Select-Object -ExpandProperty id

# Create an object to hold the release versions
$outputObject = @{
    versions = $releaseVersions
}

# Convert the object to JSON format
$releaseVersionsJson = $outputObject | ConvertTo-Json

# Write the JSON content to the output file
Set-Content -Path $outputFile -Value $releaseVersionsJson

# Output a message indicating the script has completed
Write-Host "Release versions (>= 1.8) have been written to $outputFile"
