# ---------------------------------------------------------------------------
# cnn_ued.ps1 - Drive the Community Update UnrealEd from outside: open a map,
# Play Level as the CNN player with the bridge alive, close without saving.
#
# The editor's own inis play the level as RF.RFJCDentonMale, so no CNN player
# and no bridge. Play Level passes GameCommandLine to the game, and with it
# INI=CNNPlay.ini USERINI=CNNPlayUser.ini: copies of the editor's inis with the
# CNN player, game and music (the player class comes from the user ini). These
# are set for this run only: -Close puts the inis and Editor.log back as they
# were. Autoplay.dx is the editor's own working copy of the level; the map file
# is never saved.
#
# The map goes on the editor's command line: the title bar will not show it.
# A file dialog would change the editor's current directory, and Play Level
# works relative to it (..\Maps\Autoplay.dx, DeusEx.exe).
#
# With the game up, the bridge takes the -SystemDir and -Ini printed here.
# Usage:
#   cnn_ued.ps1 -Map 06_OpheliaL2 [-Play] [-ExtraPaths 'X:\*.u','X:\*.dx']
#   cnn_ued.ps1 -Play                     (editor already open on a map)
#   cnn_ued.ps1 -Close                    (lists the problems in Editor.log)
# -ExtraPaths adds a mod's own packages and maps to the ini, for this run only.
# ---------------------------------------------------------------------------
param(
    [string]$Map,
    [switch]$Play,
    [switch]$Close,
    [string[]]$ExtraPaths,
    [string]$Root = 'D:\Program Files (x86)\Steam\steamapps\common\Deus Ex',
    [int]$LoadSeconds = 25,
    [int]$Timeout = 90
)

$cu = Join-Path $Root 'Mods\Community Update\System'
$ini = Join-Path $cu 'DeusEx.ini'
$agentIni = Join-Path $cu 'CNNAgent.ini'
$keep = Join-Path $env:TEMP 'cnn_ued_backup'
$kept = 'DeusEx.ini', 'User.ini', 'Editor.log'
$made = 'CNNPlay.ini', 'CNNPlayUser.ini'

function Get-Editor { Get-Process UnrealEd -ErrorAction SilentlyContinue | Select-Object -First 1 }
function Get-Game { Get-Process DeusEx -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$cu*" } | Select-Object -First 1 }

Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices; using System.Text;
public static class UedMenu {
  delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f, IntPtr l);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint p);
  [DllImport("user32.dll")] static extern IntPtr GetMenu(IntPtr h);
  [DllImport("user32.dll")] static extern IntPtr GetSubMenu(IntPtr m, int i);
  [DllImport("user32.dll")] static extern int GetMenuItemCount(IntPtr m);
  [DllImport("user32.dll")] static extern uint GetMenuItemID(IntPtr m, int i);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern int GetMenuString(IntPtr m, uint i, StringBuilder s, int n, uint f);
  [DllImport("user32.dll")] static extern bool PostMessage(IntPtr h, uint msg, IntPtr w, IntPtr l);
  // Posts the command of the first menu item with this caption, in any window of the process.
  public static bool Click(int pid, string caption) {
    bool done = false;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      IntPtr menu = (p == pid) ? GetMenu(h) : IntPtr.Zero;
      if (menu == IntPtr.Zero) return true;
      for (int t = 0; t < GetMenuItemCount(menu); t++) {
        IntPtr sub = GetSubMenu(menu, t);
        for (int i = 0; i < GetMenuItemCount(sub); i++) {
          var s = new StringBuilder(128);
          GetMenuString(sub, (uint)i, s, 128, 0x400);
          if (s.ToString().Replace("&", "").StartsWith(caption, StringComparison.OrdinalIgnoreCase)) {
            done = PostMessage(h, 0x111, (IntPtr)GetMenuItemID(sub, i), IntPtr.Zero);
            return false;
          }
        }
      }
      return true;
    }, IntPtr.Zero);
    return done;
  }
}
'@

function Write-PlayInis {
    $t = Get-Content $ini
    $t = $t -replace '^Class=.*', 'Class=CNN.TantalusDenton' -replace '^DefaultGame=.*', 'DefaultGame=CNN.CNNGameInfo' -replace '^Language=.*', 'Language=int'
    $at = [Array]::IndexOf($t, '[Core.System]')
    $t = $t[0..$at] + 'OggPath=..\..\..\CodenameNebula\Music\Ogg\' + $t[($at + 1)..($t.Count - 1)]
    Set-Content (Join-Path $cu 'CNNPlay.ini') $t -Encoding ASCII
    (Get-Content (Join-Path $cu 'User.ini')) -replace '^Class=.*', 'Class=CNN.TantalusDenton' | Set-Content (Join-Path $cu 'CNNPlayUser.ini') -Encoding ASCII
    (Get-Content $ini) -replace '^GameCommandLine=.*', 'GameCommandLine=-log INI=CNNPlay.ini USERINI=CNNPlayUser.ini' | Set-Content $ini -Encoding ASCII
    & (Join-Path $PSScriptRoot 'cnn_agent_listen.ps1') -Ini $agentIni | Out-Null
}

if ($Close) {
    $game = Get-Game
    if ($game) {
        & (Join-Path $PSScriptRoot 'cnn_bridge.ps1') -SystemDir $cu -Ini $agentIni -Quiet 'QUIT' | Out-Null
        for ($i = 0; $i -lt 30 -and -not $game.HasExited; $i++) { Start-Sleep 1; $game.Refresh() }
    }
    $ed = Get-Editor
    if ($ed) {
        [void][UedMenu]::Click($ed.Id, 'Exit')
        for ($i = 0; $i -lt 10 -and -not $ed.HasExited; $i++) { Start-Sleep 1; $ed.Refresh() }
        if (-not $ed.HasExited) {
            # "save changes?" is answered no, only when the editor really has the focus
            $shell = New-Object -ComObject WScript.Shell
            if ($ed.Responding -and $shell.AppActivate($ed.Id)) {
                Start-Sleep 1; $shell.SendKeys('n')
                for ($i = 0; $i -lt 15 -and -not $ed.HasExited; $i++) { Start-Sleep 1; $ed.Refresh() }
            }
        }
        # it can hang on the way out with its windows already gone; nothing is saved here anyway
        if (-not $ed.HasExited -and -not $ed.Responding) { 'editor hung on exit: stopped'; Stop-Process -Id $ed.Id -Force; Start-Sleep 2 }
        $ed.Refresh()
        if (-not $ed.HasExited) { 'editor still open: nothing restored'; return }
    }
    $log = Get-Content (Join-Path $cu 'Editor.log') -ErrorAction SilentlyContinue
    $log | Where-Object { $_ -match 'MAP LOAD|LaunchURL' }
    $bad = @($log | Where-Object { $_ -match '(?i)warning|critical|failed|can.t find|mismatch' })
    "Editor.log problems: $($bad.Count)"
    $bad | Select-Object -First 20
    if (Test-Path $keep) {
        foreach ($f in $kept) { if (Test-Path "$keep\$f") { Copy-Item "$keep\$f" "$cu\$f" -Force } }
        Remove-Item $keep -Recurse -Force
    }
    foreach ($f in $made) { Remove-Item (Join-Path $cu $f) -ErrorAction SilentlyContinue }
    return
}

$ed = Get-Editor
if ($Map) {
    if ($ed) { 'the editor is already open: -Close first (the map goes on its command line)'; return }
    if (-not (Test-Path $keep)) {
        New-Item -ItemType Directory -Force $keep | Out-Null
        foreach ($f in $kept) { if (Test-Path "$cu\$f") { Copy-Item "$cu\$f" "$keep\" -Force } }
    }
    if ($ExtraPaths) {
        $t = Get-Content $ini
        $at = [Array]::IndexOf($t, '[Core.System]')
        Set-Content $ini ($t[0..$at] + ($ExtraPaths | ForEach-Object { "Paths=$_" }) + $t[($at + 1)..($t.Count - 1)]) -Encoding ASCII
    }
    if ($Play) { Write-PlayInis }
    $mapPath = if ($Map -match ':') { "$Map.dx" } else { "..\..\..\CNNMaps\$Map.dx" }
    $ed = Start-Process (Join-Path $cu 'UnrealEd.exe') -WorkingDirectory $cu -ArgumentList $mapPath -PassThru
    for ($i = 0; $i -lt 30; $i++) { Start-Sleep 2; $ed.Refresh(); if ($ed.MainWindowTitle -match 'UnrealEd' -and $ed.Responding) { break } }
    Start-Sleep $LoadSeconds
    "editor up with $Map"
}

if ($Play) {
    if (-not $ed) { 'no editor open: use -Map'; return }
    if (-not [UedMenu]::Click($ed.Id, 'Play level')) { 'no Play level menu item found'; return }
    $sw = [Diagnostics.Stopwatch]::StartNew()
    do { Start-Sleep 2; $game = Get-Game } while (-not $game -and $sw.Elapsed.TotalSeconds -lt $Timeout)
    if (-not $game) { 'the game did not start'; return }
    "game up, bridge: -SystemDir '$cu' -Ini '$agentIni'"
}
