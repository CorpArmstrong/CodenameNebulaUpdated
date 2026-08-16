# fix_renderer.ps1
# Repairs an already-installed config that crashes with:
#   Critical Error: Failed resetting mode
#   History: HandleBigChange <- UD3DRenderDevice::Lock <- ...
#
# Cause: the INI selects the legacy 1999 Direct3D device (D3DDrv), Glide, or a
# 16-bit colour depth. Windows 10/11 cannot set those display modes, so both
# Codename Nebula and vanilla Deus Ex crash identically.
#
# This rewrites the render device to D3D9 (or OpenGL if D3D9Drv.dll is absent),
# forces 32-bit colour, and raises a 640x480 viewport to the real desktop mode.
# A .bak copy is written next to each file it changes.
#
# Usage (run from anywhere):
#   powershell -ExecutionPolicy Bypass -File fix_renderer.ps1 -Ini "<path to CNN.ini>"
#   powershell -ExecutionPolicy Bypass -File fix_renderer.ps1        # auto-detect

param(
    [string[]]$Ini,
    # Also force windowed mode. Use this when the monitor shows black but a
    # screen-share or capture shows the game rendering correctly: the frame
    # buffer is fine and only fullscreen presentation is failing (exclusive
    # fullscreen vs. HDR, a second monitor, or a refresh-rate mismatch).
    [switch]$Windowed
)

# ---- Locate the INIs to repair ----
if (-not $Ini) {
    $candidates = @()
    foreach ($root in @(
        "${env:ProgramFiles(x86)}\Steam\steamapps\common\Deus Ex",
        "$env:ProgramFiles\Steam\steamapps\common\Deus Ex",
        "C:\GOG Games\Deus Ex GOTY",
        "$env:ProgramFiles\Deus Ex",
        "${env:ProgramFiles(x86)}\Deus Ex"
    )) {
        if (Test-Path $root) {
            $candidates += "$root\CodenameNebula\System\CNN.ini"
            $candidates += "$root\System\DeusEx.ini"
        }
    }
    $Ini = $candidates | Where-Object { Test-Path $_ }
    if (-not $Ini) {
        Write-Host "Could not auto-detect Deus Ex. Pass the INI path explicitly:"
        Write-Host '  powershell -ExecutionPolicy Bypass -File fix_renderer.ps1 -Ini "D:\...\CodenameNebula\System\CNN.ini"'
        exit 1
    }
}

# ---- Real current display mode, in physical pixels ----
# Prefer WMI: it reports the hardware mode and ignores DPI scaling, so we never
# write a resolution that isn't an actual display mode.
$resX = 0; $resY = 0
try {
    $vc = Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop |
          Where-Object { $_.CurrentHorizontalResolution -gt 0 } | Select-Object -First 1
    if ($vc) { $resX = [int]$vc.CurrentHorizontalResolution; $resY = [int]$vc.CurrentVerticalResolution }
} catch { }
if ($resX -le 0 -or $resY -le 0) { $resX = 1280; $resY = 720 }

# Render devices that are either not shipped or cannot set a mode on Win10/11.
# "D3DDrv\." deliberately does not match "D3D9Drv.".
$badDevice = '(GlideDrv|D3DDrv|SoftDrv|MeTaLDrv|MetalDrv|SGLDrv)\.\w*RenderDevice'

foreach ($file in $Ini) {
    if (-not (Test-Path $file)) { Write-Host "  Skipped (not found): $file"; continue }

    $lines   = [System.IO.File]::ReadAllLines($file)
    $out     = @()
    $changes = @()

    # Pick a renderer that exists next to the exe. CNN.ini lives in
    # <root>\CodenameNebula\System, DeusEx.ini in <root>\System.
    $gameSystem = Split-Path $file -Parent
    if ((Split-Path (Split-Path $gameSystem -Parent) -Leaf) -eq 'CodenameNebula') {
        $gameSystem = Join-Path (Split-Path (Split-Path $gameSystem -Parent) -Parent) 'System'
    }
    $safe = if ((Test-Path (Join-Path $gameSystem 'D3D9Drv.dll')) -or (Test-Path (Join-Path (Split-Path $file -Parent) 'D3D9Drv.dll'))) {
        'D3D9Drv.D3D9RenderDevice'
    } else {
        'OpenGlDrv.OpenGLRenderDevice'
    }

    foreach ($line in $lines) {
        if ($line -match '^(GameRenderDevice|RenderDevice|WindowedRenderDevice)=') {
            $key = ($line -split '=', 2)[0]
            $val = ($line -split '=', 2)[1].Trim()
            if ($val -match $badDevice -or $val -eq '' -or $val -eq 'None') {
                $out += "$key=$safe"
                $changes += "$key : $val -> $safe"
                continue
            }
        }
        if ($line -match '^(Windowed|Fullscreen)ColorBits=') {
            $key = ($line -split '=', 2)[0]
            $val = ($line -split '=', 2)[1].Trim()
            if ($val -ne '32') { $out += "$key=32"; $changes += "$key : $val -> 32"; continue }
        }
        if ($Windowed -and $line -match '^StartupFullscreen=') {
            $val = ($line -split '=', 2)[1].Trim()
            if ($val -ne 'False') {
                $out += 'StartupFullscreen=False'
                $changes += "StartupFullscreen : $val -> False"
                continue
            }
        }
        if ($line -match '^(Windowed|Fullscreen)Viewport([XY])=') {
            $key    = ($line -split '=', 2)[0]
            $val    = [int](($line -split '=', 2)[1].Trim())
            $target = if ($Matches[2] -eq 'X') { $resX } else { $resY }
            $min    = if ($Matches[2] -eq 'X') { 800 } else { 600 }
            if ($val -lt $min) { $out += "$key=$target"; $changes += "$key : $val -> $target"; continue }
        }
        $out += $line
    }

    if ($changes.Count -eq 0) {
        Write-Host "  Already OK: $file"
        continue
    }

    Copy-Item $file "$file.bak" -Force
    [System.IO.File]::WriteAllLines($file, $out)
    Write-Host "  Patched: $file  (backup: $(Split-Path $file -Leaf).bak)"
    $changes | ForEach-Object { Write-Host "      $_" }
}

Write-Host ""
Write-Host "Done. Launch the game again."
if (-not $Windowed) {
    Write-Host "Black screen on the monitor while a screen-share/capture shows the game fine?"
    Write-Host "That is fullscreen presentation, not rendering. Re-run with -Windowed."
}
Write-Host "In Settings > Rendering Device, choose 'Direct3D9 support' or 'OpenGL Support' --"
Write-Host "the plain 'Direct3D support' entry is the dead 1999 device and will black-screen."
