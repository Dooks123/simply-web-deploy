
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

$recycleMode = $args[0]
$recycleApp = $args[1]
$computerName = $args[2]
$username = $args[3]
$password = $args[4]

$computerNameArgument = $computerName + '/MsDeploy.axd?site=' + $recycleApp

$msdeployArguments = 
    "-verb:sync",
    "-allowUntrusted",
    "-source:recycleApp",
    ("-dest:" + 
        "recycleApp=${recycleApp}," +
        "recycleMode=${recycleMode}," +
        "computerName=${computerNameArgument}," + 
        "username=${username}," +
        "password=${password}," +
        "AuthType='Basic'"
    )

& $msdeploy $msdeployArguments