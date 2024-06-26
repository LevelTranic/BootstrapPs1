param (
    [string]$Version = "1.21"
)

$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "../data"
if (-not (Test-Path -Path $outputDir))
{
    New-Item -ItemType Directory -Path $outputDir
}

$baseUrl = "https://api.purpurmc.org/v2/purpur"

$jsonUrl = "$baseUrl/$Version"

$outputFile = Join-Path -Path $outputDir -ChildPath "purpur/$Version.json"

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

$latestBuild = $jsonContent.builds.latest

$allBuilds = $jsonContent.builds.all

$outputObject = @{
    latest = @{
        version = "$Version-$latestBuild"
        url = "$baseUrl/$Version/$latestBuild/download"
    }
    versions = @()
}

foreach ($build in $allBuilds) {
    $outputObject.versions += @{
        version = "$Version-$build"
        url = "$baseUrl/$Version/$build/download"
    }
}

$outputJson = $outputObject | ConvertTo-Json -Depth 3

$purpurDir = Join-Path -Path $outputDir -ChildPath "purpur"
if (-not (Test-Path -Path $purpurDir)) {
    New-Item -ItemType Directory -Path $purpurDir
}

Set-Content -Path $outputFile -Value $outputJson

Write-Host "Processed builds for version $Version and written to $outputFile"
