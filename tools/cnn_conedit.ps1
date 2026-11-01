# ---------------------------------------------------------------------------
# cnn_conedit.ps1 - Do all .con files open in ConEdit? Opens copies, so nothing
# can be saved over the sources, and reports each file: opened, or the message
# ConEdit put up instead. Takes a screenshot of the last one on request.
#
# It proves the file loads. What is inside: tools/con_dump.js for the file,
# TEXTDUMP on the bridge for what the game read from it.
#
# ConEdit keeps its settings in HKCU\Software\VB and VBA Program Settings\ConEdit
# and shows a settings window while Username is empty. The key is filled for
# this run and put back as it was afterwards.
#
# Usage: cnn_conedit.ps1 [-Files Mission04,OpheliaL2] [-Shot <file.png>]
# Exit code 1 when a file did not open.
# ---------------------------------------------------------------------------
param(
    [string[]]$Files,
    [string]$Shot,
    [string]$ConEdit = 'C:\Program Files (x86)\ConEdit\ConvEdit.exe',
    [string]$Source = (Join-Path $PSScriptRoot '..\CNN\Conversations')
)

$copies = Join-Path $env:TEMP 'cnn_conedit'
$key = 'HKCU:\Software\VB and VBA Program Settings\ConEdit'
$export = Join-Path $env:TEMP 'cnn_conedit_settings.reg'

Add-Type -AssemblyName System.Drawing, System.Windows.Forms
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

$shell = New-Object -ComObject WScript.Shell
$clip = $null; try { $clip = Get-Clipboard -Raw -ErrorAction Stop } catch {}
$failed = 0
$p = Start-Process $ConEdit -WorkingDirectory (Split-Path $ConEdit) -PassThru
Start-Sleep 4
try {
    foreach ($f in $Files) {
        [void]$shell.AppActivate($p.Id); Start-Sleep 1
        $shell.SendKeys('^o'); Start-Sleep 2
        Set-Clipboard -Value (Join-Path $copies "$f.con")
        $shell.SendKeys('^v'); Start-Sleep 1; $shell.SendKeys('{ENTER}'); Start-Sleep 4
        $p.Refresh()
        if ($p.HasExited) { "$f : CONEDIT EXITED ($($p.ExitCode))"; $failed++; break }
        $titles = [CeWindows]::Titles($p.Id)
        $extra = @($titles | Where-Object { $_ -ne 'ConEdit' -and $_ -notlike 'ConEdit - *' })
        if (($titles -like "ConEdit - *\$f.con") -and -not $extra) { "$f : opened" }
        else { "$f : DID NOT OPEN [$($titles -join ' | ')]"; $failed++; $shell.SendKeys('{ENTER}'); Start-Sleep 1; $shell.SendKeys('{ESC}'); Start-Sleep 1 }
    }
    if ($Shot -and -not $p.HasExited) {
        [void]$shell.AppActivate($p.Id); Start-Sleep 1; $shell.SendKeys('% x'); Start-Sleep 2
        $b = [Windows.Forms.Screen]::PrimaryScreen.Bounds
        $bmp = New-Object Drawing.Bitmap $b.Width, ($b.Height - 80)
        $g = [Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen(0, 0, 0, 0, $bmp.Size)
        $bmp.Save($Shot, [Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
    }
} finally {
    if ($clip -ne $null) { Set-Clipboard -Value $clip }
    if (-not $p.HasExited) {
        [void]$p.CloseMainWindow()
        for ($i = 0; $i -lt 8 -and -not $p.HasExited; $i++) { Start-Sleep 1; $p.Refresh() }
        if (-not $p.HasExited) { [void]$shell.AppActivate($p.Id); $shell.SendKeys('n'); for ($i = 0; $i -lt 8 -and -not $p.HasExited; $i++) { Start-Sleep 1; $p.Refresh() } }
        if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force }
    }
    Remove-Item $key -Recurse -Force
    if ($hadKey) { reg import $export 2>$null; Remove-Item $export -Force }
    Remove-Item $copies -Recurse -Force
}
exit $(if ($failed) { 1 } else { 0 })
