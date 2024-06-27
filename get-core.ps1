param (
    [string]$proj = "paper"
)

function Get {
    param (
        [string]$url = $null
    )

    Try {
        $jsonContent = Invoke-RestMethod -Uri $url
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

    $versions = $jsonContent.versions

    if ($null -eq $versions -or $versions.Count -eq 0) {
        Write-Host "Error: No versions found in the API response."
        exit 1
    }

    if ($proj -eq "paper" -or $proj -eq "folia") {
        $getPapermcScript = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "lib") -ChildPath "get-papermc.ps1"
    } else {
        $getPapermcScript = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "lib") -ChildPath "get-$proj.ps1"
    }

    foreach ($version in $versions) {
        Write-Host "Processing version $version..."
        & $getPapermcScript $version $proj
    }

    Write-Host "All versions have been processed."
}

function Get-Spigot {
    $getSpigotScript = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "lib") -ChildPath "get-spigot.ps1"
    & $getSpigotScript
}

switch ($proj) {
    "purpur" {
        Get "https://api.purpurmc.org/v2/purpur"
    }
    "paper" { Get "https://api.papermc.io/v2/projects/$proj" }
    "folia" { Get "https://api.papermc.io/v2/projects/$proj" }
    "shreddedpaper" { Get "https://api.multipaper.io/v2/projects/$proj" }
    "spigot" { 
        Get-Spigot
    }
    "luminol" {
        Get "https://api.luminolmc.com/v2/projects/luminol"
    }
    default {
        Write-Error "proj must be either 'paper', 'folia', 'spigot'."
        exit 1
    }
}