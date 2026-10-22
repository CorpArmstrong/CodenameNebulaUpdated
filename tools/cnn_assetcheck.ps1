# ---------------------------------------------------------------------------
# cnn_assetcheck.ps1 - Does every map still find everything it needs?
#
# Opens each map through CNNAgentBridge and runs ASSETCHECK there, which loads
# what the game only loads by name during play: conversation voice, objects
# handed over in conversations, infolink portraits, and the .ogg of every
# music slot (DXOgg opens each file). What a map imports is checked by the
# load itself. Collected from the log, per map:
#   load     engine: Failed to load / Can't find / Failed import ...
#   missing  ASSETCHECK: a portrait or a class that does not load
#   ogg      DXOgg: a file it cannot find, open or decode
#   silent   a conversation line without voice -- many are unvoiced by
#            design, so these only matter compared with a baseline
#
# Run it once on a known-good install, then after removing files with
# -Baseline <first OutDir>: only what is new is a regression.
#
# The game must already run with the bridge (cnn_launch_kentie.ps1).
# Usage:
#   cnn_assetcheck.ps1 -OutDir $env:TEMP\check_before
#   cnn_assetcheck.ps1 -OutDir $env:TEMP\check_after -Baseline $env:TEMP\check_before
#   cnn_assetcheck.ps1 -ParseOnly -OutDir <dir>      (re-read <dir>\deusex.log)
# Exit code 1 when there are new problems against the baseline.
#
# Written for the installer trim, 2026-10-22 (CNNDocs/Installer_Audit.md).
# ---------------------------------------------------------------------------
param(
    [string[]]$Maps = @('CNNentry', '05_MoonIntro', '06_OpheliaDocks', '06_OpheliaL1', '06_OpheliaL2',
                        '06_Conspiracy', '06_Hijacking', '06_Mutiny', '06_Transcend'),
    [string]$OutDir = (Join-Path $env:TEMP 'cnn_assetcheck'),
    [string]$Baseline,
    [string]$Log = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Deus Ex\System\deusex.log'),
    [int]$Settle = 4,
    [switch]$NoQuit,
    [switch]$ParseOnly
)

$bridge = Join-Path $PSScriptRoot 'cnn_bridge.ps1'
New-Item -ItemType Directory -Force $OutDir | Out-Null
$saved = Join-Path $OutDir 'deusex.log'

if (-not $ParseOnly) {
    foreach ($m in $Maps) {
        & $bridge -Timeout 90 "OPEN $m"
        Start-Sleep -Seconds $Settle
        & $bridge -Timeout 120 'ASSETCHECK'
        Start-Sleep -Seconds 2      # DXOgg's own log lines
    }
    if ($NoQuit) { return }
    & $bridge -Quiet 'QUIT'
    for ($i = 0; $i -lt 60 -and (Get-Process DeusEx -ErrorAction SilentlyContinue); $i++) { Start-Sleep 1 }
    Copy-Item $Log $saved -Force
}

# ---- parse ----------------------------------------------------------------
$fs = [IO.File]::Open($saved, 'Open', 'Read', 'ReadWrite')
$lines = (New-Object IO.StreamReader($fs)).ReadToEnd() -split "`r?`n"
$fs.Close()

$problems = New-Object System.Collections.Generic.List[string]
$summary = New-Object System.Collections.Generic.List[string]
$map = '(startup)'
$seen = @()     # maps this run opened; the baseline is compared on these only
foreach ($l in $lines) {
    if ($l -match 'CNN agent: seq=\d+ cmd=OPEN arg=(\S+)') { $map = $Matches[1]; $seen += $map; continue }
    if ($l -match 'CNN raw') { continue }
    $kind = $null; $what = $null
    if ($l -match 'CNN agent: (ASSETCHECK (\S+):.*)') {
        $summary.Add($Matches[1])
        # a map that failed to load leaves the bridge on the previous one
        if ($Matches[2] -ne $map) { $problems.Add("$map`tload`tmap did not load (ASSETCHECK ran on $($Matches[2]))") }
        continue
    }
    if ($l -match 'CNN check: MISSING (.*)') { $kind = 'missing'; $what = $Matches[1] }
    elseif ($l -match 'CNN check: silent (.*)') { $kind = 'silent'; $what = $Matches[1] }
    elseif ($l -match 'DXOgg: (Error.*|File .*|Uhm.*|Eep.*)') { $kind = 'ogg'; $what = $Matches[1] }
    elseif ($l -match "(Failed to load|Can't find|Failed import|Unknown package|Couldn't load|Missing [a-z]).*") {
        $kind = 'load'; $what = $l -replace '^\w+: ', ''
    }
    if ($kind) { $problems.Add("$map`t$kind`t$what") }
}
$problems = @($problems | Sort-Object -Unique)
$problems | Set-Content (Join-Path $OutDir 'problems.tsv') -Encoding UTF8
$summary | Set-Content (Join-Path $OutDir 'summary.txt') -Encoding UTF8

$summary
''
$problems | ForEach-Object { ($_ -split "`t")[1] } | Group-Object | ForEach-Object { '{0,-8} {1}' -f $_.Name, $_.Count }
$problems | Where-Object { ($_ -split "`t")[1] -ne 'silent' } | ForEach-Object { "  $_" }

if ($Baseline) {
    $base = @(Get-Content (Join-Path $Baseline 'problems.tsv') -Encoding UTF8 |
              Where-Object { $seen -contains ($_ -split "`t")[0] })
    $new = @($problems | Where-Object { $base -notcontains $_ })
    # the counts too: fewer voiced lines than before is lost audio even if no key is new
    foreach ($s in Get-Content (Join-Path $Baseline 'summary.txt') -Encoding UTF8) {
        $m = ($s -split ' ')[1].TrimEnd(':')
        $now = $summary | Where-Object { ($_ -split ' ')[1].TrimEnd(':') -eq $m }
        if (($seen -contains $m) -and $now -and ($now -ne $s)) { $new += "$m`tcounts`t$s -> $now" }
    }
    $gone = @($base | Where-Object { $problems -notcontains $_ })
    ''
    "against $Baseline : $($new.Count) new, $($gone.Count) gone"
    $new | ForEach-Object { "  NEW  $_" }
    $gone | ForEach-Object { "  GONE $_" }
    exit [int]($new.Count -gt 0)
}
