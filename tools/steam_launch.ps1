# steam_launch.ps1
# Generates and opens an HTML trampoline that launches Codename Nebula via Steam.
# The browser triggers the steam:// protocol handler, which makes Steam launch
# the game with CNN's INI arguments. This gives Steam overlay and play time tracking.
#
# Uses -ini= (lowercase, with dash) and absolute paths with &quot; HTML entities.
# This is the same approach as DeusExNonSteamLink.

param(
    [string]$CnnIniPath,
    [string]$CnnUserIniPath
)

if (-not (Test-Path $CnnIniPath)) {
    Write-Host "  ERROR: CNN.ini not found at $CnnIniPath"
    exit 1
}

# Build steam:// URL with HTML-entity-quoted absolute paths
$iniArg = "-ini=&quot;$CnnIniPath&quot;"
$userIniArg = "-userini=&quot;$CnnUserIniPath&quot;"
$steamUrl = "steam://rungameid/6910//$iniArg $userIniArg"

# Generate HTML trampoline
$htmlContent = @"
<html>
<body>
<a id="link" target="_self" href="$steamUrl">Run Codename Nebula</a>
</body>
<script>
function LoadGame() {
  document.getElementById("link").click();
};
window.onload = LoadGame();
</script>
</html>
"@

$htmlFile = Join-Path ([System.IO.Path]::GetTempPath()) "PlayCNNSteam.html"
[System.IO.File]::WriteAllText($htmlFile, $htmlContent)

Write-Host "  Launching Codename Nebula via Steam..."
Write-Host "  A browser window will open briefly to trigger the Steam protocol."
Write-Host ""

Start-Process $htmlFile
