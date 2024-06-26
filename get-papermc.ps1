param (
    [string]$Version = "1.21",
    [string]$proj = "paper"
)

switch ($proj) {
    "paper" { }
    "folia" { }
    default {
        Write-Error "proj must be either 'paper' or 'folia'."
        exit 1
    }
}

$baseUrl = "https://api.papermc.io/v2/projects/$proj/versions"

$jsonUrl = "$baseUrl/$Version/builds"

$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "$proj/$Version.json"

Try
{
    $jsonContent = Invoke-RestMethod -Uri $jsonUrl
}
Catch
{
    if ($_.ErrorDetails.Message)
    {
        Write-Error $_.ErrorDetails.Message
    }
    else
    {
        Write-Error $_
    }
    exit 1
}

$latestBuild = $jsonContent.builds | Sort-Object -Property build -Descending | Select-Object -First 1

$allBuilds = $jsonContent.builds | Sort-Object -Property build

$outputObject = @{
    latest = @{
        version = "$Version-$( $latestBuild.build )"
        url = "$baseUrl/$Version/builds/$( $latestBuild.build )/downloads/$( $latestBuild.downloads.application.name )"
    }
    versions = @()
}

foreach ($build in $allBuilds)
{
    $outputObject.versions += @{
        version = "$Version-$( $build.build )"
        url = "$baseUrl/$Version/builds/$( $build.build )/downloads/$( $build.downloads.application.name )"
    }
}

$outputJson = $outputObject | ConvertTo-Json -Depth 3

$paperDir = Join-Path -Path $PSScriptRoot -ChildPath $proj
if (-not (Test-Path -Path $paperDir))
{
    New-Item -ItemType Directory -Path $paperDir
}

Set-Content -Path $outputFile -Value $outputJson

Write-Host "Processed builds for version $Version and written to $outputFile"