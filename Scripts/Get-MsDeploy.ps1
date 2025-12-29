# ---------------------------------------------------------------------------
# Get-MsDeploy.ps1
# Usage: .\Get-MsDeploy.ps1 [-StaticPath "C:\Path\To\msdeploy.exe"]
# ---------------------------------------------------------------------------

param(
    [string]$StaticPath = $null
)

# 1. If a static path is provided, verify and return it.
if ($StaticPath) {
    if (Test-Path $StaticPath) {
        Write-Verbose "Using provided static path."
        return $StaticPath
    } else {
        Write-Warning "The provided static path was not found: $StaticPath. Attempting auto-discovery..."
    }
}

# 2. Dynamic Discovery Logic
$searchPaths = @(
    "$env:ProgramFiles\IIS\Microsoft Web Deploy *",
    "${env:ProgramFiles(x86)}\IIS\Microsoft Web Deploy *"
)

# Get all folders matching the pattern, sort by name descending (V4 before V3)
$installedVersions = Get-ChildItem -Path $searchPaths -ErrorAction SilentlyContinue | 
                     Sort-Object Name -Descending

foreach ($folder in $installedVersions) {
    $potentialPath = Join-Path $folder.FullName "msdeploy.exe"
    if (Test-Path $potentialPath) {
        # Return the found path and exit the script
        return $potentialPath
    }
}

# 3. Fail if nothing found
Write-Error "Could not find msdeploy.exe in standard installation paths."
exit 1