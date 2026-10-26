# make_icon.ps1 -- builds CodenameNebula\cnnico.ico from CNNLauncher\IconArt.cs.
#
# The old icon held only 32x32, so the exe, the shortcuts and the installer
# blurred at 125-200 % scaling. This draws the same emblem at every Windows
# icon size: BMP entries up to 128 px, a PNG entry at 256 px (as Windows
# itself stores them).
#
#   powershell -ExecutionPolicy Bypass -File tools\make_icon.ps1 [-Out <ico>] [-PreviewDir <dir>]

param(
    [string]$Out = (Join-Path $PSScriptRoot '..\CodenameNebula\cnnico.ico'),
    [string]$PreviewDir = ''
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$src = Get-Content -Raw (Join-Path $PSScriptRoot '..\CNNLauncher\IconArt.cs')
Add-Type -TypeDefinition $src -ReferencedAssemblies System.Drawing

$sizes = 16, 20, 24, 32, 40, 48, 64, 128, 256
$entries = @()
foreach ($s in $sizes) {
    $bmp = New-Object System.Drawing.Bitmap $s, $s, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::Transparent)
    # a dark rounded tile, as the old icon was black: on a light desktop the
    # glow alone washes out
    $g.SmoothingMode = 'AntiAlias'
    $r = [math]::Max(2, $s * 0.18); $d = $r * 2; $e = $s - 0.5
    $tile = New-Object System.Drawing.Drawing2D.GraphicsPath
    $tile.AddArc(0, 0, $d, $d, 180, 90); $tile.AddArc($e - $d, 0, $d, $d, 270, 90)
    $tile.AddArc($e - $d, $e - $d, $d, $d, 0, 90); $tile.AddArc(0, $e - $d, $d, $d, 90, 90)
    $tile.CloseFigure()
    $fill = New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.PointF 0, 0), (New-Object System.Drawing.PointF 0, $s), ([System.Drawing.Color]::FromArgb(255, 14, 16, 34)), ([System.Drawing.Color]::FromArgb(255, 4, 4, 12))
    $g.FillPath($fill, $tile)
    $g.SetClip($tile)
    # the emblem's own space is 32 units with its glow reaching the edge
    [CNNLauncher.IconArt]::Draw($g, (New-Object System.Drawing.PointF ($s / 2), ($s / 2)), $s)
    $g.Dispose()
    if ($PreviewDir) {
        New-Item -ItemType Directory -Force $PreviewDir | Out-Null
        $bmp.Save((Join-Path $PreviewDir "icon_$s.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    }

    if ($s -ge 256) {
        $ms = New-Object System.IO.MemoryStream
        $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        $data = $ms.ToArray()
    } else {
        # BITMAPINFOHEADER, bottom-up BGRA rows, then a 1-bit AND mask
        $ms = New-Object System.IO.MemoryStream
        $w = New-Object System.IO.BinaryWriter $ms
        $w.Write([int]40); $w.Write([int]$s); $w.Write([int]($s * 2))
        $w.Write([int16]1); $w.Write([int16]32); $w.Write([int]0)
        $w.Write([int]0); $w.Write([int]0); $w.Write([int]0); $w.Write([int]0); $w.Write([int]0)
        for ($y = $s - 1; $y -ge 0; $y--) {
            for ($x = 0; $x -lt $s; $x++) {
                $c = $bmp.GetPixel($x, $y)
                $w.Write([byte]$c.B); $w.Write([byte]$c.G); $w.Write([byte]$c.R); $w.Write([byte]$c.A)
            }
        }
        $maskRow = [int]([math]::Ceiling($s / 32.0) * 4)
        for ($y = $s - 1; $y -ge 0; $y--) {
            $row = New-Object byte[] $maskRow
            for ($x = 0; $x -lt $s; $x++) {
                if ($bmp.GetPixel($x, $y).A -eq 0) { $row[[int][math]::Floor($x / 8)] = $row[[int][math]::Floor($x / 8)] -bor (0x80 -shr ($x % 8)) }
            }
            $w.Write($row)
        }
        $w.Flush()
        $data = $ms.ToArray()
    }
    $bmp.Dispose()
    $entries += ,@($s, $data)
}

$fs = New-Object System.IO.MemoryStream
$w = New-Object System.IO.BinaryWriter $fs
$w.Write([int16]0); $w.Write([int16]1); $w.Write([int16]$entries.Count)
$offset = 6 + 16 * $entries.Count
foreach ($e in $entries) {
    $s = $e[0]; $len = $e[1].Length
    $w.Write([byte]($s % 256)); $w.Write([byte]($s % 256))
    $w.Write([byte]0); $w.Write([byte]0)
    $w.Write([int16]1); $w.Write([int16]32)
    $w.Write([int]$len); $w.Write([int]$offset)
    $offset += $len
}
foreach ($e in $entries) { $w.Write([byte[]]$e[1]) }
$w.Flush()
[System.IO.File]::WriteAllBytes((Resolve-Path -LiteralPath (Split-Path $Out)).Path + '\' + (Split-Path $Out -Leaf), $fs.ToArray())
Write-Host "wrote $Out ($($fs.Length) bytes, sizes $($sizes -join ', '))"
