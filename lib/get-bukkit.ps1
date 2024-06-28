param (
    [string]$proj = "spigot",
    [string]$Version = "1.20.4"
)

$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "../data"
if (-not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

switch ($proj) {
    "purpur" { 
        $baseUrl = "https://api.purpurmc.org/v2/purpur"
        $jsonUrl = "$baseUrl/$Version"
    }
    "paper" { 
        $baseUrl = "https://api.papermc.io/v2/projects/$proj/versions"
        $jsonUrl = "$baseUrl/$Version/builds" 
    }
    "folia" {
        $baseUrl = "https://api.papermc.io/v2/projects/$proj/versions"
        $jsonUrl = "$baseUrl/$Version/builds" 
    }
    "shreddedpaper" {
        $baseUrl = "https://api.multipaper.io/v2/projects/shreddedpaper/versions"
        $jsonUrl = "$baseUrl/$Version" 
    }
    "spigot" { }
    "luminol" {
        $baseUrl = "https://api.luminolmc.com/v2/projects/luminol/versions"
        $jsonUrl = "$baseUrl/$Version/builds" 
    }
    default {
        Write-Error "proj must be either 'paper', 'folia', 'spigot'."
        exit 1
    }
}

$outputPath = Join-Path -Path $outputDir -ChildPath "$proj"
$outputFile = Join-Path -Path $outputPath -ChildPath "$Version.json"

if (-not (Test-Path -Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath
}

$versionFilePath = Join-Path -Path $outputDir -ChildPath "minecraft_version.json"
$autoVersionScript = Join-Path -Path $PSScriptRoot -ChildPath "auto_version.ps1"

function LoadVersionFile {
    if (Test-Path -Path $versionFilePath) {
        return Get-Content -Path $versionFilePath | ConvertFrom-Json
    }
    else {
        return $null
    }
}

$versionData = LoadVersionFile

if (-not $versionData) {
    Write-Host "aoto_version.json not found. Running auto_version.ps1..."
    & $autoVersionScript
    $versionData = LoadVersionFile

    if (-not $versionData) {
        Write-Host "Error: auto_version.json not found after running auto_version.ps1."
        exit 1
    }
}

function Get-Spigot {
    $outputFile = Join-Path -Path $outputPath -ChildPath "spigot.json"

    $outputObject = @{
        latest   = @{
            version = $versionData.versions[0]
            url     = "https://download.getbukkit.org/spigot/spigot-$($versionData.versions[0]).jar"
        }
        versions = @()
    }

    foreach ($version in $versionData.versions) {
        $outputObject.versions += @{
            version = $version
            url     = "https://download.getbukkit.org/spigot/spigot-$version.jar"
        }
    }

    $outputJson = $outputObject | ConvertTo-Json -Depth 3

    Set-Content -Path $outputFile -Value $outputJson

    Write-Host "Processed Spigot versions and written to $outputFile"

}

function Get-Bukkit {
    Try {
        $jsonContent = Invoke-RestMethod -Uri $jsonUrl
    }
    Catch {
        if ($_.ErrorDetails.Message) {
            Write-Host $_.ErrorDetails.Message
        }
        else {
            Write-Host $_
        }
        exit 1
    }

    if ($proj -eq "luminol") {
        if (-not $jsonContent.builds) {
            Write-Error "Not found Luminol $Version"
            exit 1
        }
    }

    if ($proj -eq "shreddedpaper") {
        $latestBuild = ($jsonContent.builds | Measure-Object -Maximum).Maximum
        $allBuilds = $jsonContent.builds
    }
    elseif ($proj -eq "purpur") {
        $latestBuild = $jsonContent.builds.latest
        $allBuilds = $jsonContent.builds.all
    }
    else {
        $latestBuild = $jsonContent.builds | Sort-Object -Property build -Descending | Select-Object -First 1
        $allBuilds = $jsonContent.builds | Sort-Object -Property build
    }


    if ($proj -eq "purpur") {
        $outputObject = @{
            latest   = @{
                version = "$Version-$latestBuild"
                url     = "$baseUrl/$Version/$latestBuild/download"
            }
            versions = @()
        }
    }
    elseif ($proj -eq "shreddedpaper") {
        $outputObject = @{
            latest   = @{
                version = "$Version-$latestBuild"
                url     = "$baseUrl/$Version/builds/$latestBuild/downloads/shreddedpaper-$Version-$latestBuild.jar"
            }
            versions = @()
        }
    }
    else {
        $outputObject = @{
            latest   = @{
                version = "$Version-$( $latestBuild.build )"
                url     = "$baseUrl/$Version/builds/$( $latestBuild.build )/downloads/$( $latestBuild.downloads.application.name )"
            }
            versions = @()
        }
    }

    if ($proj -eq "purpur") {
        foreach ($build in $allBuilds) {
            $outputObject.versions += @{
                version = "$Version-$build"
                url     = "$baseUrl/$Version/$build/download"
            }
        }
    }
    elseif ($proj -eq "shreddedpaper") {
        foreach ($build in $allBuilds) {
            $outputObject.versions += @{
                version = "$Version-$build"
                url     = "$baseUrl/$Version/builds/$build/downloads/shreddedpaper-$Version-$build.jar"
            }
        }
    }
    else {
        foreach ($build in $allBuilds) {
            $outputObject.versions += @{
                version = "$Version-$( $build.build )"
                url     = "$baseUrl/$Version/builds/$( $build.build )/downloads/$( $build.downloads.application.name )"
            }
        }
    }

    $outputJson = $outputObject | ConvertTo-Json -Depth 3

    Set-Content -Path $outputFile -Value $outputJson

    Write-Host "Processed builds for version $Version and written to $outputFile"
}

if ($proj -eq "spigot") {
    Get-Spigot
} else {
    Get-Bukkit
}