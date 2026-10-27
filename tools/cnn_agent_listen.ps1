# ---------------------------------------------------------------------------
# cnn_agent_listen.ps1 - Let CNNAgentBridge poll CNNAgentCmd.txt.
#
# The bridge reads CNNAgentCmd.txt only with bListen=True in CNNAgent.ini, so
# a player's log does not fill with "Can't find file" once a second. The
# ini is read when the game starts: run this before launching. The bridge's
# SaveConfig keeps the value, so once per install is enough.
#
# CNNAgent.ini lives next to the player's ini: Documents\Deus Ex\System with
# Kentie's launcher, the game's System with the original exe.
#
# Usage: cnn_agent_listen.ps1 [-Ini <path to CNNAgent.ini>]
# ---------------------------------------------------------------------------
param([string]$Ini = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Deus Ex\System\CNNAgent.ini'))

$section = '[CNN.CNNAgentBridge]'
$lines = @()
if (Test-Path $Ini) { $lines = @(Get-Content $Ini) }
if ($lines -contains 'bListen=True') { return }

$lines = @($lines | Where-Object { $_ -notmatch '^bListen=' })
$at = [Array]::IndexOf($lines, $section)
if ($at -lt 0) {
    $lines = @($section, 'bListen=True') + $lines
} else {
    $lines = $lines[0..$at] + 'bListen=True' + $(if ($at + 1 -lt $lines.Count) { $lines[($at + 1)..($lines.Count - 1)] })
}
Set-Content -Path $Ini -Value $lines -Encoding ASCII
"bListen=True -> $Ini"
