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

    $getPapermcScript = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "lib") -ChildPath "get-bukkit.ps1"

    foreach ($version in $versions) {
        Write-Host "Processing version $version..."
        & $getPapermcScript $proj $version
    }

    Write-Host "All versions have been processed."
}

function Get-Spigot {
    $getSpigotScript = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "lib") -ChildPath "get-bukkit.ps1"
    & $getSpigotScript $proj
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
        Write-Error "Unknown Minecraft Server: $proj"
        exit 1
    }
}