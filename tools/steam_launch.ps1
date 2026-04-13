# steam_launch.ps1
# Launches Codename Nebula via Steam for play time tracking and overlay.
#
# Uses the steam:// protocol with URL-encoded quotes (%22) to pass
# INI arguments in a format that both Steam and Kentie's launcher accept.
# No browser or HTML trampoline needed.

param(
    [string]$CnnIniPath,
    [string]$CnnUserIniPath
)

if (-not (Test-Path $CnnIniPath)) {
    Write-Host "  ERROR: CNN.ini not found at $CnnIniPath"
    exit 1
}

# Build steam:// URL with %22 (URL-encoded quotes) around paths
# INI= and USERINI= (no dash prefix) is the Unreal Engine 1 command-line format
$iniArg = "INI=%22$CnnIniPath%22"
$userIniArg = "USERINI=%22$CnnUserIniPath%22"
$steamUrl = "steam://rungameid/6910//$iniArg $userIniArg"

Write-Host "  Launching: $steamUrl"
Start-Process $steamUrl
