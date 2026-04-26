param(
    [Parameter(Mandatory=$true)][string]$InputIni,
    [Parameter(Mandatory=$true)][string]$OutputIni,
    [Parameter(Mandatory=$true)][string]$MapName
)

# Generate a per-map test INI from the install's CNN.ini.
# Overrides:
#   LocalMap / Map  = <MapName>.dx     so engine boots straight into the map
#   Resolution      = native screen    avoids menu-logo aspect issues
#   Renderer        = D3D9             skips GlideDrv-not-found warnings if
#                                      the player INI inherited Glide

Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$ResX = $bounds.Width
$ResY = $bounds.Height

(Get-Content -LiteralPath $InputIni) `
    -replace '^LocalMap=.*',          "LocalMap=$MapName.dx" `
    -replace '^Map=.*',               "Map=$MapName.dx" `
    -replace '^WindowedViewportX=.*', "WindowedViewportX=$ResX" `
    -replace '^WindowedViewportY=.*', "WindowedViewportY=$ResY" `
    -replace '^FullscreenViewportX=.*',"FullscreenViewportX=$ResX" `
    -replace '^FullscreenViewportY=.*',"FullscreenViewportY=$ResY" `
    -replace 'GlideDrv\.GlideRenderDevice', 'D3D9Drv.D3D9RenderDevice' `
    | Set-Content -LiteralPath $OutputIni

Write-Host "  Generated $OutputIni (LocalMap=$MapName.dx, ${ResX}x${ResY})"
