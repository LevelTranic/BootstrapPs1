$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "../data"
if (-not (Test-Path -Path $outputDir))
{
    New-Item -ItemType Directory -Path $outputDir
}

$jsonUrl = "https://bmclapi2.bangbang93.com/mc/game/version_manifest_v2.json"

$outputFile = Join-Path -Path $outputDir -ChildPath "minecraft_version.json"

$jsonContent = Invoke-RestMethod -Uri $jsonUrl

$releaseVersions = $jsonContent.versions | Where-Object {
    $_.type -eq 'release' -and [version]$_.id -ge [version]"1.4"
} | Select-Object -ExpandProperty id

$outputObject = @{
    versions = $releaseVersions
}

$releaseVersionsJson = $outputObject | ConvertTo-Json

Set-Content -Path $outputFile -Value $releaseVersionsJson

Write-Host "Release versions (>= 1.4) have been written to $outputFile"
