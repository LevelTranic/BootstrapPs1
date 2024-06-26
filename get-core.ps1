param (
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

$url = "https://api.papermc.io/v2/projects/$proj"

Try
{
    $jsonContent = Invoke-RestMethod -Uri $url -ErrorAction Stop
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

$versions = $jsonContent.versions

if ($null -eq $versions -or $versions.Count -eq 0) {
    Write-Host "Error: No versions found in the API response."
    exit 1
}

$getPapermcScript = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "lib") -ChildPath "get-papermc.ps1"

foreach ($version in $versions) {
    Write-Host "Processing version $version..."
    & $getPapermcScript $version $proj
}

Write-Host "All versions have been processed."
