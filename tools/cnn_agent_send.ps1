# ---------------------------------------------------------------------------
# cnn_agent_send.ps1 - Queue one command for CNNAgentBridge to run in-game.
#
# Companion to CNN\Classes\CNNAgentBridge.uc / the CNNAgentRun exec function
# on TantalusDenton.uc. CNNAgentBridge polls <SystemDir>\CNNAgentCmd.txt once
# a second via the engine's "exec" console feature; this script is the write
# side of that file. It owns the sequence counter so the in-game side never
# has to delete or truncate anything -- UnrealScript has no confirmed file
# I/O API for that in this engine, so re-reading the same line on the next
# poll must be safe, and sequence-gating (see CNNAgentRun) is what makes it
# safe.
#
# Prerequisites (once per game session): type `CNNAgentStart` at the in-game
# console. Nothing consumes the file before that.
#
# Usage:
#   cnn_agent_send.ps1 -SystemDir <dir> -Cmd GOTO -Arg TUBE
#   cnn_agent_send.ps1 -SystemDir <dir> -Cmd FIRE -Arg MiniGameDispatcher
#   cnn_agent_send.ps1 -SystemDir <dir> -Cmd WHERE
#   cnn_agent_send.ps1 -SystemDir <dir> -Cmd SHOT
#
# Then confirm it ran with (see find_log.ps1):
#   find_log.ps1 -SystemDir <dir> -Pattern "CNN agent: seq=<n>"
# ---------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$true)][string]$SystemDir,
    [Parameter(Mandatory=$true)]
    [ValidateSet('GOTO','GOTOVEC','FIRE','FROB','DAMAGE','OPEN','CONVERSE','ADVANCE','STATUS','MAGSTATE','CONDUMP','NEWGAME','RAW','WHERE','FLAGS','PROBE','TESTENDING','SHOT','QUIT')]
    [string]$Cmd,
    [string]$Arg = ""
)

if (-not (Test-Path $SystemDir)) {
    Write-Host "SystemDir not found: $SystemDir"
    exit 1
}

$seqFile = Join-Path $SystemDir 'CNNAgentCmd.seq'
$cmdFile = Join-Path $SystemDir 'CNNAgentCmd.txt'

$seq = 0
if (Test-Path $seqFile) {
    $raw = (Get-Content $seqFile -Raw -ErrorAction SilentlyContinue)
    if ($raw) { [int]::TryParse($raw.Trim(), [ref]$seq) | Out-Null }
}
$seq++

$line = "CNNAgentRun $seq $Cmd $Arg".TrimEnd()

# ASCII, no BOM: the engine's console-exec reader is old-school and a UTF-8
# BOM on the first line has caused misparsed commands elsewhere in this repo.
#
# Retry on write: CNNAgentBridge's Timer polls this same file via "exec"
# once a second, and confirmed 2026-09-23 that landing a write inside that
# narrow window throws a sharing-violation IOException -- silently losing
# the command if uncaught (a TESTENDING call vanished this way with no
# trace in the bridge's own log, only discovered by cross-checking against
# expected follow-up state).
$attempts = 0
while ($true) {
    try {
        [System.IO.File]::WriteAllText($cmdFile, "$line`r`n", [System.Text.Encoding]::ASCII)
        break
    } catch [System.IO.IOException] {
        $attempts++
        if ($attempts -ge 5) { throw }
        Start-Sleep -Milliseconds 200
    }
}
[System.IO.File]::WriteAllText($seqFile, "$seq", [System.Text.Encoding]::ASCII)

Write-Host "Queued (seq=$seq): $line"
Write-Host "Wrote: $cmdFile"
Write-Host "Confirm with: tools\find_log.ps1 -SystemDir `"$SystemDir`" -Pattern `"CNN agent: seq=$seq`""
