$recycleMode = $args[0]
$recycleApp = $args[1]
$computerName = $args[2]
$username = $args[3]
$password = $args[4]
$optMsDeployPath = $args[5] # Optional argument for MSDeploy path

# Locate MSDeploy and pass the static path if it was provided in args[5]
$msdeploy = & "Scripts\Get-MsDeploy.ps1" -StaticPath $optMsDeployPath

if (-not $msdeploy) {
    Write-Error "Could not find msdeploy.exe in standard installation paths."
    exit 1
}

Write-Host "-----------------------------------------"
Write-Host "Setting Application Pool with parameters:"
Write-Host "Recycle Mode:           $recycleMode"
Write-Host "Recycle App:            $recycleApp"
Write-Host "Computer Name:          $computerName"
Write-Host "Optional MsDeploy Path: $optMsDeployPath"
Write-Host "-----------------------------------------"

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