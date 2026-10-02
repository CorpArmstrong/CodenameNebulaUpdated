# ---------------------------------------------------------------------------
# find_log.ps1 - Locate and read the game log, wherever the launcher put it.
#
# Why this exists: Kentie/Han's DeusExe uses a "User Documents File Manager"
# and writes deusex.log under <Documents>\Deus Ex\System\ instead of the game
# System\ dir. On this machine Documents is BOTH OneDrive-redirected and
# localised ("Документы"), so the log lands in a path no plain search for
# "Documents\Deus Ex" will ever find. A whole debugging session was lost to
# that. The original 1112fm exe, by contrast, writes <ExeBaseName>.log into
# the game System\ dir. This script checks every candidate and picks the
# newest, so callers never have to care which exe ran.
#
# Usage:
#   find_log.ps1 -SystemDir <dir> [-Pattern <regex>] [-Tail <n>] [-List] [-PathOnly]
# ---------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$true)][string]$SystemDir,
    [string]$Pattern = "",
    [int]$Tail = 40,
    [switch]$List,
    [switch]$PathOnly
)

# Logs written by the toolchain, not by a game run.
$excluded = @('UCC.log', 'Editor.log', 'Detected.log')

function Get-DocumentsPath {
    # Read the real Documents location: honours OneDrive redirection and
    # localised folder names, which $env:USERPROFILE\Documents does not.
    try {
        $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
        $raw = (Get-ItemProperty -Path $key -Name 'Personal' -ErrorAction Stop).Personal
        return [Environment]::ExpandEnvironmentVariables($raw)
    } catch {
        return (Join-Path $env:USERPROFILE 'Documents')
    }
}

$candidateDirs = @($SystemDir)
foreach ($docs in @((Get-DocumentsPath), (Join-Path $env:USERPROFILE 'Documents'))) {
    if ($docs) { $candidateDirs += (Join-Path $docs 'Deus Ex\System') }
}

$logs = @()
foreach ($dir in ($candidateDirs | Select-Object -Unique)) {
    if (Test-Path $dir) {
        $logs += Get-ChildItem -Path (Join-Path $dir '*.log') -ErrorAction SilentlyContinue |
                 Where-Object { $excluded -notcontains $_.Name }
    }
}

if ($logs.Count -eq 0) {
    Write-Host "No game log found. Searched:"
    foreach ($dir in ($candidateDirs | Select-Object -Unique)) { Write-Host "  $dir" }
    Write-Host ""
    Write-Host "Launch with -log (cnn test already does) and play at least once."
    exit 1
}

$logs = $logs | Sort-Object LastWriteTime -Descending

if ($List) {
    Write-Host "Game logs found (newest first):"
    foreach ($l in $logs) {
        "{0,-10} {1}  {2}" -f ("{0:N0}KB" -f ($l.Length / 1KB)), $l.LastWriteTime, $l.FullName
    }
    exit 0
}

$log = $logs[0]

if ($PathOnly) { Write-Output $log.FullName; exit 0 }

Write-Host "Log: $($log.FullName)"
Write-Host "     $($log.Length) bytes, last written $($log.LastWriteTime)"
Write-Host ""

# The original 1112fm exe holds an exclusive lock while running; Kentie's does
# not. Copy first so we can always read, even mid-session.
$temp = Join-Path $env:TEMP ("cnn_log_" + [System.IO.Path]::GetRandomFileName() + ".log")
try {
    Copy-Item -LiteralPath $log.FullName -Destination $temp -ErrorAction Stop
} catch {
    Write-Host "Cannot read the log - the game holds it open. Quit the game and retry."
    exit 1
}

try {
    if ($Pattern -ne "") {
        $hits = Select-String -Path $temp -Pattern $Pattern
        if ($hits) { $hits | ForEach-Object { $_.Line } }
        else { Write-Host "No lines matching /$Pattern/" }
    } else {
        Get-Content $temp -Tail $Tail
    }
} finally {
    Remove-Item $temp -ErrorAction SilentlyContinue
}
