# ---------------------------------------------------------------------------
# cnn_shot_to_png.ps1 - Convert a Deus Ex Shot*.bmp into a PNG Claude can view.
#
# The engine's `shot` console command (triggered via CNNAgentRun ... SHOT)
# writes BMP, which Claude's Read tool cannot open directly. Confirmed
# working 2026-09-23.
#
# Usage:
#   cnn_shot_to_png.ps1 -Bmp <path\to\ShotNNNN.bmp> [-Out <path\to\out.png>]
# ---------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$true)][string]$Bmp,
    [string]$Out = ""
)

if (-not (Test-Path $Bmp)) {
    Write-Host "ERROR: $Bmp not found."
    exit 1
}

if ($Out -eq "") {
    $Out = Join-Path $env:TEMP ((Split-Path -Leaf $Bmp) -replace '\.bmp$', '.png')
}

Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile((Resolve-Path $Bmp))
try {
    $img.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
} finally {
    $img.Dispose()
}

Write-Output $Out
