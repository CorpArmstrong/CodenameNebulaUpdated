# ---------------------------------------------------------------------------
# cnn_agent_wait_alive.ps1 - Block until CNNAgentBridge answers, instead of a
# fixed sleep after launch or a map change.
#
# The session log is locked while the game runs, so the only lock-free
# signal is a fresh ShotNNNN.bmp: send SHOT, see whether a new one appears,
# retry. The probe screenshots are deleted so they don't pile up.
#
# Usage:
#   cnn_agent_wait_alive.ps1 -SystemDir <DeusExRoot>\System [-TimeoutSec 60]
# Exit code 0 = bridge answered, 1 = timed out.
# ---------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$true)][string]$SystemDir,
    [int]$TimeoutSec = 60
)

function Get-NewestShot {
    Get-ChildItem $SystemDir -Filter "Shot*.bmp" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

$sw = [Diagnostics.Stopwatch]::StartNew()
$before = Get-NewestShot
while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
    & (Join-Path $PSScriptRoot 'cnn_agent_send.ps1') -SystemDir $SystemDir -Cmd SHOT | Out-Null
    for ($i = 0; $i -lt 4; $i++) {
        Start-Sleep -Milliseconds 500
        $now = Get-NewestShot
        if ($now -and (-not $before -or $now.FullName -ne $before.FullName -or $now.LastWriteTime -gt $before.LastWriteTime)) {
            Start-Sleep -Milliseconds 300   # let the engine finish writing before deleting
            Remove-Item $now.FullName -Force -ErrorAction SilentlyContinue
            Write-Host ("Bridge alive after {0:N1}s" -f $sw.Elapsed.TotalSeconds)
            exit 0
        }
    }
}
Write-Host "Bridge did not answer within ${TimeoutSec}s"
exit 1
