# ---------------------------------------------------------------------------
# cnn_bridge.ps1 - Drive CNNAgentBridge with acknowledged commands.
#
# Companion to cnn_agent_send.ps1 (which only queues a line). Each command is
# queued, then this waits until CNNAgentBridge writes its acknowledgement to
# CNNAgent.ini (SaveConfig, on disk at once -- the game log reaches disk in
# chunks and could lag a command by 30s) and prints what the command
# reported (out[] in that file).
#
#   SNAP <name>              also saves the lines to <SnapDir>\<name>.txt for
#                            cnn_snapdiff.ps1
#   LOAD / QLOAD / OPEN /    right after the ack the LOAD line is overwritten
#   NEWGAME / TESTENDING     with WHERE (a load restores the saved, older
#                            lastAgentSeq, and the LOAD would run again), then
#                            this waits for the new level's bridge to answer
#
# Usage:
#   cnn_bridge.ps1 "OPEN 06_OpheliaL2" "SNAP before" "SAVE 900 test"
#   cnn_bridge.ps1 -Quiet "LOAD 900"
#
# Written for the save/load audit, 2026-10-05 (CNNDocs/Bridge_SaveLoad_Plan.md).
# CNNAgent.ini lives next to the player's ini: with Kentie's launcher that is
# Documents\Deus Ex\System; pass -Ini when it is elsewhere.
# ---------------------------------------------------------------------------
param(
    [Parameter(Position=0, ValueFromRemainingArguments=$true)][string[]]$Cmds,
    [string]$SystemDir = 'D:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System',
    [string]$Ini = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Deus Ex\System\CNNAgent.ini'),
    [string]$SnapDir = (Join-Path $env:TEMP 'cnn_snaps'),
    [int]$Timeout = 20,
    [switch]$Quiet
)

$send = Join-Path $PSScriptRoot 'cnn_agent_send.ps1'
New-Item -ItemType Directory -Force $SnapDir | Out-Null

function ReadAck {
    $r = @{ seq = -1; out = @() }
    try { $lines = [IO.File]::ReadAllLines($Ini) } catch { return $r }
    $n = 0
    foreach ($l in $lines) {
        if ($l -match '^ackSeq=(\d+)') { $r.seq = [int]$Matches[1] }
        elseif ($l -match '^outCount=(\d+)') { $n = [int]$Matches[1] }
    }
    for ($i = 0; $i -lt $n; $i++) {
        $p = "Out[$i]="
        $m = $lines | Where-Object { $_.StartsWith($p, [StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1
        if ($m) { $r.out += $m.Substring($m.IndexOf('=') + 1) }
    }
    $r
}

function Send([string]$c) {
    $parts = $c -split ' ', 2
    $a = if ($parts.Count -gt 1) { $parts[1] } else { '' }
    & $send -SystemDir $SystemDir -Cmd $parts[0] -Arg $a *> $null
    [int](Get-Content (Join-Path $SystemDir 'CNNAgentCmd.seq') -Raw).Trim()
}

function WaitAck([int]$seq, [int]$secs) {
    $deadline = (Get-Date).AddSeconds($secs)
    while ((Get-Date) -lt $deadline) {
        $r = ReadAck
        if ($r.seq -ge $seq) { return $r }
        Start-Sleep -Milliseconds 250
    }
    $null
}

foreach ($c in $Cmds) {
    $verb = ($c -split ' ')[0].ToUpper()
    $seq = Send $c
    $r = WaitAck $seq $Timeout
    if (-not $r) { "[$seq] $c -> NO ACK"; continue }
    if (-not $Quiet) { "[$seq] $c"; $r.out | ForEach-Object { "    $_" } }
    if ($verb -eq 'SNAP') {
        $name = ($c -split ' ', 2)[1]
        $r.out | Set-Content (Join-Path $SnapDir "$name.txt") -Encoding UTF8
    }
    if ($verb -in @('LOAD', 'QLOAD', 'OPEN', 'NEWGAME', 'TESTENDING')) {
        Start-Sleep -Milliseconds 300
        $s2 = Send 'WHERE'
        Start-Sleep -Seconds 3
        $r2 = WaitAck $s2 90
        if ($r2) { "    after travel: ack $s2" } else { "    after travel: NO ACK in 90s" }
    }
}
