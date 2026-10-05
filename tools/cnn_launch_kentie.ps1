# ---------------------------------------------------------------------------
# cnn_launch_kentie.ps1 - Start CNN through Kentie's launcher for bridge work.
#
# Kentie's log (Documents\Deus Ex\System\deusex.log) and CNNAgent.ini can be
# read while the game runs; the original exe locks its log. If the launcher
# shows its menu ("Deus Exe Launcher"), Play is pressed. Returns once the
# bridge answers (cnn_bridge.ps1 WHERE). The bridge's gate is armed by
# cnn_agent_send.ps1 with every command, so no startup exec file is needed.
#
# Usage: cnn_launch_kentie.ps1 [-Root <Deus Ex root>]
# ---------------------------------------------------------------------------
param([string]$Root = 'D:\Program Files (x86)\Steam\steamapps\common\Deus Ex')

$sys = Join-Path $Root 'System'
$ini = Join-Path $Root 'CodenameNebula\System\CNN.ini'
$user = Join-Path $Root 'CodenameNebula\System\CNNUser.ini'
Start-Process -FilePath (Join-Path $sys 'DeusEx.exe') -WorkingDirectory $sys `
    -ArgumentList "INI=`"$ini`"", "USERINI=`"$user`"", '-log'

$shell = New-Object -ComObject WScript.Shell
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 1
    $p = Get-Process DeusEx -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $p) { continue }
    if ($p.MainWindowTitle -eq 'Deus Exe Launcher') {
        if ($shell.AppActivate($p.Id)) { Start-Sleep -Milliseconds 400; $shell.SendKeys('{ENTER}') }
        Start-Sleep -Seconds 2
    }
    elseif ($p.MainWindowTitle -eq 'Deus Ex') { break }
}
"pid=$($p.Id) title=$($p.MainWindowTitle)"
& (Join-Path $PSScriptRoot 'cnn_bridge.ps1') -SystemDir $sys -Timeout 60 'WHERE'
