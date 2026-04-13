# generate_cnn_ini.ps1
# Generates CNN.ini from the player's DeusEx.ini, preserving their graphics/audio/input settings
# and patching only CNN-specific values (player class, game mode, asset paths, save path).
# Auto-detects HD textures (NewVision/HDTP) from Revision, GMDX, or standalone installs.
#
# Also generates CNNUser.ini from User.ini with CNN player class.
#
# Usage: powershell -ExecutionPolicy Bypass -File generate_cnn_ini.ps1 -ArgsFile <path>
# ArgsFile format (one per line):
#   Line 1: Path to DeusEx.ini (source)
#   Line 2: Path to output CNN.ini
#   Line 3: Path to output CNNUser.ini
#   Line 4: Path to User.ini (source, or "." to skip CNNUser.ini generation)
#   Line 5: Mod root relative path (e.g. "..\CodenameNebula" or absolute)
#   Line 6: Deus Ex root path (for HD texture detection)

param(
    [string]$ArgsFile
)

$argsLines = Get-Content $ArgsFile
$SourceIni    = $argsLines[0].Trim()
$OutputIni    = $argsLines[1].Trim()
$OutputUser   = $argsLines[2].Trim()
$SourceUser   = $argsLines[3].Trim()
$ModRoot      = $argsLines[4].Trim()
$DeusExRoot   = if ($argsLines.Length -gt 5) { $argsLines[5].Trim() } else { '' }

if (-not (Test-Path $SourceIni)) {
    Write-Host "  ERROR: Source DeusEx.ini not found: $SourceIni"
    exit 1
}

# ---- Auto-detect HD textures (NewVision / HDTP) ----
$hdPaths = @()
$hdSource = ''
$nvPath = ''
$hdtpTexPath = ''
$hdtpSysPath = ''

if ($DeusExRoot -and (Test-Path $DeusExRoot)) {
    # NewVision detection (priority order)
    $nvSearchPaths = @(
        @{ Path = "$DeusExRoot\Revision\NewVision\Textures"; Source = "Revision" },
        @{ Path = "$DeusExRoot\GMDXv9\NewVision\Textures";   Source = "GMDX v9" },
        @{ Path = "$DeusExRoot\GMDX\NewVision\Textures";     Source = "GMDX v10" },
        @{ Path = "$DeusExRoot\New Vision\Textures";          Source = "Standalone" },
        @{ Path = "$DeusExRoot\NewVision\Textures";           Source = "Standalone" }
    )
    foreach ($nv in $nvSearchPaths) {
        if (Test-Path "$($nv.Path)\CoreTexMetal.utx") {
            $nvPath = $nv.Path
            $hdSource = $nv.Source
            break
        }
    }

    # HDTP detection (priority order)
    $hdtpSearchPaths = @(
        "$DeusExRoot\Revision\HDTP",
        "$DeusExRoot\GMDXv9\HDTP",
        "$DeusExRoot\GMDX\HDTP",
        "$DeusExRoot\HDTP"
    )
    foreach ($hp in $hdtpSearchPaths) {
        if (Test-Path "$hp\System\HDTPCharacters.u") {
            $hdtpSysPath = "$hp\System"
            $hdtpTexPath = "$hp\Textures"
            break
        }
    }
    # HDTP in base System/Textures folders
    if (-not $hdtpSysPath -and (Test-Path "$DeusExRoot\System\HDTPCharacters.u")) {
        $hdtpSysPath = "$DeusExRoot\System"
        $hdtpTexPath = "$DeusExRoot\Textures"
    }

    # Build HD paths (inserted BEFORE CNN and base game paths for loading priority)
    if ($nvPath -or $hdtpSysPath) {
        $hdPaths += '; HD Textures (auto-detected)'
    }
    if ($nvPath) {
        # Convert absolute to relative from System dir
        $hdPaths += "Paths=$nvPath\*.utx"
        Write-Host "    NewVision: FOUND [$hdSource] -> $nvPath"
    }
    if ($hdtpTexPath) {
        $hdPaths += "Paths=$hdtpTexPath\*.utx"
        Write-Host "    HDTP Textures: FOUND -> $hdtpTexPath"
    }
    if ($hdtpSysPath) {
        $hdPaths += "Paths=$hdtpSysPath\*.u"
        Write-Host "    HDTP Models: FOUND -> $hdtpSysPath"
    }
    if (-not $nvPath -and -not $hdtpSysPath) {
        Write-Host "    HD textures: not found (optional)"
    }
}

# ---- CNN-specific Paths= lines ----
# Order: HD textures first (priority), then CNN mod paths, then base game paths
$cnnPaths = @()
$cnnPaths += $hdPaths
$cnnPaths += @(
    "Paths=$ModRoot\Maps\*.dx",
    "Paths=$ModRoot\System\*.u",
    "Paths=$ModRoot\Textures\*.utx",
    "Paths=$ModRoot\Music\*.umx",
    "Paths=..\Music\*.umx",
    "Paths=..\Sounds\*.uax",
    "Paths=..\Textures\*.utx",
    "Paths=..\Maps\*.dx",
    "Paths=..\System\*.u"
)

# ---- Read source INI line by line ----
$lines = [System.IO.File]::ReadAllLines($SourceIni)
$result = @()
$inCoreSystem = $false
$pathsInjected = $false
$seenSuppressBlock = $false

for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]

    # Track section transitions
    if ($line -match '^\[(.+)\]') {
        # If leaving [Core.System] and paths not yet injected, inject now
        if ($inCoreSystem -and -not $pathsInjected) {
            $result += $cnnPaths
            $pathsInjected = $true
        }
        $inCoreSystem = ($line -eq '[Core.System]')
        $seenSuppressBlock = $false
    }

    # ---- [URL] section patches ----
    if ($line -match '^Class=')            { $result += 'Class=CNN.TantalusDenton';    continue }
    if ($line -match '^Map=')              { $result += 'Map=Index.dx';                continue }
    if ($line -match '^LocalMap=')         { $result += 'LocalMap=DX.dx';              continue }
    if ($line -match '^MapExt=')           { $result += 'MapExt=dx';                   continue }
    if ($line -match '^SaveExt=')          { $result += 'SaveExt=dxs';                 continue }

    # ---- [Engine.Engine] section patches ----
    if ($line -match '^DefaultGame=')      { $result += 'DefaultGame=CNN.CNNGameInfo';  continue }
    # Replace Render= but NOT GameRenderDevice=, RenderDevice=, WindowedRenderDevice=
    if ($line -match '^Render=' -and $line -notmatch 'RenderDevice') {
        $result += 'Render=RenderExt.RenderExt'
        continue
    }

    # ---- [Core.System] section: replace Paths=, patch SavePath= ----
    if ($inCoreSystem) {
        # Patch save path
        if ($line -match '^SavePath=') {
            $result += "SavePath=$ModRoot\Save"
            continue
        }
        # Skip existing Paths= lines (we inject our own)
        if ($line -match '^Paths=') {
            continue
        }
        # Skip old HD texture comments
        if ($line -match '^; HD Textures') {
            continue
        }
        # Track Suppress= block end — inject paths after last Suppress line
        if ($line -match '^Suppress=') {
            $seenSuppressBlock = $true
            $result += $line
            continue
        }
        # After Suppress block ends, inject CNN paths
        if ($seenSuppressBlock -and -not $pathsInjected) {
            $result += $cnnPaths
            $pathsInjected = $true
            # Fall through to add current line
        }
    }

    # ---- [DeusEx.DeusExGameEngine] patches ----
    if ($line -match '^CacheSizeMegs=') {
        $result += 'CacheSizeMegs=256'
        continue
    }

    # ---- Skip EditPackages= lines (not needed for playing) ----
    if ($line -match '^EditPackages=') {
        continue
    }

    # Keep all other lines as-is (renderer settings, resolution, audio, keybinds, etc.)
    $result += $line
}

# If paths still not injected (edge case: no [Core.System] section), append
if (-not $pathsInjected) {
    $result += '[Core.System]'
    $result += $cnnPaths
}

# ---- Write CNN.ini ----
[System.IO.File]::WriteAllLines($OutputIni, $result)
Write-Host "  Generated CNN.ini from player's DeusEx.ini"
Write-Host "    Source:  $SourceIni"
Write-Host "    Output:  $OutputIni"

# Detect what renderer was inherited
$renderer = ($result | Where-Object { $_ -match '^GameRenderDevice=' }) -replace '^GameRenderDevice=', '' | Select-Object -First 1
if ($renderer) {
    Write-Host "    Renderer: $renderer (inherited from player)"
}

# Detect resolution
$resX = ($result | Where-Object { $_ -match '^FullscreenViewportX=' }) -replace '^FullscreenViewportX=', '' | Select-Object -First 1
$resY = ($result | Where-Object { $_ -match '^FullscreenViewportY=' }) -replace '^FullscreenViewportY=', '' | Select-Object -First 1
if ($resX -and $resY) {
    Write-Host "    Resolution: ${resX}x${resY} (inherited from player)"
}

# ---- Generate CNNUser.ini from User.ini ----
if ($SourceUser -ne '.' -and (Test-Path $SourceUser)) {
    $userLines = [System.IO.File]::ReadAllLines($SourceUser)
    $userResult = @()

    foreach ($line in $userLines) {
        if ($line -match '^Class=') {
            $userResult += 'Class=CNN.TantalusDenton'
        } else {
            $userResult += $line
        }
    }

    [System.IO.File]::WriteAllLines($OutputUser, $userResult)
    Write-Host "  Generated CNNUser.ini from player's User.ini"
    Write-Host "    Source:  $SourceUser"
    Write-Host "    Output:  $OutputUser"
    Write-Host "    Player keybindings: inherited"
} else {
    Write-Host "  Skipped CNNUser.ini generation (no User.ini found)"
}
