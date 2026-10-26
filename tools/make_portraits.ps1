# make_portraits.ps1 -- infolink portraits for the speakers that had none.
#
# Only Janus and Ada had a portrait (AiInfoPortraits); nine other infolink
# speakers showed an empty frame. These follow Janus's look, a HUD
# hologram: a glowing head-and-shoulders outline over a dark screen with
# faint display lines, each speaker in a colour of their own and with one
# feature (cap, helmet, glasses). Drawn at 256 px and reduced to 64, the
# size of the infolink window.
#
# Output: 24-bit BMPs in CNN\Textures\Portraits, imported into CNN.u by
# CNN\Classes\CNNTextures.uc as CNN.Portraits.<Name>; AiHUDInfoLinkDisplay
# falls back to them.
#
#   powershell -ExecutionPolicy Bypass -File tools\make_portraits.ps1 [-PreviewDir <dir>]

param([string]$PreviewDir = '')

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$out = Join-Path $PSScriptRoot '..\CNN\Textures\Portraits'
New-Item -ItemType Directory -Force $out | Out-Null

# name -> colour (R,G,B) and feature
$speakers = [ordered]@{
    Tantalus         = @{ c = 70, 190, 255;  f = 'hair' }
    JCDenton         = @{ c = 90, 230, 120;  f = 'shades' }
    CaptainValiente  = @{ c = 220, 235, 255; f = 'cap' }
    DrMephistopheles = @{ c = 190, 110, 255; f = 'glasses' }
    MikeWong         = @{ c = 255, 160, 60;  f = 'hair' }
    MJ12troop        = @{ c = 255, 70, 60;   f = 'helmet' }
    MassacreWitness  = @{ c = 170, 200, 160; f = 'static' }
}

function Col($c, $a) { [System.Drawing.Color]::FromArgb($a, $c[0], $c[1], $c[2]) }

function Glow($g, $path, $c, $width) {
    for ($i = 4; $i -ge 0; $i--) {
        $a = if ($i -eq 0) { 255 } else { [int](70 / $i) }
        $p = New-Object System.Drawing.Pen (Col $c $a), ($width * (1 + $i * 1.4))
        $p.LineJoin = 'Round'
        $g.DrawPath($p, $path); $p.Dispose()
    }
}

function Draw($name, $c, $feature) {
    $S = 256
    $bmp = New-Object System.Drawing.Bitmap $S, $S, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([System.Drawing.Color]::FromArgb(8, 9, 8))
    $rnd = New-Object System.Random ($name.GetHashCode())

    # the screen behind: dim panels, ticks and text-like dashes
    $dim = New-Object System.Drawing.Pen (Col $c 38), 2
    foreach ($r in @(@(18, 30, 52, 70), @(190, 40, 48, 54), @(196, 150, 44, 60), @(14, 160, 40, 64))) {
        $g.DrawRectangle($dim, $r[0], $r[1], $r[2], $r[3])
        for ($k = 0; $k -lt 4; $k++) {
            $y = $r[1] + 10 + $k * 13
            $g.DrawLine($dim, $r[0] + 6, $y, $r[0] + 6 + $rnd.Next(10, $r[2] - 10), $y)
        }
    }
    $bracket = New-Object System.Drawing.Pen (Col $c 120), 4
    $g.DrawLines($bracket, @((New-Object System.Drawing.Point 6, 40), (New-Object System.Drawing.Point 6, 6), (New-Object System.Drawing.Point 40, 6)))
    $g.DrawLines($bracket, @((New-Object System.Drawing.Point 250, 216), (New-Object System.Drawing.Point 250, 250), (New-Object System.Drawing.Point 216, 250)))

    # head, neck and shoulders as one outline
    $body = New-Object System.Drawing.Drawing2D.GraphicsPath
    $body.AddEllipse(78, 34, 100, 128)
    $sh = New-Object System.Drawing.Drawing2D.GraphicsPath
    $sh.AddLines(@(
        (New-Object System.Drawing.PointF 108, 150), (New-Object System.Drawing.PointF 106, 186),
        (New-Object System.Drawing.PointF 54, 206), (New-Object System.Drawing.PointF 36, 256),
        (New-Object System.Drawing.PointF 220, 256), (New-Object System.Drawing.PointF 202, 206),
        (New-Object System.Drawing.PointF 150, 186), (New-Object System.Drawing.PointF 148, 150)))
    $sh.CloseFigure()

    $fill = New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.Point 0, 30), (New-Object System.Drawing.Point 0, 256), (Col $c 70), (Col $c 18)
    $g.FillPath($fill, $sh); $g.FillPath($fill, $body)
    Glow $g $sh $c 2.2
    Glow $g $body $c 2.6

    # contour lines across the face, as on Janus
    $line = New-Object System.Drawing.Pen (Col $c 60), 1.5
    $g.SetClip($body)
    for ($y = 50; $y -lt 160; $y += 9) { $g.DrawLine($line, 70, $y, 186, $y + 4) }
    $g.ResetClip()

    switch ($feature) {
        'hair' {
            $p = New-Object System.Drawing.Drawing2D.GraphicsPath
            $p.AddArc(80, 32, 96, 70, 190, 160)
            Glow $g $p $c 3
        }
        'cap' {
            $p = New-Object System.Drawing.Drawing2D.GraphicsPath
            $p.AddLines(@((New-Object System.Drawing.PointF 70, 70), (New-Object System.Drawing.PointF 186, 70),
                          (New-Object System.Drawing.PointF 176, 36), (New-Object System.Drawing.PointF 128, 24),
                          (New-Object System.Drawing.PointF 80, 36)))
            $p.CloseFigure()
            $g.FillPath((New-Object System.Drawing.SolidBrush (Col $c 90)), $p)
            Glow $g $p $c 2.4
            $v = New-Object System.Drawing.Drawing2D.GraphicsPath
            $v.AddLine(66, 76, 190, 76)
            Glow $g $v $c 3
        }
        'helmet' {
            $p = New-Object System.Drawing.Drawing2D.GraphicsPath
            $p.AddArc(70, 24, 116, 120, 180, 180)
            $p.AddLine(186, 84, 186, 116); $p.AddLine(186, 116, 70, 116); $p.CloseFigure()
            $g.FillPath((New-Object System.Drawing.SolidBrush (Col $c 70)), $p)
            Glow $g $p $c 2.6
            $visor = New-Object System.Drawing.Drawing2D.GraphicsPath
            $visor.AddRectangle((New-Object System.Drawing.RectangleF 84, 90, 88, 18))
            $g.FillPath((New-Object System.Drawing.SolidBrush (Col $c 200)), $visor)
        }
        'shades' {
            $p = New-Object System.Drawing.Drawing2D.GraphicsPath
            $p.AddRectangle((New-Object System.Drawing.RectangleF 90, 88, 34, 16))
            $p.AddRectangle((New-Object System.Drawing.RectangleF 132, 88, 34, 16))
            $g.FillPath((New-Object System.Drawing.SolidBrush (Col $c 230)), $p)
            $b = New-Object System.Drawing.Drawing2D.GraphicsPath
            $b.AddLine(80, 92, 176, 92)
            Glow $g $b $c 1.6
        }
        'glasses' {
            $p = New-Object System.Drawing.Drawing2D.GraphicsPath
            $p.AddEllipse(92, 86, 30, 22); $p.AddEllipse(134, 86, 30, 22)
            Glow $g $p $c 1.8
            $b = New-Object System.Drawing.Drawing2D.GraphicsPath
            $b.AddLine(122, 96, 134, 96)
            Glow $g $b $c 1.6
        }
        'static' {
            # a broken signal: torn lines and noise
            for ($k = 0; $k -lt 9; $k++) {
                $y = $rnd.Next(20, 240); $h = $rnd.Next(3, 9); $dx = $rnd.Next(-26, 26)
                $src = New-Object System.Drawing.Rectangle 0, $y, $S, $h
                $strip = $bmp.Clone($src, $bmp.PixelFormat)
                $g.DrawImage($strip, $dx, $y); $strip.Dispose()
            }
            for ($k = 0; $k -lt 2600; $k++) {
                $v = $rnd.Next(30, 140)
                $bmp.SetPixel($rnd.Next(0, $S), $rnd.Next(0, $S), [System.Drawing.Color]::FromArgb($v, $v, $v))
            }
        }
    }
    $g.Dispose()

    $small = New-Object System.Drawing.Bitmap 64, 64, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($small)
    $g.InterpolationMode = 'HighQualityBicubic'
    $g.PixelOffsetMode = 'HighQuality'
    $g.DrawImage($bmp, 0, 0, 64, 64)
    $g.Dispose()
    $small.Save((Join-Path $out "$name.bmp"), [System.Drawing.Imaging.ImageFormat]::Bmp)
    if ($PreviewDir) {
        New-Item -ItemType Directory -Force $PreviewDir | Out-Null
        $big = New-Object System.Drawing.Bitmap 256, 256
        $g = [System.Drawing.Graphics]::FromImage($big)
        $g.InterpolationMode = 'NearestNeighbor'; $g.PixelOffsetMode = 'Half'
        $g.DrawImage($small, 0, 0, 256, 256); $g.Dispose()
        $big.Save((Join-Path $PreviewDir "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
        $big.Dispose()
    }
    $small.Dispose(); $bmp.Dispose()
}

foreach ($n in $speakers.Keys) { Draw $n $speakers[$n].c $speakers[$n].f }
Write-Host "wrote $($speakers.Count) portraits to $out"
