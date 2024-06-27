param (
    [string]$Version = "1.20.6"
)

$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "../data"
if (-not (Test-Path -Path $outputDir))
{
    New-Item -ItemType Directory -Path $outputDir
}

$baseUrl = "https://api.multipaper.io/v2/projects/shreddedpaper/versions"

$jsonUrl = "$baseUrl/$Version"

$outputFile = Join-Path -Path $outputDir -ChildPath "shreddedpaper/$Version.json"

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

$latestBuild = ($jsonContent.builds | Measure-Object -Maximum).Maximum

$allBuilds = $jsonContent.builds

$outputObject = @{
    latest = @{
        version = "$Version-$latestBuild"
        url = "$baseUrl/$Version/builds/$latestBuild/downloads/shreddedpaper-$Version-$latestBuild.jar"
    }
    versions = @()
}

foreach ($build in $allBuilds) {
    $outputObject.versions += @{
        version = "$Version-$build"
        url = "$baseUrl/$Version/builds/$build/downloads/shreddedpaper-$Version-$build.jar"
    }
}

$outputJson = $outputObject | ConvertTo-Json -Depth 3

$purpurDir = Join-Path -Path $outputDir -ChildPath "shreddedpaper"
if (-not (Test-Path -Path $purpurDir)) {
    New-Item -ItemType Directory -Path $purpurDir
}

Set-Content -Path $outputFile -Value $outputJson

Write-Host "Processed builds for version $Version and written to $outputFile"
