# ---------------------------------------------------------------------------
# cnn_objdump.ps1 - What the engine really loads on each map.
#
# Opens every map through CNNAgentBridge and runs the engine's own
# "obj linkers" and "obj list class=<X>" there (bridge RAW, which logs the
# output in pieces). A map loads exactly what it and the classes on it
# reference -- packages are loaded lazily, CNN.u included -- so the union over
# all maps is what the mod uses statically. Not seen here: what code loads by
# name at play time (DynamicLoadObject: conversation audio, info portraits,
# HDTP) and the .ogg music, which DXOgg streams from files.
#
# The game must already run with the bridge (cnn_launch_kentie.ps1). For a
# player's view, launch it with a copy of CNN.ini without the developer's
# Revision HD Paths= lines (cnn_launch_kentie.ps1 -Ini <copy>). Kentie's
# log reaches disk late, so the dumps are parsed after the game quits.
#
# Usage:
#   cnn_objdump.ps1                    dump all maps, quit, parse
#   cnn_objdump.ps1 -Maps 06_OpheliaL1 -NoQuit
#   cnn_objdump.ps1 -ParseOnly [-Log <saved log>]
# Writes <OutDir>\objects.tsv (map, class, object, bytes) and linkers.tsv
# (map, package, file); tools/asset_usage.js compares them with the packages.
#
# Written for the asset audit, 2026-10-22 (CNNDocs/Assets_License_Audit.md).
# ---------------------------------------------------------------------------
param(
    [string[]]$Maps = @('CNNentry', '05_MoonIntro', '06_OpheliaDocks', '06_OpheliaL1', '06_OpheliaL2',
                        '06_Conspiracy', '06_Hijacking', '06_Mutiny', '06_Transcend'),
    [string[]]$Classes = @('Texture', 'Sound', 'Mesh', 'Music', 'Class'),
    [string]$Log = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Deus Ex\System\deusex.log'),
    [string]$OutDir = (Join-Path $env:TEMP 'cnn_objdump'),
    [int]$Settle = 4,
    [switch]$NoQuit,
    [switch]$ParseOnly
)

$bridge = Join-Path $PSScriptRoot 'cnn_bridge.ps1'
New-Item -ItemType Directory -Force $OutDir | Out-Null

if (-not $ParseOnly) {
    foreach ($m in $Maps) {
        & $bridge -Timeout 90 "OPEN $m"
        Start-Sleep -Seconds $Settle
        $cmds = @('WHERE', 'RAW obj linkers') + ($Classes | ForEach-Object { "RAW obj list class=$_" })
        & $bridge -Timeout 60 -Quiet @cmds
    }
    if ($NoQuit) { return }
    & $bridge -Quiet 'QUIT'
    for ($i = 0; $i -lt 60 -and (Get-Process DeusEx -ErrorAction SilentlyContinue); $i++) { Start-Sleep 1 }
    Copy-Item $Log (Join-Path $OutDir 'deusex.log') -Force
}

# ---- parse ----------------------------------------------------------------
$fs = [IO.File]::Open($Log, 'Open', 'Read', 'ReadWrite')
$lines = (New-Object IO.StreamReader($fs)).ReadToEnd() -split "`r?`n"
$fs.Close()

$objects = New-Object System.Collections.Generic.List[string]
$linkers = New-Object System.Collections.Generic.List[string]
$map = ''; $query = ''; $buf = $null
foreach ($l in $lines) {
    if ($l -match 'CNN agent: seq=\d+ cmd=OPEN arg=(\S+)') { $map = $Matches[1]; continue }
    if ($l -match 'CNN agent: seq=\d+ cmd=RAW arg=(.*)$') { $query = $Matches[1].Trim(); continue }
    if ($l -match 'CNN raw: begin') { $buf = New-Object Text.StringBuilder; continue }
    if ($l -match '^ScriptLog: CNN raw\|(.*)\|$' -and $buf) { [void]$buf.Append($Matches[1]); continue }
    if ($l -notmatch 'CNN raw: end' -or -not $buf) { continue }
    $s = $buf.ToString(); $buf = $null
    if (-not $map) { continue }
    if ($query -match '^obj linkers') {
        foreach ($x in [regex]::Matches($s, '(?:Linkers:|Lazy=\d+)(.+?) \(Package (\S+?)\)')) {
            $linkers.Add("$map`t$($x.Groups[2].Value)`t$($x.Groups[1].Value)")
        }
    }
    elseif ($query -match '^obj list class=(\w+)') {
        $cls = $Matches[1]
        # entries "%60s %10i %10i" (class + full name, bytes, max) between the header and the per-class
        # totals; a name over 60 characters leaves no space after the previous number
        $a = $s.IndexOf('MaxBytes') + 8
        $b = $s.LastIndexOf('Class  Count')
        if ($a -lt 8 -or $b -lt $a) { continue }
        foreach ($x in [regex]::Matches($s.Substring($a, $b - $a), '([A-Za-z]\w*) (\S+)\s+(\d+)\s+\d+')) {
            $objects.Add("$map`t$($x.Groups[1].Value)`t$($x.Groups[2].Value)`t$($x.Groups[3].Value)")
        }
    }
}
$objects | Set-Content (Join-Path $OutDir 'objects.tsv') -Encoding UTF8
$linkers | Set-Content (Join-Path $OutDir 'linkers.tsv') -Encoding UTF8
$objects | ForEach-Object { ($_ -split "`t")[0] } | Group-Object | ForEach-Object { "{0,-18} {1,6} objects" -f $_.Name, $_.Count }
"-> $OutDir"
