# ---------------------------------------------------------------------------
# cnn_regression.ps1 - L2 regression run through CNNAgentBridge.
#
# Plays every L2 ending and the risky branches in a running game and prints
# PASS/FAIL per check. Run it before and after a refactor: the results must
# match. Needs the game started with cnn_launch_kentie.ps1 (or -Launch).
#
#   R1  Social Boss, ATTACK -> fight; save/load mid-fight; wheel -> Hijacking;
#       F5 refused during the scene
#   R2  Social Boss, give up -> Mutiny
#   R3  Chinese Trained, Manipulate -> Wong kills Mephistopheles -> Hijacking
#   R4  tube upload; save/load mid-countdown -> Transcend
#   R5  MJ12 countdown survives a load; ArmMagdalene hands over the assault
#       gun; MJ12 arrival -> Conspiracy
#   R6  the cast is protected before the scene; hostages carry real names and
#       their own bodies
#
# Usage: cnn_regression.ps1 [-Launch] [-Only R1,R4]
# Saves go to slots 950-959 and are deleted afterwards.
# ---------------------------------------------------------------------------
param(
    [switch]$Launch,
    [string[]]$Only = @()
)

$tools = $PSScriptRoot
$bridge = Join-Path $tools 'cnn_bridge.ps1'
$snapDir = Join-Path $env:TEMP 'cnn_snaps'
$saveDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Deus Ex\CodenameNebula\Save'
$results = New-Object System.Collections.ArrayList

function Br([string[]]$cmds, [int]$timeout = 20) { & $bridge -Quiet -Timeout $timeout @cmds | Out-Null }

function Snap([string]$name) {
    Br @("SNAP $name")
    $h = @{}
    $file = Join-Path $snapDir "$name.txt"
    if (Test-Path $file) {
        foreach ($l in Get-Content $file) {
            $k = ($l -split '=', 2)[0]
            $h[$k] = if ($l.Contains('=')) { ($l -split '=', 2)[1] } else { '' }
        }
    }
    $h
}

function Check([string]$scenario, [string]$what, [bool]$ok, [string]$detail = '') {
    [void]$results.Add([pscustomobject]@{ Scenario = $scenario; Check = $what; Result = $(if ($ok) { 'PASS' } else { 'FAIL' }); Detail = $detail })
    "  {0} {1}{2}" -f $(if ($ok) { 'PASS' } else { 'FAIL' }), $what, $(if ($detail) { "  ($detail)" } else { '' })
}

function WaitFor([scriptblock]$cond, [int]$seconds, [int]$every = 2) {
    $deadline = (Get-Date).AddSeconds($seconds)
    while ((Get-Date) -lt $deadline) {
        $s = Snap 'wait'
        if (& $cond $s) { return $s }
        Start-Sleep -Seconds $every
    }
    Snap 'wait'
}

function MapIs($s, [string]$map) { ($s['map'] -as [string]) -match [regex]::Escape($map) }
function NotTalking($s) { ($s['player.state'] -as [string]) -notmatch '^Conversation' }

# Fresh L2: an ending map in between makes the next OPEN a real, clean load.
# A level left within the mission is kept in Save\Current and restored on
# return (vanilla behaviour), so the previous scenario's L2 is removed first.
function FreshL2 {
    Br @('OPEN 06_OpheliaDocks') 120
    Remove-Item (Join-Path $saveDir 'Current\06_OpheliaL2.dxs') -ErrorAction SilentlyContinue
    Br @('OPEN 06_OpheliaL2') 120
    [void](WaitFor { param($s) ($s['mapName'] -match '^06_OpheliaL2') -and ($s['l2.init'] -match '^[1-9]') } 60)
    Br @('RAW set cnn.tantalusdenton bCheatsEnabled true', 'RAW god')
}

# The scene starts on approach once the countdown has set it up (Mephistopheles
# beside Wong); one more approach if it did not start.
function StartScene {
    Br @('SETFLAG CanArmMagdalene True')
    [void](WaitFor { param($s) $s['pawn.DrMephistopheles'] -match 'loc=845,-4108' } 20)
    foreach ($try in 1..2) {
        Br @('GOTOVEC 800 -3700 -1300')
        $s = WaitFor { param($s) $s['l2.socialboss'] -match 'started:True' } 20
        if ($s['l2.socialboss'] -match 'started:True') { return $s }
        Br @('GOTOVEC 800 -3300 -1300')
        Start-Sleep -Seconds 2
    }
    $s
}

function SaveLoad([int]$slot) {
    Br @("SAVE $slot regression")
    Start-Sleep -Seconds 3
    Br @("LOAD $slot") 120
    Start-Sleep -Seconds 3
}

function Want([string]$id) { ($Only.Count -eq 0) -or ($Only -contains $id) }

if ($Launch) { & (Join-Path $tools 'cnn_launch_kentie.ps1') | Out-Null }

# --------------------------------------------------------------------- R6
if (Want 'R6') {
    'R6  cast protected, names, bodies'
    FreshL2
    Br @('SETFLAG CanArmMagdalene True')
    Start-Sleep -Seconds 2
    Br @('KILL MikeWong', 'KILL DrMephistopheles', 'KILL CorpArmstrongHostage')
    $s = Snap 'r6'
    Check R6 'Wong survives 1000 damage before the scene' ($s['pawn.MikeWong'] -match 'alive=True') $s['pawn.MikeWong']
    Check R6 'Mephistopheles survives before the scene' ($s['pawn.DrMephistopheles'] -match 'alive=True')
    Check R6 'Armstrong survives before the scene' ($s['pawn.CorpArmstrongHostage'] -match 'alive=True')
    Check R6 'Armstrong shown as Corporal Armstrong' ($s['pawn.CorpArmstrongHostage'] -match 'name=Corporal Armstrong')
    Check R6 'Samantha shown as Samantha Reed' ($s['pawn.SamanthaReedHostage'] -match 'name=Samantha Reed')
    Check R6 'Wong leaves MikeWongCarcass' ($s['pawn.MikeWong'] -match 'carcass=CNN.MikeWongCarcass')
    Check R6 'Mephistopheles leaves MephistophelesCarcass' ($s['pawn.DrMephistopheles'] -match 'carcass=CNN.MephistophelesCarcass')
    Check R6 'Dr. Johnson has no conversations of his own' ($s['pawn.DrJohnsonHostage'] -match 'cons=False')
    Check R6 'Mephistopheles stands next to Wong' ($s['pawn.DrMephistopheles'] -match 'loc=845,-4108')
    Check R6 'L2 has its map name' ($s['mapName'] -match '^06_OpheliaL2')
    Check R6 'Magdalene carries a single coil gun' ($s['pawn.Magdalene'] -match 'items=3')
}

# --------------------------------------------------------------------- R1
if (Want 'R1') {
    'R1  ATTACK -> fight -> save/load -> wheel -> Hijacking'
    FreshL2
    $s = StartScene
    Check R1 'scene starts on approach' ($s['l2.socialboss'] -match 'started:True')
    $quick = Get-Item (Join-Path $saveDir 'QuickSave') -ErrorAction SilentlyContinue
    $quickTime = if ($quick) { $quick.LastWriteTime } else { $null }
    Br @('QSAVE')
    Start-Sleep -Seconds 2
    $quick = Get-Item (Join-Path $saveDir 'QuickSave') -ErrorAction SilentlyContinue
    Check R1 'F5 refused during the scene' ((-not $quick) -or ($quick.LastWriteTime -eq $quickTime))
    Br @('CONRUN 2 2 2')
    $s = WaitFor { param($s) NotTalking $s } 240 3
    Check R1 'scene ends in a fight' ($s['l2.socialboss'] -match 'fight:True') $s['l2.socialboss']
    Check R1 'Wong hostile and mortal' ($s['pawn.MikeWong'] -match 'invincible=False')
    Check R1 'MJ12 timer paused during the scene' ([int](($s['l2.init'] -split 'mj12=')[1] -split ' ')[0] -ge 200) $s['l2.init']
    SaveLoad 950
    $s = Snap 'r1load'
    Check R1 'fight survives a load' ($s['l2.socialboss'] -match 'fight:True') $s['l2.socialboss']
    Check R1 'Wong still mortal after the load' ($s['pawn.MikeWong'] -match 'invincible=False')
    Br @('KILL MikeWong', 'KILL DrMephistopheles')
    Start-Sleep -Seconds 4
    Br @('BODIES')
    Br @('FROB ShipsWheel')
    $s = WaitFor { param($s) MapIs $s '06_Hijacking' } 30
    Check R1 'wheel -> 06_Hijacking' (MapIs $s '06_Hijacking') $s['map']
}

# --------------------------------------------------------------------- R2
if (Want 'R2') {
    'R2  give up -> Mutiny'
    FreshL2
    [void](StartScene)
    Br @('CONRUN 1 2 3')
    $s = WaitFor { param($s) MapIs $s '06_Mutiny' } 300 3
    Check R2 'CAUSE AN APOCALYPSE -> 06_Mutiny' (MapIs $s '06_Mutiny') $s['map']
}

# --------------------------------------------------------------------- R3
if (Want 'R3') {
    'R3  Chinese -> Manipulate -> Wong kills Mephistopheles -> Hijacking'
    FreshL2
    Br @('RAW set AiSkillChinese CurrentLevel 1')
    [void](StartScene)
    Br @('CONRUN 1 1 2 4')
    $s = WaitFor { param($s) NotTalking $s } 300 3
    Check R3 'Wong betrayed Mephistopheles' ($s['l2.flags'] -match 'WongBetrayedMeph') $s['l2.flags']
    Check R3 'Mephistopheles is dead' (-not $s.ContainsKey('pawn.DrMephistopheles'))
    Br @('KILL MikeWong')
    Start-Sleep -Seconds 4
    Br @('FROB ShipsWheel')
    $s = WaitFor { param($s) MapIs $s '06_Hijacking' } 30
    Check R3 'wheel -> 06_Hijacking' (MapIs $s '06_Hijacking') $s['map']
}

# --------------------------------------------------------------------- R4
if (Want 'R4') {
    'R4  tube upload -> save/load mid-countdown -> Transcend'
    FreshL2
    Br @('GOTO TUBE', 'FIRE CNNTubeButton')
    Start-Sleep -Seconds 3
    Br @('CONRUN')
    $s = WaitFor { param($s) NotTalking $s } 180 3
    Check R4 'upload started' ($s['l2.flags'] -match 'TantalusUploadStarted') $s['l2.flags']
    SaveLoad 951
    $s = Snap 'r4load'
    Check R4 'upload state survives a load' ($s['l2.flags'] -match 'TantalusUploadStarted')
    $s = WaitFor { param($s) MapIs $s '06_Transcend' } 120 4
    Check R4 'countdown -> 06_Transcend' (MapIs $s '06_Transcend') $s['map']
}

# --------------------------------------------------------------------- R5
if (Want 'R5') {
    'R5  MJ12 timer save/load, ArmMagdalene, Conspiracy'
    FreshL2
    Br @('SETFLAG CanArmMagdalene True')
    Start-Sleep -Seconds 4
    $a = Snap 'r5a'
    SaveLoad 952
    $b = Snap 'r5b'
    $ta = [int](($a['l2.init'] -split 'mj12=')[1] -split ' ')[0]
    $tb = [int](($b['l2.init'] -split 'mj12=')[1] -split ' ')[0]
    Check R5 'MJ12 timer survives a load' (($tb -gt 0) -and ($tb -le $ta) -and ($ta - $tb -lt 30)) "before $ta, after $tb"
    Check R5 'timer window back after the load' ($b['l2.init'] -match 'window=True')
    Br @('GIVE WeaponAssaultGun', 'TALK Magdalene ArmMagdalene force', 'CONRUN 1')
    [void](WaitFor { param($s) NotTalking $s } 60)
    $inv = & $bridge -Timeout 20 'INV Magdalene' | Out-String
    Check R5 'ArmMagdalene hands over the assault gun' ($inv -match 'WeaponAssaultGun') (($inv -split "`n" | Select-String 'INV').Line)
    Br @('SETFLAG MJ12Arrived True')
    $s = WaitFor { param($s) MapIs $s '06_Conspiracy' } 30
    Check R5 'MJ12 arrival -> 06_Conspiracy' (MapIs $s '06_Conspiracy') $s['map']
}

# ------------------------------------------------------------------ summary
Get-ChildItem $saveDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^Save095\d$' } |
    ForEach-Object { Remove-Item $_.FullName -Recurse -Force }

''
$fail = @($results | Where-Object { $_.Result -eq 'FAIL' })
'{0} checks, {1} failed' -f $results.Count, $fail.Count
$fail | ForEach-Object { '  FAIL {0}: {1} {2}' -f $_.Scenario, $_.Check, $_.Detail }
$report = Join-Path $env:TEMP ('cnn_regression_{0:yyyyMMdd_HHmm}.txt' -f (Get-Date))
$results | Format-Table -AutoSize | Out-String -Width 200 | Set-Content $report -Encoding UTF8
"report: $report"
