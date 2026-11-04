# ---------------------------------------------------------------------------
# cnn_conedit.ps1 - Do all .con files open in ConEdit? Opens copies, so nothing
# can be saved over the sources, and reports each file: opened, or the message
# ConEdit put up instead.
#
# It proves the file loads. What is inside: tools/con_format.js for the file,
# TEXTDUMP on the bridge for what the game read from it.
#
# A file goes on ConEdit's command line, one process each, so no keys or clipboard
# are involved. ConEdit reads the whole command line as the name: no quotes, and no
# spaces in the path (error 52), so the copies stay under TEMP.
#
# ConEdit keeps its settings in HKCU\Software\VB and VBA Program Settings\ConEdit
# and shows a settings window while Username is empty. The key is filled for
# this run and put back as it was afterwards.
#
# Usage: cnn_conedit.ps1 [-Files Mission04,OpheliaL2] [-Source <folder of .con files>]
# Exit code 1 when a file did not open.
# ---------------------------------------------------------------------------
param(
    [string[]]$Files,
    [string]$ConEdit = 'C:\Program Files (x86)\ConEdit\ConvEdit.exe',
    [string]$Source = (Join-Path $PSScriptRoot '..\CNN\Conversations')
)

$copies = Join-Path $env:TEMP 'cnn_conedit'
$key = 'HKCU:\Software\VB and VBA Program Settings\ConEdit'
$export = Join-Path $env:TEMP 'cnn_conedit_settings.reg'

Add-Type -TypeDefinition @'
using System; using System.Collections.Generic; using System.Runtime.InteropServices; using System.Text;
public static class CeWindows {
  delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f, IntPtr l);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint p);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  public static List<string> Titles(int pid) { var o = new List<string>();
    EnumWindows((h, l) => { uint p; GetWindowThreadProcessId(h, out p);
      if (p == pid && IsWindowVisible(h)) { var s = new StringBuilder(300); GetWindowText(h, s, 300); if (s.Length > 0) o.Add(s.ToString()); }
      return true; }, IntPtr.Zero);
    return o; }
}
'@
[void][CeWindows]::SetProcessDPIAware()

New-Item -ItemType Directory -Force $copies | Out-Null
Copy-Item (Join-Path $Source '*.con') $copies -Force
if (-not $Files) { $Files = Get-ChildItem $copies -Filter '*.con' | ForEach-Object BaseName }

$hadKey = Test-Path $key
if ($hadKey) { reg export 'HKCU\Software\VB and VBA Program Settings\ConEdit' $export /y | Out-Null }
New-Item "$key\Settings" -Force | Out-Null
Set-ItemProperty "$key\Settings" -Name Username -Value 'CNN check'

$failed = 0
try {
    foreach ($f in $Files) {
        $p = Start-Process $ConEdit -WorkingDirectory (Split-Path $ConEdit) -ArgumentList (Join-Path $copies "$f.con") -PassThru
        Start-Sleep 4
        $p.Refresh()
        if ($p.HasExited) { "$f : CONEDIT EXITED ($($p.ExitCode))"; $failed++; continue }
        $titles = [CeWindows]::Titles($p.Id)
        $extra = @($titles | Where-Object { $_ -ne 'ConEdit' -and $_ -notlike 'ConEdit - *' })
        if (($titles -like "ConEdit - *$f.con*") -and -not $extra) { "$f : opened" }
        else { "$f : DID NOT OPEN [$($titles -join ' | ')]"; $failed++ }
        Stop-Process -Id $p.Id -Force   # a copy, with nothing to save
        Start-Sleep 1
    }
} finally {
    if ($p -and -not $p.HasExited) { Stop-Process -Id $p.Id -Force; Start-Sleep 1 }
    Remove-Item $key -Recurse -Force
    if ($hadKey) { reg import $export 2>$null; Remove-Item $export -Force }
    Remove-Item $copies -Recurse -Force
}
exit $(if ($failed) { 1 } else { 0 })
