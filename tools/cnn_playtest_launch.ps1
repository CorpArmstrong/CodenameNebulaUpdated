# ---------------------------------------------------------------------------
# cnn_playtest_launch.ps1 - Launch CNN with CNNAgentBridge auto-started.
#
# Companion to cnn_agent_send.ps1 / CNN\Classes\CNNAgentBridge.uc. A normal
# playthrough never starts the bridge (TantalusDenton.bAgentAutoStart
# defaults False) -- this script is what flips it on, the same way
# System\cheaton.txt already flips bCheatsEnabled: a startup "-EXEC=<file>"
# containing a `set` command, run before any level (and therefore any
# TantalusDenton instance) exists.
#
# Requirements confirmed 2026-09-23 (see project_agent_bridge memory):
#   - Use the small "DeusEx 1112fm (Original EXE).exe", NOT deusex.exe
#     (Kentie/Han GUI launcher) -- the launcher blocks on its own splash
#     screen and never reaches the map.
#   - That exe's log is exclusively locked while it runs. Do not try to
#     tail it live; read it after the session ends (see cnn_agent_send.ps1
#     for a lock-free progress signal: fresh ShotNNNN.bmp files).
#   - ALWAYS stop the session with cnn_agent_send.ps1 -Cmd QUIT, never
#     Stop-Process -- killing it trips the engine's dirty-shutdown Recovery
#     Mode dialog on the next launch, which only a human can click through.
#
# Usage:
#   cnn_playtest_launch.ps1 -SystemDir <DeusExRoot>\System [-Map 06_OpheliaL2]
#
# -Map only sets LocalMap=/Map= in the launch INI, which CNN does NOT
# actually honour (it always boots to its own main menu level first --
# confirmed 2026-09-23). Reach a specific map with
# `cnn_agent_send.ps1 -Cmd OPEN -Arg <mapname>` after confirming the bridge
# is alive on the menu level (a WHERE round-trip), not via this parameter.
# It is kept only because test_meshes_make_ini.ps1 requires a value.
# ---------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$true)][string]$SystemDir,
    [string]$Map = "CNNentry"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$deusExRoot = Split-Path -Parent $SystemDir
$distSys = Join-Path $deusExRoot "CodenameNebula\System"

if (-not (Test-Path (Join-Path $distSys 'CNN.ini'))) {
    Write-Host "ERROR: $distSys\CNN.ini not found. Run cnn install first."
    exit 1
}

$exe = Join-Path $SystemDir "DeusEx 1112fm (Original EXE).exe"
if (-not (Test-Path $exe)) {
    Write-Host "ERROR: $exe not found. cnn_playtest_launch.ps1 only supports the direct-boot 1112fm exe."
    exit 1
}

# 1. Flip the auto-start flag via a startup exec file (proven mechanism --
#    see cheaton.txt/cheatoff.txt already in this SystemDir). Written to
#    TEMP, not SystemDir: confirmed 2026-09-23 that the engine's -EXEC=
#    handling truncates the path at the first space REGARDLESS of quoting
#    on the process command line ("D:\Program Files (x86)\..." breaks at
#    "D:\Program") -- the same reason test_meshes_make_ini.ps1's caller
#    uses a short TEMP path instead of the game directory.
$autoStartFile = Join-Path $env:TEMP "cnnagenton.txt"
Set-Content -Path $autoStartFile -Value "set cnn.tantalusdenton bAgentAutoStart True" -Encoding ASCII -NoNewline

# 2. Start clean: a stale CNNAgentCmd.txt from a previous session gets
#    replayed instantly by the new session's seq=0 bridge, which is
#    especially bad if the last line left there was QUIT.
$cmdFile = Join-Path $SystemDir "CNNAgentCmd.txt"
Set-Content -Path $cmdFile -Value '' -NoNewline -Encoding ASCII

# 3. Generate the launch INI (LocalMap=/Map= override -- see the caveat
#    above about it not actually skipping the menu).
$tempIni = Join-Path $env:TEMP "CNN_playtest.ini"
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repoRoot "tools\test_meshes_make_ini.ps1") `
    -InputIni (Join-Path $distSys 'CNN.ini') -OutputIni $tempIni -MapName $Map | Out-Null

# 4. Back up any existing log so this session's log starts clean.
$activeLog = Join-Path $SystemDir "DeusEx 1112fm (Original EXE).log"
if (Test-Path $activeLog) {
    Move-Item $activeLog "$activeLog.preTest" -Force
}

# 5. Launch. -EXEC runs the `set` line before any map loads; no `open` in
#    it, so the documented "-EXEC commands after open run before the map
#    finishes loading" trap does not apply here.
$userIni = Join-Path $distSys "CNNUser.ini"
$argList = @("INI=`"$tempIni`"", "-EXEC=`"$autoStartFile`"", "-log")
if (Test-Path $userIni) { $argList += "USERINI=`"$userIni`"" }

Start-Process -FilePath $exe -ArgumentList $argList -WorkingDirectory $SystemDir
Start-Sleep -Seconds 3

$proc = Get-Process -Name "DeusEx 1112fm (Original EXE)" -ErrorAction SilentlyContinue
if ($proc) {
    Write-Host "Launched (PID $($proc.Id)). Next: toolsn_agent_wait_alive.ps1 (returns as soon as the bridge answers)."
} else {
    Write-Host "WARNING: process not found after launch -- check for a blocking dialog (e.g. Recovery Mode) on screen."
}
