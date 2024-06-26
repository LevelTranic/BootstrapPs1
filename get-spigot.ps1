# Define the path for version.json and auto_version.ps1
$versionFilePath = Join-Path -Path $PSScriptRoot -ChildPath "version.json"
$autoVersionScript = Join-Path -Path $PSScriptRoot -ChildPath "auto_version.ps1"
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "spigot.json"

# Function to load version.json
function Load-VersionFile {
    if (Test-Path -Path $versionFilePath) {
        return Get-Content -Path $versionFilePath | ConvertFrom-Json
    } else {
        return $null
    }
}

# Attempt to load version.json
$versionData = Load-VersionFile

# If version.json does not exist, run auto_version.ps1 and attempt to load version.json again
if (-not $versionData) {
    Write-Host "version.json not found. Running auto_version.ps1..."
    & $autoVersionScript
    $versionData = Load-VersionFile

    # If version.json still does not exist, report error and exit
    if (-not $versionData) {
        Write-Host "Error: version.json not found after running auto_version.ps1."
        exit 1
    }
}

# Prepare the JSON structure for spigot.json
$outputObject = @{
    latest = @{
        version = $versionData.versions[0]
        url = "https://download.getbukkit.org/spigot/spigot-$($versionData.versions[0]).jar"
    }
    versions = @()
}

# Populate the versions array
foreach ($version in $versionData.versions) {
    $outputObject.versions += @{
        version = $version
        url = "https://download.getbukkit.org/spigot/spigot-$version.jar"
    }
}

# Convert the object to JSON format
$outputJson = $outputObject | ConvertTo-Json -Depth 3

# Write the JSON content to the output file
Set-Content -Path $outputFile -Value $outputJson

# Output a message indicating the script has completed
Write-Host "Processed Spigot versions and written to $outputFile"
