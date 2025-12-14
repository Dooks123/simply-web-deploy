$searchPaths = @(
    "$env:ProgramFiles\IIS\Microsoft Web Deploy *",
    "${env:ProgramFiles(x86)}\IIS\Microsoft Web Deploy *"
)

$msdeploy = $null

# Get all folders matching the pattern, sort by name descending (V4 before V3, etc.)
$installedVersions = Get-ChildItem -Path $searchPaths -ErrorAction SilentlyContinue | 
                     Sort-Object Name -Descending

foreach ($folder in $installedVersions) {
    $potentialPath = Join-Path $folder.FullName "msdeploy.exe"
    if (Test-Path $potentialPath) {
        $msdeploy = $potentialPath
        Write-Host "Found MSDeploy at: $msdeploy"
        break
    }
}

if (-not $msdeploy) {
    Write-Error "Could not find msdeploy.exe in standard installation paths."
    exit 1
}

$source                 = $args[0]
$destination            = $args[1]
$recycleApp             = $args[2]
$computerName           = $args[3]
$username               = $args[4]
$password               = $args[5]
$deleteTarget           = $args[6]
$skipDirectoryPathsInput= $args[7]
$skipFilesInput         = $args[8]
$skipPatternsInput      = $args[9]

Write-Host "------------------------------------"
Write-Host "Starting deployment with parameters:"
Write-Host "Source:               $source"
Write-Host "Destination:          $destination"
Write-Host "Recycle App:          $recycleApp"
Write-Host "Computer Name:        $computerName"
Write-Host "Delete target:        $deleteTarget"
Write-Host "Skip Directory Paths: $skipDirectoryPathsInput"
Write-Host "Skip Files:           $skipFilesInput"
Write-Host "Skip Regex Patterns:  $skipPatternsInput"
Write-Host "------------------------------------"

$computerNameArgument = "$computerName/MsDeploy.axd?site=$recycleApp"

$directory = Split-Path -Path (Get-Location) -Parent
$baseName = (Get-Item $directory).BaseName
$contentPath = Join-Path (Join-Path $directory $baseName) $source

$targetPath = "$recycleApp$destination"

[System.Collections.ArrayList]$msdeployArguments = 
    "-verb:sync",
    "-allowUntrusted",
    "-source:contentPath=$contentPath",
    ("-dest:" + 
      "contentPath=${targetPath}," +
      "computerName=${computerNameArgument}," + 
      "username=${username}," +
      "password=${password}," +
      "AuthType='Basic'"
    )

if ($deleteTarget -NotMatch "true") {
  $msdeployArguments.Add("-enableRule:DoNotDeleteRule")
}

if ($skipDirectoryPathsInput) {
  $skipDirs = $skipDirectoryPathsInput -split ","
  foreach ($dir in $skipDirs) {
    $msdeployArguments.Add("-skip:Directory=$dir")
  }
}

if ($skipFilesInput) {
  $skipFiles = $skipFilesInput -split ","
  foreach ($file in $skipFiles) {
    $msdeployArguments.Add("-skip:File=$file")
  }
}

if ($skipPatternsInput) {
  $skipPatterns = $skipPatternsInput -split ","
  foreach ($pattern in $skipPatterns) {
    $msdeployArguments.Add("-skip:regexPattern=$pattern")
  }
}

& $msdeploy $msdeployArguments