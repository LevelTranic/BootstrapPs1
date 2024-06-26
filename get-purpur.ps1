param (
    [string]$Version = "1.21"
)

# Define the base URL
$baseUrl = "https://api.purpurmc.org/v2/purpur"

# Construct the URL based on the provided version
$jsonUrl = "$baseUrl/$Version"

# Define the output file path using the script's directory
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "purpur/$Version.json"

# Download the JSON content with error handling
Try
{
    $jsonContent = Invoke-RestMethod -Uri $jsonUrl
}
Catch
{
    if ($_.ErrorDetails.Message)
    {
        Write-Host $_.ErrorDetails.Message
    }
    else
    {
        Write-Host $_
    }
    exit 1
}

# Extract the latest build
$latestBuild = $jsonContent.builds.latest

# Extract all builds
$allBuilds = $jsonContent.builds.all

# Prepare the JSON structure
$outputObject = @{
    latest = @{
        version = "$Version-$latestBuild"
        url = "$baseUrl/$Version/$latestBuild/download"
    }
    versions = @()
}

# Populate the versions array
foreach ($build in $allBuilds) {
    $outputObject.versions += @{
        version = "$Version-$build"
        url = "$baseUrl/$Version/$build/download"
    }
}

# Convert the object to JSON format
$outputJson = $outputObject | ConvertTo-Json -Depth 3

# Create the directory if it doesn't exist
$purpurDir = Join-Path -Path $PSScriptRoot -ChildPath "purpur"
if (-not (Test-Path -Path $purpurDir)) {
    New-Item -ItemType Directory -Path $purpurDir
}

# Write the JSON content to the output file
Set-Content -Path $outputFile -Value $outputJson

# Output a message indicating the script has completed
Write-Host "Processed builds for version $Version and written to $outputFile"
