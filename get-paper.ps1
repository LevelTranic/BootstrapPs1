param (
    [string]$Version = "1.21"
)

# Define the base URL
$baseUrl = "https://api.papermc.io/v2/projects/paper/versions"

# Construct the URL based on the provided version
$jsonUrl = "$baseUrl/$Version/builds"

# Define the output file path
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "paper/$Version.json"

# Download the JSON content
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
$latestBuild = $jsonContent.builds | Sort-Object -Property build -Descending | Select-Object -First 1

# Extract all builds
$allBuilds = $jsonContent.builds | Sort-Object -Property build

# Prepare the JSON structure
$outputObject = @{
    latest = @{
        version = "$Version-$( $latestBuild.build )"
        url = "$baseUrl/$Version/builds/$( $latestBuild.build )/downloads/$( $latestBuild.downloads.application.name )"
    }
    versions = @()
}

# Populate the versions array
foreach ($build in $allBuilds)
{
    $outputObject.versions += @{
        version = "$Version-$( $build.build )"
        url = "$baseUrl/$Version/builds/$( $build.build )/downloads/$( $build.downloads.application.name )"
    }
}

# Convert the object to JSON format
$outputJson = $outputObject | ConvertTo-Json -Depth 3

# Create the directory if it doesn't exist
$paperDir = Join-Path -Path $PSScriptRoot -ChildPath "paper"
if (-not (Test-Path -Path $paperDir))
{
    New-Item -ItemType Directory -Path $paperDir
}

# Write the JSON content to the output file
Set-Content -Path $outputFile -Value $outputJson

# Output a message indicating the script has completed
Write-Host "Processed builds for version $Version and written to $outputFile"