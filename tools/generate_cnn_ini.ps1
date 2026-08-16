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

# ---- Detect native screen resolution (overrides player's old DeusEx.ini values) ----
# Player's DeusEx.ini often has 640x480 from initial install (Kentie/Han launchers
# use a separate INI for actual gameplay), so inheriting it leaves the in-game
# Settings menu defaulting to 640x480 and downgrading on first interaction.
# Prefer WMI (real hardware res, ignores DPI scaling); fall back to Windows.Forms.
$nativeResX = 0; $nativeResY = 0
try {
    $vc = Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop |
          Where-Object { $_.CurrentHorizontalResolution -gt 0 } |
          Select-Object -First 1
    if ($vc) {
        $nativeResX = [int]$vc.CurrentHorizontalResolution
        $nativeResY = [int]$vc.CurrentVerticalResolution
    }
} catch { }
if ($nativeResX -le 0 -or $nativeResY -le 0) {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $nativeResX = $bounds.Width
    $nativeResY = $bounds.Height
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

    # ---- [WinDrv.WindowsClient] section patches: viewport size = native res ----
    if ($line -match '^WindowedViewportX=')   { $result += "WindowedViewportX=$nativeResX";   continue }
    if ($line -match '^WindowedViewportY=')   { $result += "WindowedViewportY=$nativeResY";   continue }
    if ($line -match '^FullscreenViewportX=') { $result += "FullscreenViewportX=$nativeResX"; continue }
    if ($line -match '^FullscreenViewportY=') { $result += "FullscreenViewportY=$nativeResY"; continue }

    # Windows 10/11 expose no 16-bit fullscreen display modes; the vanilla
    # Default.ini asks for 16-bit, which makes the engine fail its mode reset
    # ("Failed resetting mode") regardless of which renderer is selected.
    if ($line -match '^WindowedColorBits=')   { $result += 'WindowedColorBits=32';   continue }
    if ($line -match '^FullscreenColorBits=') { $result += 'FullscreenColorBits=32'; continue }

    # ---- Force D3D9 over any render device that can't work on a modern PC ----
    #      GlideDrv  - 3dfx, DLL not shipped with modern installs
    #      D3DDrv    - the 1999 D3D7 device; dies with "Failed resetting mode"
    #                  (HandleBigChange <- UD3DRenderDevice::Lock) on Win10/11
    #      SoftDrv / MeTaLDrv / SGLDrv - software or dead vendor APIs
    #      A never-configured retail/CD install inherits exactly these from the
    #      game's Default.ini, so replace them inline. "D3DDrv\." deliberately
    #      does not match "D3D9Drv.".
    if ($line -match '(GlideDrv|D3DDrv|SoftDrv|MeTaLDrv|MetalDrv|SGLDrv)\.\w*RenderDevice' -and
        $line -match '^(GameRenderDevice|RenderDevice|WindowedRenderDevice)=') {
        $result += (($line -split '=', 2)[0] + '=D3D9Drv.D3D9RenderDevice')
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

# Detect what renderer ended up in the output (inherited from player or replaced)
$renderer = ($result | Where-Object { $_ -match '^GameRenderDevice=' }) -replace '^GameRenderDevice=', '' | Select-Object -First 1
if ($renderer) {
    Write-Host "    Renderer: $renderer"
}

Write-Host "    Resolution: ${nativeResX}x${nativeResY} (forced to native)"

# ---- Generate CNNUser.ini from User.ini ----
#
# Keybindings are inherited verbatim, with one exception: the console.
# Deus Ex ships Tilde= and T= deliberately blank (see DefUser.ini), so a
# player who never bound a console key gets a CNNUser.ini with no way to
# open one. That blocks every console-driven workflow -- CNNTestEnding,
# EditFlags, "open <map>" -- in a mod that has no other cheat UI. Only
# genuinely unbound keys are filled, so a player's own binding always wins.
if ($SourceUser -ne '.' -and (Test-Path $SourceUser)) {
    $userLines = [System.IO.File]::ReadAllLines($SourceUser)
    $userResult = @()

    $consoleKeys = [ordered]@{ 'Tilde' = 'Type'; 'T' = 'Talk' }
    $filled = @()
    $inInput = $false

    foreach ($line in $userLines) {
        if ($line -match '^\[(.+)\]\s*$') {
            # Leaving [Engine.Input]: add any console key the section never mentioned.
            if ($inInput) {
                foreach ($key in $consoleKeys.Keys) {
                    if ($filled -notcontains $key) {
                        $userResult += "$key=$($consoleKeys[$key])"
                        $filled += $key
                    }
                }
            }
            $inInput = ($matches[1] -eq 'Engine.Input')
            $userResult += $line
            continue
        }

        if ($line -match '^Class=') {
            $userResult += 'Class=CNN.TantalusDenton'
            continue
        }

        if ($inInput -and ($line -match '^(\w+)=(.*)$') -and $consoleKeys.Contains($matches[1])) {
            $key = $matches[1]
            $filled += $key
            if ($matches[2].Trim() -eq '') {
                $userResult += "$key=$($consoleKeys[$key])"
            } else {
                $userResult += $line
            }
            continue
        }

        $userResult += $line
    }

    # [Engine.Input] ran to end of file.
    if ($inInput) {
        foreach ($key in $consoleKeys.Keys) {
            if ($filled -notcontains $key) {
                $userResult += "$key=$($consoleKeys[$key])"
            }
        }
    }

    [System.IO.File]::WriteAllLines($OutputUser, $userResult)
    Write-Host "  Generated CNNUser.ini from player's User.ini"
    Write-Host "    Source:  $SourceUser"
    Write-Host "    Output:  $OutputUser"
    Write-Host "    Player keybindings: inherited (console keys added only if unbound)"
} else {
    Write-Host "  Skipped CNNUser.ini generation (no User.ini found)"
}
