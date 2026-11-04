# ---------------------------------------------------------------------------
# cnn_edcmd.ps1 - Type commands into the log terminal of a running UnrealEd or
# game, and print what the log added. Needs no keyboard focus and no mouse.
#
# The terminal runs what the editor's own buttons send. A full build:
#   MAP LOAD FILE=X:\Map.dx      MAP IMPORTADD FILE=X:\Part.t3d
#   MAP REBUILD                  (geometry + BSP; lightmaps are lost until:)
#   LIGHT APPLY                  PATHS DEFINE
#   MAP SAVE FILE=X:\Map.dx      MAP EXPORT FILE=X:\Map.t3d
# Others: OBJ LOAD FILE=..\..\..\Textures\CoreTexMetal.utx PACKAGE=CoreTexMetal,
# OBJ LIST CLASS=Brush, GET Engine.Scout CollisionHeight, LEVEL VALIDATE.
#
# In UnrealEd the terminal exists once the Log window was opened: -OpenLog.
# In the game it is the "Deus Ex (Running)" window of a -log run, which also
# shows the log live while DeusEx.log is locked: -Process DeusEx -ReadOnly.
#
# Usage:
#   cnn_edcmd.ps1 -OpenLog 'MAP REBUILD','LIGHT APPLY'
#   cnn_edcmd.ps1 -Process DeusEx -ReadOnly -Tail 40
# Sends wait for the command to finish, so a rebuild blocks here too.
# UnrealEd cuts paths at 79 characters: use `subst` for a short drive.
# ---------------------------------------------------------------------------
param(
    [Parameter(Position=0)][string[]]$Lines,
    [string]$Process = 'UnrealEd',
    [int]$Wait = 500,
    [int]$Tail = 40,
    [switch]$OpenLog,
    [switch]$ReadOnly
)

Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
public static class EdTerm {
  delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr p, EnumProc f, IntPtr l);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint p);
  [DllImport("user32.dll", CharSet=CharSet.Ansi)] static extern int GetClassNameA(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] static extern IntPtr GetMenu(IntPtr h);
  [DllImport("user32.dll")] static extern IntPtr GetSubMenu(IntPtr m, int i);
  [DllImport("user32.dll")] static extern int GetMenuItemCount(IntPtr m);
  [DllImport("user32.dll")] static extern uint GetMenuItemID(IntPtr m, int i);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern int GetMenuString(IntPtr m, uint i, StringBuilder s, int n, uint f);
  [DllImport("user32.dll")] static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", EntryPoint="SendMessageW")] public static extern IntPtr Send(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", EntryPoint="SendMessageW", CharSet=CharSet.Unicode)] static extern IntPtr SendS(IntPtr h, uint m, IntPtr w, StringBuilder l);
  public static IntPtr Find(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => { uint p; GetWindowThreadProcessId(h, out p); if (p != pid) return true;
      EnumChildWindows(h, (k, x) => { var s = new StringBuilder(128); GetClassNameA(k, s, 128);
        if (s.ToString().EndsWith("WEditTerminal")) { found = k; return false; } return true; }, IntPtr.Zero);
      return found == IntPtr.Zero; }, IntPtr.Zero);
    return found; }
  public static void OpenLog(uint pid) {
    EnumWindows((h, l) => { uint p; GetWindowThreadProcessId(h, out p); IntPtr menu = (p == pid) ? GetMenu(h) : IntPtr.Zero;
      if (menu == IntPtr.Zero) return true;
      for (int t = 0; t < GetMenuItemCount(menu); t++) { IntPtr sub = GetSubMenu(menu, t);
        for (int i = 0; i < GetMenuItemCount(sub); i++) { var s = new StringBuilder(128); GetMenuString(sub, (uint)i, s, 128, 0x400);
          if (s.ToString().Replace("&", "") == "Log") { PostMessage(h, 0x111, (IntPtr)GetMenuItemID(sub, i), IntPtr.Zero); return false; } } }
      return true; }, IntPtr.Zero); }
  public static string Get(IntPtr h) { int n = (int)Send(h, 0x0E, IntPtr.Zero, IntPtr.Zero); var s = new StringBuilder(n + 2); SendS(h, 0x0D, (IntPtr)(n + 1), s); return s.ToString(); }
}
'@

$target = Get-Process $Process -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $target) { "$Process is not running"; exit 1 }
if ($OpenLog) { [EdTerm]::OpenLog([uint32]$target.Id); Start-Sleep 1 }
$term = [EdTerm]::Find([uint32]$target.Id)
if ($term -eq [IntPtr]::Zero) { 'no log terminal: use -OpenLog (editor) or a -log run (game)'; exit 1 }

if ($ReadOnly) {
    [EdTerm]::Get($term) -split "`r?`n" | Where-Object { $_ } | Select-Object -Last $Tail
    return
}
foreach ($line in $Lines) {
    foreach ($c in ($line + "`r").ToCharArray()) { [void][EdTerm]::Send($term, 0x102, [IntPtr][int]$c, [IntPtr]::Zero) }
    Start-Sleep -Milliseconds $Wait
    $all = [EdTerm]::Get($term)
    # the terminal trims its buffer, so find the command rather than an old length
    $from = $all.LastIndexOf('>' + $line)
    if ($from -lt 0) { $from = [Math]::Max(0, $all.Length - 6000) }
    "> $line"
    $all.Substring($from) -split "`r?`n" | Select-Object -Skip 1 | Where-Object { $_ -and $_ -ne '>' } | Select-Object -Last $Tail
}
