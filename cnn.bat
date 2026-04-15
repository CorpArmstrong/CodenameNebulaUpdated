@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: Codename Nebula Build Tool
:: Usage: cnn <command>
::   compile        - Compile UnrealScript packages (CNN.u, CNNText.u)
::   package        - Copy compiled assets into distribution folder
::   installer      - Build Inno Setup installer (.exe)
::   install        - Install the mod to local Deus Ex (for testing)
::   test           - Launch the mod in Deus Ex
::   steam          - Launch via Steam (overlay + play time tracking)
::   reset          - Regenerate CNN.ini/CNNUser.ini from player's config
::   clean          - Remove compiled packages
::   bump [part]    - Increment version (patch/minor/major, default: patch)
::   version        - Show current version
::   all            - compile + package + installer
::   help           - Show this help
:: ============================================================================

:: Determine repo root (directory where this script lives)
set "REPO_ROOT=%~dp0"
set "REPO_ROOT=%REPO_ROOT:~0,-1%"

:: Save current dir and switch to repo root for reliable execution
pushd "%REPO_ROOT%"

:: ---- Auto-detect Deus Ex root ----
:: Priority: 1) env var  2) cnn.local.bat  3) Steam registry  4) GOG registry
if not defined DEUSEX_ROOT if exist "%REPO_ROOT%\cnn.local.bat" call "%REPO_ROOT%\cnn.local.bat"

:: Steam: query registry for install path, then scan library folders for app 6910 (Deus Ex GOTY)
if not defined DEUSEX_ROOT (
    for /f "tokens=2*" %%a in ('reg query "HKCU\SOFTWARE\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM_PATH=%%b"
    if not defined STEAM_PATH for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Valve\Steam" /v InstallPath 2^>nul') do set "STEAM_PATH=%%b"
    if not defined STEAM_PATH for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v InstallPath 2^>nul') do set "STEAM_PATH=%%b"
)
:: Replace forward slashes from registry (SteamPath uses forward slashes)
if defined STEAM_PATH set "STEAM_PATH=!STEAM_PATH:/=\!"
:: Parse libraryfolders.vdf to find all Steam library paths
if defined STEAM_PATH if not defined DEUSEX_ROOT (
    for /f "usebackq tokens=*" %%L in ("!STEAM_PATH!\steamapps\libraryfolders.vdf") do (
        set "VDF_LINE=%%L"
        if not defined DEUSEX_ROOT (
            echo !VDF_LINE! | findstr /c:"\"path\"" >nul 2>&1
            if not errorlevel 1 (
                for /f "tokens=2 delims=	" %%v in ("!VDF_LINE!") do (
                    set "LIB_PATH=%%~v"
                    set "LIB_PATH=!LIB_PATH:\\=\!"
                    if exist "!LIB_PATH!\steamapps\common\Deus Ex\System\ucc.exe" set "DEUSEX_ROOT=!LIB_PATH!\steamapps\common\Deus Ex"
                )
            )
        )
    )
)

:: GOG: query registry for Deus Ex GOTY (app ID 1207658924)
if not defined DEUSEX_ROOT (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\GOG.com\Games\1207658924" /v path 2^>nul') do set "DEUSEX_ROOT=%%b"
)
if not defined DEUSEX_ROOT (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\GOG.com\Games\1207658924" /v path 2^>nul') do set "DEUSEX_ROOT=%%b"
)

:: CD/manual install fallback: search common Unreal/Deus Ex registry keys
if not defined DEUSEX_ROOT (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Unreal Technology\Installed Apps\Deus Ex" /v Folder 2^>nul') do set "DEUSEX_ROOT=%%b"
)
if not defined DEUSEX_ROOT (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Unreal Technology\Installed Apps\Deus Ex" /v Folder 2^>nul') do set "DEUSEX_ROOT=%%b"
)

:: Last resort: ask the user and save for future runs
if not defined DEUSEX_ROOT (
    echo Deus Ex installation not found automatically.
    echo.
    echo Checked: Steam registry, GOG registry, CD registry, cnn.local.bat
    echo.
    set /p "DEUSEX_ROOT=Enter path to Deus Ex root folder: "
    if defined DEUSEX_ROOT (
        if not exist "!DEUSEX_ROOT!\System\DeusEx.exe" (
            echo ERROR: DeusEx.exe not found at "!DEUSEX_ROOT!\System\"
            echo Please check the path and try again.
            set "DEUSEX_ROOT="
            goto :eof
        )
        echo @echo off> "%REPO_ROOT%\cnn.local.bat"
        echo set "DEUSEX_ROOT=!DEUSEX_ROOT!">> "%REPO_ROOT%\cnn.local.bat"
        echo.
        echo Saved to cnn.local.bat. You won't be asked again.
    ) else (
        goto :eof
    )
)
:: Strip trailing backslash if present
if "!DEUSEX_ROOT:~-1!"=="\" set "DEUSEX_ROOT=!DEUSEX_ROOT:~0,-1!"

:: ---- Auto-detect Inno Setup via registry ----
if not defined INNO_SETUP (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1" /v InstallLocation 2^>nul') do set "INNO_SETUP=%%b"
)
if not defined INNO_SETUP (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1" /v InstallLocation 2^>nul') do set "INNO_SETUP=%%b"
)
:: Strip trailing backslash if present
if defined INNO_SETUP if "!INNO_SETUP:~-1!"=="\" set "INNO_SETUP=!INNO_SETUP:~0,-1!"

:: ---- Read version from version.txt ----
set "VERSION_FILE=%REPO_ROOT%\version.txt"
if exist "%VERSION_FILE%" (
    set /p CNN_VERSION=<"%VERSION_FILE%"
) else (
    set "CNN_VERSION=0.0.0"
)
:: Parse version into major.minor.patch
for /f "tokens=1,2,3 delims=." %%a in ("%CNN_VERSION%") do (
    set "VER_MAJOR=%%a"
    set "VER_MINOR=%%b"
    set "VER_PATCH=%%c"
)

:: Paths derived from roots
set "SYSTEM_DIR=%DEUSEX_ROOT%\System"
set "DIST_DIR=%REPO_ROOT%\CodenameNebula"
set "BUILD_DIR=%REPO_ROOT%\Build"
set "CU_SYSTEM=%DEUSEX_ROOT%\Mods\Community Update\System"

:: Parse command
if "%~1"=="" goto :help
if /i "%~1"=="setup" goto :setup
if /i "%~1"=="compile" goto :compile
if /i "%~1"=="package" goto :package
if /i "%~1"=="installer" goto :installer
if /i "%~1"=="install" goto :install
if /i "%~1"=="test" goto :test
if /i "%~1"=="steam" goto :steam
if /i "%~1"=="reset" goto :reset
if /i "%~1"=="clean" goto :clean
if /i "%~1"=="bump" goto :bump
if /i "%~1"=="hd" goto :hd
if /i "%~1"=="renderer" goto :renderer
if /i "%~1"=="version" goto :version
if /i "%~1"=="all" goto :all
if /i "%~1"=="help" goto :help
echo Unknown command: %~1
goto :help

:: ============================================================================
:: SETUP - Configure the development environment
:: ============================================================================
:setup
echo.
echo ========================================
echo  SETUP - Codename Nebula Dev Environment
echo ========================================
echo  Repo:     %REPO_ROOT%
echo  Deus Ex:  %DEUSEX_ROOT%
echo ========================================
echo.

:: Create junctions
echo [1/4] Creating directory junctions...
set "JUNCTIONS_OK=1"
for %%j in (CodenameNebulaUpdated CNN CNNText CNNMaps) do (
    if "%%j"=="CodenameNebulaUpdated" set "JUNCTION_SRC=%REPO_ROOT%"
    if "%%j"=="CNN" set "JUNCTION_SRC=%REPO_ROOT%\CNN"
    if "%%j"=="CNNText" set "JUNCTION_SRC=%REPO_ROOT%\CNNText"
    if "%%j"=="CNNMaps" set "JUNCTION_SRC=%REPO_ROOT%\Maps"
    if exist "%DEUSEX_ROOT%\%%j" (
        echo   %%j already exists, skipping.
    ) else (
        mklink /J "%DEUSEX_ROOT%\%%j" "!JUNCTION_SRC!" >nul 2>&1
        if errorlevel 1 (
            echo   ERROR: Failed to create junction %%j
            set "JUNCTIONS_OK=0"
        ) else (
            echo   Created %%j
        )
    )
)
if "%JUNCTIONS_OK%"=="0" echo   WARNING: Some junctions failed. You may need to run as administrator.

:: Copy runtime DLLs and dependency packages
echo.
echo [2/4] Copying runtime dependencies to System...
for %%f in (DXOgg.dll DXOgg.u GaussGun.u PFAD.u DXRVNewVehicles.u) do (
    if exist "%REPO_ROOT%\System\%%f" copy /y "%REPO_ROOT%\System\%%f" "%SYSTEM_DIR%\" >nul && echo   %%f
)
if exist "%REPO_ROOT%\CNN\System\RenderExt.dll" copy /y "%REPO_ROOT%\CNN\System\RenderExt.dll" "%SYSTEM_DIR%\" >nul && echo   RenderExt.dll

:: Configure DeusEx.ini
echo.
echo [3/4] Configuring DeusEx.ini...
set "INI_FILE=%SYSTEM_DIR%\DeusEx.ini"
if not exist "%INI_FILE%" echo   ERROR: DeusEx.ini not found && goto :setup_cu

:: Check if CNN paths already added
findstr /c:"CodenameNebulaUpdated" "%INI_FILE%" >nul 2>&1
if not errorlevel 1 (
    echo   CNN paths already configured, skipping.
) else (
    echo   Adding CNN paths...
    :: Use PowerShell for reliable INI editing (handles special characters)
    powershell -Command ^
        "$ini = Get-Content '%INI_FILE%' -Raw;" ^
        "$ini = $ini -replace '(Paths=\.\.\\Music\\\*\.umx)', \"`$1`r`nPaths=..\CodenameNebulaUpdated\System\*.u`r`nPaths=..\CodenameNebulaUpdated\Maps\*.dx`r`nPaths=..\CodenameNebulaUpdated\Textures\*.utx`r`nPaths=..\CodenameNebulaUpdated\CNN\Sounds\*.uax`r`nPaths=..\CodenameNebulaUpdated\Music\*.umx\";" ^
        "$ini = $ini -replace '(EditPackages=DeusEx)\r?\n', \"`$1`r`nEditPackages=GaussGun`r`nEditPackages=CNN`r`nEditPackages=CNNText`r`n\";" ^
        "$ini = $ini -replace 'CacheSizeMegs=\d+', 'CacheSizeMegs=256';" ^
        "Set-Content '%INI_FILE%' $ini -NoNewline" 2>nul
    if errorlevel 1 (
        echo   WARNING: Auto-config failed. Please edit DeusEx.ini manually per SetupCNN.md.
    ) else (
        echo   Done.
    )
)

:setup_cu
:: Configure Community Update editor if present
echo.
echo [4/4] Configuring Community Update editor...
if not exist "%CU_SYSTEM%\UnrealEd.exe" (
    echo   Community Update not installed, skipping.
    echo   Optional: install from https://www.moddb.com/mods/deus-ex-community-update
    goto :setup_done
)

:: Copy packages to CU
for %%f in (CNN.u CNNText.u CNNAudioCNN.u CNNAudioChapter05.u CNNAudioChapter06.u GaussGun.u DXOgg.u DXOgg.dll) do (
    if exist "%REPO_ROOT%\System\%%f" copy /y "%REPO_ROOT%\System\%%f" "%CU_SYSTEM%\" >nul
    if exist "%SYSTEM_DIR%\%%f" copy /y "%SYSTEM_DIR%\%%f" "%CU_SYSTEM%\" >nul
)
echo   Packages deployed.

:: Create DeusEx.exe symlink for Play Level
if not exist "%CU_SYSTEM%\DeusEx.exe" (
    if exist "%CU_SYSTEM%\Deus Ex Community Update.exe" (
        copy /y "%CU_SYSTEM%\Deus Ex Community Update.exe" "%CU_SYSTEM%\DeusEx.exe" >nul
        echo   Created DeusEx.exe for Play Level.
    )
)

:: Add CNN paths to CU ini
set "CU_INI=%CU_SYSTEM%\DeusEx.ini"
findstr /c:"CodenameNebulaUpdated" "%CU_INI%" >nul 2>&1
if not errorlevel 1 (
    echo   CNN paths already configured in CU.
) else (
    echo   Adding CNN paths to Community Update ini...
    powershell -Command ^
        "$ini = Get-Content '%CU_INI%' -Raw;" ^
        "$ini = $ini -replace '(Paths=\.\.\\\.\.\\\.\.\\Music\\\*\.umx)', \"`$1`r`nPaths=..\..\..\CodenameNebulaUpdated\System\*.u`r`nPaths=..\..\..\CodenameNebulaUpdated\Maps\*.dx`r`nPaths=..\..\..\CodenameNebulaUpdated\Textures\*.utx`r`nPaths=..\..\..\CodenameNebulaUpdated\CNN\Sounds\*.uax`r`nPaths=..\..\..\CodenameNebulaUpdated\Music\*.umx`r`nPaths=..\..\..\CNNMaps\*.dx\";" ^
        "$ini = $ini -replace '(EditPackages=MoreTriggers)', \"`$1`r`nEditPackages=GaussGun`r`nEditPackages=CNN`r`nEditPackages=CNNText\";" ^
        "Set-Content '%CU_INI%' $ini -NoNewline" 2>nul
    if errorlevel 1 (
        echo   WARNING: Auto-config failed. Please edit CU DeusEx.ini manually per SetupCNN.md.
    ) else (
        echo   Done.
    )
)

:setup_done
echo.
echo ========================================
echo  SETUP COMPLETE
echo ========================================
echo.
echo Next steps:
echo   1. Install Deus Ex SDK v1112fm (run Setup.exe, NOT just extract)
echo      Download: https://www.moddb.com/games/deus-ex/downloads/sdk-v1112fm
echo   2. Run: cnn compile
echo   3. Run: cnn install
echo   4. Run: cnn test
echo.
goto :eof

:: ============================================================================
:: COMPILE - Run ucc make to compile UnrealScript
:: ============================================================================
:compile
echo.
echo ========================================
echo  COMPILE
echo ========================================
echo  Repo:     %REPO_ROOT%
echo  Deus Ex:  %DEUSEX_ROOT%
echo ========================================
echo.

:: Verify junctions exist
if not exist "%DEUSEX_ROOT%\CNN\Classes" echo ERROR: Junction CNN not found. Run: mklink /J "%DEUSEX_ROOT%\CNN" "%REPO_ROOT%\CNN" && goto :eof
if not exist "%DEUSEX_ROOT%\CNNText\Classes" echo ERROR: Junction CNNText not found. Run: mklink /J "%DEUSEX_ROOT%\CNNText" "%REPO_ROOT%\CNNText" && goto :eof

:: Remove old compiled packages so ucc recompiles from source
echo Cleaning old packages...
set "CNN_PACKAGES=CNN.u CNNText.u CNNTextText.u CNNAudioCNN.u CNNAudioChapter05.u CNNAudioChapter06.u"
for %%f in (%CNN_PACKAGES%) do (
    if exist "%SYSTEM_DIR%\%%f" del "%SYSTEM_DIR%\%%f"
    if exist "%REPO_ROOT%\System\%%f" del "%REPO_ROOT%\System\%%f"
    if exist "%CU_SYSTEM%\%%f" del "%CU_SYSTEM%\%%f" 2>nul
)

echo Compiling...
cd /d "%SYSTEM_DIR%"
"%SYSTEM_DIR%\ucc.exe" make
if errorlevel 1 echo. && echo COMPILE FAILED && goto :eof

echo.
echo Copying compiled packages to repo...
for %%f in (%CNN_PACKAGES%) do (
    if exist "%SYSTEM_DIR%\%%f" copy /y "%SYSTEM_DIR%\%%f" "%REPO_ROOT%\System\" >nul && echo   %%f
)

:: Deploy to Community Update editor if present
if exist "%CU_SYSTEM%\UnrealEd.exe" (
    echo.
    echo Deploying to Community Update editor...
    for %%f in (%CNN_PACKAGES%) do (
        if exist "%SYSTEM_DIR%\%%f" copy /y "%SYSTEM_DIR%\%%f" "%CU_SYSTEM%\" >nul
    )
    for %%f in (GaussGun.u DXOgg.u DXOgg.dll) do (
        if exist "%SYSTEM_DIR%\%%f" copy /y "%SYSTEM_DIR%\%%f" "%CU_SYSTEM%\" >nul
    )
    echo   Done.
)

echo.
echo COMPILE SUCCEEDED
cmd /c "exit /b 0"
goto :eof

:: ============================================================================
:: PACKAGE - Copy compiled assets into distribution folder
:: ============================================================================
:package
echo.
echo ========================================
echo  PACKAGE
echo ========================================
echo.

:: Verify CNN.u exists
if not exist "%REPO_ROOT%\System\CNN.u" (
    echo ERROR: CNN.u not found. Run "cnn compile" first.
    goto :eof
)

:: Clean distribution folder
echo Cleaning distribution folder...
if exist "%DIST_DIR%\Maps\*.dx" del /q "%DIST_DIR%\Maps\*.dx"
if exist "%DIST_DIR%\Music\*.*" del /q "%DIST_DIR%\Music\*.*"
if exist "%DIST_DIR%\Music\Ogg\*.*" del /q "%DIST_DIR%\Music\Ogg\*.*"
if exist "%DIST_DIR%\Textures\*.*" del /q "%DIST_DIR%\Textures\*.*"
if exist "%DIST_DIR%\System\*.*" del /q "%DIST_DIR%\System\*.*"

:: Ensure directories exist
if not exist "%DIST_DIR%\Maps" mkdir "%DIST_DIR%\Maps"
if not exist "%DIST_DIR%\Music" mkdir "%DIST_DIR%\Music"
if not exist "%DIST_DIR%\Music\Ogg" mkdir "%DIST_DIR%\Music\Ogg"
if not exist "%DIST_DIR%\Textures" mkdir "%DIST_DIR%\Textures"
if not exist "%DIST_DIR%\System" mkdir "%DIST_DIR%\System"

:: Package Maps
echo Packaging Maps...
for %%f in (CNNentry.dx 05_MoonIntro.dx 06_OpheliaDocks.dx 06_OpheliaL1.dx 06_OpheliaL2.dx 06_OpheliaL2_QuestSystem.dx 06_Conspiracy.dx 06_Hijacking.dx 06_Mutiny.dx 06_Transcend.dx) do (
    if exist "%REPO_ROOT%\Maps\%%f" (
        copy /y "%REPO_ROOT%\Maps\%%f" "%DIST_DIR%\Maps\" >nul
        echo   %%f
    )
)
:: Create DX.dx entry map
if exist "%DIST_DIR%\Maps\CNNentry.dx" (
    copy /y "%DIST_DIR%\Maps\CNNentry.dx" "%DIST_DIR%\Maps\DX.dx" >nul
)

:: Package Music
echo Packaging Music...
if exist "%REPO_ROOT%\Music\Terrified.umx" copy /y "%REPO_ROOT%\Music\Terrified.umx" "%DIST_DIR%\Music\" >nul
for %%f in ("%REPO_ROOT%\Music\Ogg\*.ogg") do (
    copy /y "%%f" "%DIST_DIR%\Music\Ogg\" >nul
    echo   %%~nxf
)

:: Package Textures (copy all .utx — avoids missing-texture bugs from a hardcoded list)
echo Packaging Textures...
for %%f in ("%REPO_ROOT%\Textures\*.utx") do (
    copy /y "%%f" "%DIST_DIR%\Textures\" >nul
    echo   %%~nxf
)

:: Package System files
echo Packaging System...
for %%f in (CNN.u CNNText.u CNNAudioCNN.u CNNAudioChapter05.u CNNAudioChapter06.u PFAD.u GaussGun.u DXRVNewVehicles.u DXOgg.u DXOgg.dll D3D9Drv.dll CNN.ini CNNUser.ini) do (
    if exist "%REPO_ROOT%\System\%%f" (
        copy /y "%REPO_ROOT%\System\%%f" "%DIST_DIR%\System\" >nul
        echo   %%f
    )
)

:: Package renderer and editor fix files
for %%f in (D3D9Drv.int RenderExt.dll RenderExt.int) do (
    if exist "%REPO_ROOT%\System\%%f" (
        copy /y "%REPO_ROOT%\System\%%f" "%DIST_DIR%\System\" >nul
        echo   %%f
    )
)

:: Create PlayCodenameNebula.bat launcher
:: Uses DeusEx.exe directly with INI= params (same as GMDX/TNM)
:: Preserves Steam overlay on Steam installs, works on GOG and vanilla too
echo Creating launcher bat...
> "%DIST_DIR%\PlayCodenameNebula.bat" (
    echo @echo off
    echo cd /d "%%~dp0..\System"
    echo :: Launch CNN using DeusEx.exe with custom INI files
    echo :: Steam overlay and play time tracking work because we use the original exe
    echo if exist "%%~dp0..\System\DeusEx.exe" ^(
    echo     "%%~dp0..\System\DeusEx.exe" INI="%%~dp0System\CNN.ini" USERINI="%%~dp0System\CNNUser.ini"
    echo ^) else ^(
    echo     echo ERROR: DeusEx.exe not found. Please verify your Deus Ex installation.
    echo     pause
    echo ^)
)
echo   PlayCodenameNebula.bat

:: Copy Steam launcher and helper script
if exist "%REPO_ROOT%\CodenameNebula\PlayCNNSteam.bat" (
    copy /y "%REPO_ROOT%\CodenameNebula\PlayCNNSteam.bat" "%DIST_DIR%\" >nul
    echo   PlayCNNSteam.bat
)
if not exist "%DIST_DIR%\tools" mkdir "%DIST_DIR%\tools"
if exist "%REPO_ROOT%\tools\steam_launch.ps1" (
    copy /y "%REPO_ROOT%\tools\steam_launch.ps1" "%DIST_DIR%\tools\" >nul
    echo   tools\steam_launch.ps1
)

:: Build CNNInstallUtil (try MSBuild first, then dotnet CLI)
set "INSTALLUTIL_BUILT=0"
where msbuild >nul 2>&1
if not errorlevel 1 (
    echo Building CNNInstallUtil via MSBuild...
    msbuild "%REPO_ROOT%\CNNInstallUtil\CNNInstallUtil.sln" /p:Configuration=Release /v:minimal
    if exist "%REPO_ROOT%\CNNInstallUtil\CNNInstallUtil\bin\Release\CNNInstallUtil.exe" (
        copy /y "%REPO_ROOT%\CNNInstallUtil\CNNInstallUtil\bin\Release\CNNInstallUtil.exe" "%DIST_DIR%\" >nul
        echo   CNNInstallUtil.exe
        set "INSTALLUTIL_BUILT=1"
    )
)
if "!INSTALLUTIL_BUILT!"=="0" (
    where dotnet >nul 2>&1
    if not errorlevel 1 (
        echo Building CNNInstallUtil via dotnet publish...
        dotnet publish "%REPO_ROOT%\CNNInstallUtil\CNNInstallUtil\CNNInstallUtil.csproj" -c Release -r win-x86 --self-contained true -o "%REPO_ROOT%\CNNInstallUtil\publish" >nul 2>&1
        if exist "%REPO_ROOT%\CNNInstallUtil\publish\CNNInstallUtil.exe" (
            copy /y "%REPO_ROOT%\CNNInstallUtil\publish\CNNInstallUtil.exe" "%DIST_DIR%\" >nul
            echo   CNNInstallUtil.exe
            set "INSTALLUTIL_BUILT=1"
        )
    )
)
if "!INSTALLUTIL_BUILT!"=="0" (
    echo WARNING: Neither MSBuild nor dotnet found, skipping CNNInstallUtil build.
    if exist "%DIST_DIR%\CNNInstallUtil.exe" echo   Using existing CNNInstallUtil.exe
)

echo.
echo PACKAGE SUCCEEDED
echo Output: %DIST_DIR%
cmd /c "exit /b 0"
goto :eof

:: ============================================================================
:: INSTALLER - Build Inno Setup installer
:: ============================================================================
:installer
echo.
echo ========================================
echo  INSTALLER
echo ========================================
echo.

if not defined INNO_SETUP (
    echo ERROR: Inno Setup not found.
    echo Install from: https://jrsoftware.org/isdl.php
    echo Or set INNO_SETUP environment variable to the install directory.
    goto :eof
)

:: Verify distribution folder has content
if not exist "%DIST_DIR%\System\CNN.u" (
    echo ERROR: Distribution folder not packaged. Run "cnn package" first.
    goto :eof
)

:: Create build output directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

:: Generate the .iss script with correct paths
echo Generating installer script...
set "ISS_FILE=%BUILD_DIR%\CNNSetup.generated.iss"

> "%ISS_FILE%" (
    echo #define MyAppName "Codename Nebula"
    echo #define MyAppVersion "%CNN_VERSION%"
    echo #define MyAppPublisher "ApostleMod"
    echo #define MyAppURL "https://apocalypseinside.heraldic.cloud/"
    echo.
    echo [Setup]
    echo AppId={{C4AE68BE-8529-47A6-8659-4CC0EF7311CA}
    echo AppName={#MyAppName}
    echo AppVersion={#MyAppVersion}
    echo AppPublisher={#MyAppPublisher}
    echo AppPublisherURL={#MyAppURL}
    echo AppSupportURL={#MyAppURL}
    echo AppUpdatesURL={#MyAppURL}
    echo DefaultDirName={sd}\Games\DeusEx\CodenameNebula
    echo DefaultGroupName={#MyAppName}
    echo LicenseFile=%REPO_ROOT%\CNNInstaller\InfoLicense.txt
    echo InfoBeforeFile=%REPO_ROOT%\CNNInstaller\InfoBeforeInstall.txt
    echo OutputDir=%BUILD_DIR%
    echo OutputBaseFilename=CodenameNebula_v%CNN_VERSION%
    echo SetupIconFile=%DIST_DIR%\cnnico.ico
    echo WizardImageFile=%REPO_ROOT%\CNNInstaller\WizardImage.bmp
    echo WizardSmallImageFile=%REPO_ROOT%\CNNInstaller\WizardSmallImage.bmp
    echo Compression=lzma
    echo SolidCompression=yes
    echo.
    echo [Languages]
    echo Name: "english"; MessagesFile: "compiler:Default.isl"
    echo Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
    echo Name: "german"; MessagesFile: "compiler:Languages\German.isl"
    echo Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
    echo.
    echo [Files]
    echo Source: "%DIST_DIR%\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
    echo.
    echo [Icons]
    echo Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; IconFilename: "{app}\cnnico.ico";
    echo Name: "{userdesktop}\Play Codename Nebula"; Filename: "{app}\PlayCodenameNebula.bat"; WorkingDir: "{app}"; IconFilename: "{app}\cnnico.ico";
    echo Name: "{userdesktop}\Play Codename Nebula Steam"; Filename: "{app}\PlayCNNSteam.bat"; WorkingDir: "{app}"; IconFilename: "{app}\cnnico.ico";
    echo Name: "{group}\Play Codename Nebula"; Filename: "{app}\PlayCodenameNebula.bat"; WorkingDir: "{app}"; IconFilename: "{app}\cnnico.ico";
    echo Name: "{group}\Play Codename Nebula Steam"; Filename: "{app}\PlayCNNSteam.bat"; WorkingDir: "{app}"; IconFilename: "{app}\cnnico.ico";
    echo.
    echo [Run]
    echo Filename: "{app}\CNNInstallUtil.EXE"; Description: "Configure mod (create launcher, shortcuts, INI files)"; Flags: waituntilterminated
    echo.
    echo [UninstallDelete]
    echo Type: filesandordirs; Name: "{app}"
    echo.
    echo [Code]
    echo procedure CurUninstallStepChanged^(CurUninstallStep: TUninstallStep^);
    echo var
    echo   DesktopFile: String;
    echo   StartMenuDir: String;
    echo   SystemDir: String;
    echo begin
    echo   if CurUninstallStep = usPostUninstall then
    echo   begin
    echo     DesktopFile := ExpandConstant^('{userdesktop}\Codename Nebula.lnk'^);
    echo     if FileExists^(DesktopFile^) then
    echo       DeleteFile^(DesktopFile^);
    echo     DesktopFile := ExpandConstant^('{userdesktop}\Play Codename Nebula.lnk'^);
    echo     if FileExists^(DesktopFile^) then
    echo       DeleteFile^(DesktopFile^);
    echo     DesktopFile := ExpandConstant^('{userdesktop}\Play Codename Nebula Steam.lnk'^);
    echo     if FileExists^(DesktopFile^) then
    echo       DeleteFile^(DesktopFile^);
    echo     DesktopFile := ExpandConstant^('{userdesktop}\Play Codename Nebula.bat'^);
    echo     if FileExists^(DesktopFile^) then
    echo       DeleteFile^(DesktopFile^);
    echo     StartMenuDir := ExpandConstant^('{userprograms}\Codename Nebula'^);
    echo     if DirExists^(StartMenuDir^) then
    echo       DelTree^(StartMenuDir, True, True, True^);
    echo     // No exe cleanup needed - we use DeusEx.exe directly, nothing to remove
    echo   end;
    echo end;
)

echo Building installer...
"%INNO_SETUP%\iscc.exe" "%ISS_FILE%"
if errorlevel 1 (
    echo.
    echo INSTALLER BUILD FAILED
    goto :eof
)

echo.
echo INSTALLER SUCCEEDED
echo Output: %BUILD_DIR%\CodenameNebula_v%CNN_VERSION%.exe
goto :eof

:: ============================================================================
:: INSTALL - Deploy mod to local Deus Ex for testing
:: ============================================================================
:install
echo.
echo ========================================
echo  INSTALL (local testing)
echo ========================================
echo.

:: Ensure mod directory structure exists
if not exist "%DEUSEX_ROOT%\CodenameNebula\System" mkdir "%DEUSEX_ROOT%\CodenameNebula\System"
if not exist "%DEUSEX_ROOT%\CodenameNebula\Save" mkdir "%DEUSEX_ROOT%\CodenameNebula\Save"

:: Copy compiled packages to Deus Ex System
echo Deploying packages to %SYSTEM_DIR%...
for %%f in (CNN.u CNNText.u CNNTextText.u CNNAudioCNN.u CNNAudioChapter05.u CNNAudioChapter06.u GaussGun.u DXOgg.u DXOgg.dll PFAD.u DXRVNewVehicles.u RenderExt.dll D3D9Drv.dll) do (
    if exist "%REPO_ROOT%\System\%%f" (
        copy /y "%REPO_ROOT%\System\%%f" "%SYSTEM_DIR%\" >nul
        echo   %%f
    )
)

:: Copy packages to mod System folder too
echo Deploying packages to CodenameNebula\System...
for %%f in (CNN.u CNNText.u CNNTextText.u CNNAudioCNN.u CNNAudioChapter05.u CNNAudioChapter06.u GaussGun.u DXOgg.u DXOgg.dll PFAD.u DXRVNewVehicles.u) do (
    if exist "%REPO_ROOT%\System\%%f" (
        copy /y "%REPO_ROOT%\System\%%f" "%DEUSEX_ROOT%\CodenameNebula\System\" >nul
    )
)

:: ---- Generate CNN.ini from player's DeusEx.ini ----
echo.
echo Generating CNN.ini from player's DeusEx.ini...
set "GEN_ARGS=%TEMP%\cnn_gen_args.txt"
echo %SYSTEM_DIR%\DeusEx.ini> "!GEN_ARGS!"
echo %DEUSEX_ROOT%\CodenameNebula\System\CNN.ini>> "!GEN_ARGS!"
echo %DEUSEX_ROOT%\CodenameNebula\System\CNNUser.ini>> "!GEN_ARGS!"
echo %SYSTEM_DIR%\User.ini>> "!GEN_ARGS!"
echo ..\CodenameNebula>> "!GEN_ARGS!"
echo %DEUSEX_ROOT%>> "!GEN_ARGS!"

powershell -ExecutionPolicy Bypass -File "%REPO_ROOT%\tools\generate_cnn_ini.ps1" -ArgsFile "!GEN_ARGS!"
if errorlevel 1 (
    echo   WARNING: INI generation failed. Falling back to static CNN.ini...
    if exist "%REPO_ROOT%\System\CNN.ini" copy /y "%REPO_ROOT%\System\CNN.ini" "%DEUSEX_ROOT%\CodenameNebula\System\" >nul
    if exist "%REPO_ROOT%\System\CNNUser.ini" copy /y "%REPO_ROOT%\System\CNNUser.ini" "%DEUSEX_ROOT%\CodenameNebula\System\" >nul
)
del "!GEN_ARGS!" 2>nul

:: ---- Detect game executable (no renaming — use DeusEx.exe directly) ----
:: Same approach as GMDX/TNM: preserves Steam overlay on Steam installs
:: Works on Steam, GOG, and vanilla (CD) installs
echo.
echo Detecting game executable...
set "EXE_TYPE=not found"
set "EXE_SIZE=0"
if exist "%SYSTEM_DIR%\DeusEx.exe" for %%A in ("%SYSTEM_DIR%\DeusEx.exe") do set "EXE_SIZE=%%~zA"
if !EXE_SIZE! GTR 300000 set "EXE_TYPE=third-party launcher - Kentie or Han"
if !EXE_SIZE! GTR 200000 if "!EXE_TYPE!"=="not found" set "EXE_TYPE=original 1112fm"
if !EXE_SIZE! GTR 0 if "!EXE_TYPE!"=="not found" set "EXE_TYPE=Community Update wrapper"
echo   DeusEx.exe: !EXE_TYPE! [!EXE_SIZE! bytes]

:: Deploy to Community Update if present
if exist "%CU_SYSTEM%" (
    echo.
    echo Deploying to Community Update editor...
    for %%f in (CNN.u CNNText.u CNNTextText.u CNNAudioCNN.u CNNAudioChapter05.u CNNAudioChapter06.u GaussGun.u DXOgg.u DXOgg.dll) do (
        if exist "%REPO_ROOT%\System\%%f" copy /y "%REPO_ROOT%\System\%%f" "%CU_SYSTEM%\" >nul
    )
)

echo.
echo INSTALL SUCCEEDED
echo You can now run: cnn test
goto :eof

:: ============================================================================
:: TEST - Launch the mod
:: ============================================================================
:test
echo.
echo ========================================
echo  TEST - Launching Codename Nebula
echo ========================================
echo.

:: Check for generated CNN.ini (from cnn install), then auto-install if missing
:: Note: use !DEUSEX_ROOT! (delayed expansion) to handle parentheses in paths like "Program Files (x86)"
set "CNN_INI="
if exist "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini" set "CNN_INI=!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini"
if not defined CNN_INI (
    echo CNN.ini not found. Running "cnn install" first...
    echo.
    call :install
)
if not defined CNN_INI if exist "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini" set "CNN_INI=!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini"
if not defined CNN_INI echo ERROR: CNN.ini still not found after install. && goto :eof

set "CNN_USER_INI="
if exist "!DEUSEX_ROOT!\CodenameNebula\System\CNNUser.ini" set "CNN_USER_INI=!DEUSEX_ROOT!\CodenameNebula\System\CNNUser.ini"

:: Use DeusEx.exe directly with INI= parameters (same approach as GMDX/TNM)
:: This preserves Steam overlay and play time tracking on Steam installs
:: Works on Steam, GOG, and vanilla (CD) installs
set "CNN_EXE="
set "EXE_TYPE=not found"
set "EXE_SIZE=0"

:: Detect the best game executable
:: Use delayed expansion !VAR! throughout to handle parentheses in paths like (x86)
if exist "!SYSTEM_DIR!\DeusEx.exe" for %%A in ("!SYSTEM_DIR!\DeusEx.exe") do set "EXE_SIZE=%%~zA"
if !EXE_SIZE! GTR 300000 set "CNN_EXE=!SYSTEM_DIR!\DeusEx.exe" & set "EXE_TYPE=third-party launcher - Kentie or Han"
if !EXE_SIZE! GTR 200000 if not defined CNN_EXE set "CNN_EXE=!SYSTEM_DIR!\DeusEx.exe" & set "EXE_TYPE=original 1112fm"
if !EXE_SIZE! GTR 0 if not defined CNN_EXE set "CNN_EXE=!SYSTEM_DIR!\DeusEx.exe" & set "EXE_TYPE=Community Update wrapper"

:: If DeusEx.exe is the small CU wrapper, prefer the original 1112fm backup
if !EXE_SIZE! LEQ 200000 if !EXE_SIZE! GTR 0 if exist "!SYSTEM_DIR!\DeusEx 1112fm ^(Original EXE^).exe" set "CNN_EXE=!SYSTEM_DIR!\DeusEx 1112fm (Original EXE).exe" & set "EXE_TYPE=original 1112fm via CU backup"

if not defined CNN_EXE echo ERROR: No DeusEx.exe found in !SYSTEM_DIR! && goto :eof

echo Starting Codename Nebula...
echo   EXE:  !CNN_EXE! [!EXE_TYPE!]
echo   INI:  !CNN_INI!
if defined CNN_USER_INI echo   USER: !CNN_USER_INI!
echo.
if defined CNN_USER_INI start "" /d "!SYSTEM_DIR!" "!CNN_EXE!" INI="!CNN_INI!" USERINI="!CNN_USER_INI!"
if not defined CNN_USER_INI start "" /d "!SYSTEM_DIR!" "!CNN_EXE!" INI="!CNN_INI!"
goto :eof

:: ============================================================================
:: STEAM - Launch via Steam (overlay + play time tracking)
:: ============================================================================
:steam
echo.
echo ========================================
echo  STEAM - Launching via Steam
echo ========================================
echo.

:: Ensure CNN.ini exists
if not exist "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini" (
    echo CNN.ini not found. Running "cnn install" first...
    echo.
    call :install
)
if not exist "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini" echo ERROR: CNN.ini not found. && goto :eof

powershell -ExecutionPolicy Bypass -File "%REPO_ROOT%\tools\steam_launch.ps1" -CnnIniPath "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini" -CnnUserIniPath "!DEUSEX_ROOT!\CodenameNebula\System\CNNUser.ini"
goto :eof

:: ============================================================================
:: RESET - Regenerate CNN.ini and CNNUser.ini from player's config
:: ============================================================================
:reset
echo.
echo ========================================
echo  RESET - Regenerate config files
echo ========================================
echo.

:: Backup old configs if they exist
if exist "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini" (
    copy /y "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini" "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini.bak" >nul
    echo   Backed up CNN.ini to CNN.ini.bak
)
if exist "!DEUSEX_ROOT!\CodenameNebula\System\CNNUser.ini" (
    copy /y "!DEUSEX_ROOT!\CodenameNebula\System\CNNUser.ini" "!DEUSEX_ROOT!\CodenameNebula\System\CNNUser.ini.bak" >nul
    echo   Backed up CNNUser.ini to CNNUser.ini.bak
)

:: Ensure mod directory exists
if not exist "!DEUSEX_ROOT!\CodenameNebula\System" mkdir "!DEUSEX_ROOT!\CodenameNebula\System"
if not exist "!DEUSEX_ROOT!\CodenameNebula\Save" mkdir "!DEUSEX_ROOT!\CodenameNebula\Save"

:: Generate fresh configs from player's DeusEx.ini
echo.
echo Regenerating from player's DeusEx.ini...
set "GEN_ARGS=%TEMP%\cnn_gen_args.txt"
echo !SYSTEM_DIR!\DeusEx.ini> "!GEN_ARGS!"
echo !DEUSEX_ROOT!\CodenameNebula\System\CNN.ini>> "!GEN_ARGS!"
echo !DEUSEX_ROOT!\CodenameNebula\System\CNNUser.ini>> "!GEN_ARGS!"
echo !SYSTEM_DIR!\User.ini>> "!GEN_ARGS!"
echo ..\CodenameNebula>> "!GEN_ARGS!"
echo !DEUSEX_ROOT!>> "!GEN_ARGS!"

powershell -ExecutionPolicy Bypass -File "%REPO_ROOT%\tools\generate_cnn_ini.ps1" -ArgsFile "!GEN_ARGS!"
if errorlevel 1 (
    echo   WARNING: Config regeneration failed.
    if exist "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini.bak" (
        echo   Restoring from backup...
        copy /y "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini.bak" "!DEUSEX_ROOT!\CodenameNebula\System\CNN.ini" >nul
    )
)
del "!GEN_ARGS!" 2>nul

echo.
echo RESET COMPLETE
echo   Your renderer, resolution, and graphics settings have been refreshed
echo   from DeusEx.ini. HD textures auto-detected if available.
echo.
echo   Old configs saved as .bak files in CodenameNebula\System\
goto :eof

:: ============================================================================
:: CLEAN - Remove compiled packages
:: ============================================================================
:clean
echo.
echo ========================================
echo  CLEAN
echo ========================================
echo.

echo Cleaning compiled packages...
for %%f in (CNN.u CNNText.u CNNTextText.u CNNAudioCNN.u CNNAudioChapter05.u CNNAudioChapter06.u) do (
    if exist "%SYSTEM_DIR%\%%f" (
        del "%SYSTEM_DIR%\%%f"
        echo   Removed from System: %%f
    )
    if exist "%REPO_ROOT%\System\%%f" (
        del "%REPO_ROOT%\System\%%f"
        echo   Removed from repo: %%f
    )
    if exist "%CU_SYSTEM%\%%f" (
        del "%CU_SYSTEM%\%%f"
        echo   Removed from CU: %%f
    )
)

echo.
echo CLEAN SUCCEEDED
goto :eof

:: ============================================================================
:: HD - Detect and configure high-res texture/model packs
:: ============================================================================
:hd
echo.
echo ========================================
echo  HD TEXTURE DETECTION
echo ========================================
echo  Scanning for NewVision and HDTP...
echo ========================================
echo.

set "NV_PATH="
set "HDTP_TEX_PATH="
set "HDTP_SYS_PATH="
set "HD_SOURCE="

:: --- Detect NewVision ---
:: Revision (Steam DLC)
if not defined NV_PATH if exist "%DEUSEX_ROOT%\Revision\NewVision\Textures\CoreTexMetal.utx" (
    set "NV_PATH=%DEUSEX_ROOT%\Revision\NewVision\Textures"
    set "HD_SOURCE=Revision"
)
:: GMDX v9
if not defined NV_PATH if exist "%DEUSEX_ROOT%\GMDXv9\NewVision\Textures\CoreTexMetal.utx" (
    set "NV_PATH=%DEUSEX_ROOT%\GMDXv9\NewVision\Textures"
    set "HD_SOURCE=GMDX v9"
)
:: GMDX v10
if not defined NV_PATH if exist "%DEUSEX_ROOT%\GMDX\NewVision\Textures\CoreTexMetal.utx" (
    set "NV_PATH=%DEUSEX_ROOT%\GMDX\NewVision\Textures"
    set "HD_SOURCE=GMDX v10"
)
:: Standalone (New Vision folder)
if not defined NV_PATH if exist "%DEUSEX_ROOT%\New Vision\Textures\CoreTexMetal.utx" (
    set "NV_PATH=%DEUSEX_ROOT%\New Vision\Textures"
    set "HD_SOURCE=Standalone"
)
:: Standalone (NewVision folder, no space)
if not defined NV_PATH if exist "%DEUSEX_ROOT%\NewVision\Textures\CoreTexMetal.utx" (
    set "NV_PATH=%DEUSEX_ROOT%\NewVision\Textures"
    set "HD_SOURCE=Standalone"
)
:: Standalone (directly in Textures with NV prefix)
if not defined NV_PATH if exist "%DEUSEX_ROOT%\Textures\NVCoreTexMetal.utx" (
    set "NV_PATH=%DEUSEX_ROOT%\Textures"
    set "HD_SOURCE=Standalone (in Textures)"
)

:: --- Detect HDTP ---
:: Revision
if exist "%DEUSEX_ROOT%\Revision\HDTP\System\HDTPCharacters.u" (
    set "HDTP_SYS_PATH=%DEUSEX_ROOT%\Revision\HDTP\System"
    set "HDTP_TEX_PATH=%DEUSEX_ROOT%\Revision\HDTP\Textures"
    if not defined HD_SOURCE set "HD_SOURCE=Revision"
)
:: GMDX v9
if not defined HDTP_SYS_PATH if exist "%DEUSEX_ROOT%\GMDXv9\HDTP\System\HDTPCharacters.u" (
    set "HDTP_SYS_PATH=%DEUSEX_ROOT%\GMDXv9\HDTP\System"
    set "HDTP_TEX_PATH=%DEUSEX_ROOT%\GMDXv9\HDTP\Textures"
)
:: GMDX v10
if not defined HDTP_SYS_PATH if exist "%DEUSEX_ROOT%\GMDX\HDTP\System\HDTPCharacters.u" (
    set "HDTP_SYS_PATH=%DEUSEX_ROOT%\GMDX\HDTP\System"
    set "HDTP_TEX_PATH=%DEUSEX_ROOT%\GMDX\HDTP\Textures"
)
:: Standalone
if not defined HDTP_SYS_PATH if exist "%DEUSEX_ROOT%\HDTP\System\HDTPCharacters.u" (
    set "HDTP_SYS_PATH=%DEUSEX_ROOT%\HDTP\System"
    set "HDTP_TEX_PATH=%DEUSEX_ROOT%\HDTP\Textures"
)
:: Standalone (in base System/Textures folders)
if not defined HDTP_SYS_PATH if exist "%DEUSEX_ROOT%\System\HDTPCharacters.u" (
    set "HDTP_SYS_PATH=%DEUSEX_ROOT%\System"
    set "HDTP_TEX_PATH=%DEUSEX_ROOT%\Textures"
)
if not defined HDTP_SYS_PATH if exist "%DEUSEX_ROOT%\HDTP\HDTPCharacters.u" (
    set "HDTP_SYS_PATH=%DEUSEX_ROOT%\HDTP"
    set "HDTP_TEX_PATH=%DEUSEX_ROOT%\HDTP"
)

:: --- Report findings ---
if defined NV_PATH (
    echo   NewVision: FOUND [!HD_SOURCE!]
    echo     Path: !NV_PATH!
) else (
    echo   NewVision: not found
)
if defined HDTP_SYS_PATH (
    echo   HDTP:      FOUND
    echo     Models:  !HDTP_SYS_PATH!
    echo     Textures: !HDTP_TEX_PATH!
) else (
    echo   HDTP:      not found
)

if not defined NV_PATH if not defined HDTP_SYS_PATH (
    echo.
    echo   No HD packs found. You can install them from:
    echo     NewVision: https://www.moddb.com/mods/new-vision
    echo     HDTP:      https://www.moddb.com/mods/hdtp
    echo.
    echo   Or install Deus Ex: Revision (free on Steam^) which includes both.
    goto :eof
)

:: --- Inject paths into CNN.ini ---
echo.
set "CNN_INI_FILE=%REPO_ROOT%\System\CNN.ini"
if not exist "!CNN_INI_FILE!" (
    echo   ERROR: CNN.ini not found at !CNN_INI_FILE!
    goto :eof
)

:: Note: the PS script cleans old HD lines before injecting, so re-running is safe

echo   Updating CNN.ini with HD texture paths...

:: Write paths to temp file to avoid escaping issues with parentheses in paths
set "HD_ARGS=%TEMP%\cnn_hd_args.txt"
echo !CNN_INI_FILE!> "!HD_ARGS!"
if defined NV_PATH (echo !NV_PATH!>> "!HD_ARGS!") else (echo .>> "!HD_ARGS!")
if defined HDTP_TEX_PATH (echo !HDTP_TEX_PATH!>> "!HD_ARGS!") else (echo .>> "!HD_ARGS!")
if defined HDTP_SYS_PATH (echo !HDTP_SYS_PATH!>> "!HD_ARGS!") else (echo .>> "!HD_ARGS!")

powershell -ExecutionPolicy Bypass -File "%REPO_ROOT%\tools\inject_hd_paths.ps1" -ArgsFile "!HD_ARGS!"
del "!HD_ARGS!" 2>nul

echo   Done!
echo.
echo   HD textures will be loaded next time you run "cnn test".
echo   To also apply in the installed mod, run "cnn install" afterwards.
goto :eof

:: ============================================================================
:: RENDERER - Detect and select renderer
:: ============================================================================
:renderer
echo.
echo ========================================
echo  RENDERER SELECTION
echo ========================================
echo.

set "CNN_INI_FILE=%REPO_ROOT%\System\CNN.ini"
if not exist "!CNN_INI_FILE!" echo ERROR: CNN.ini not found && goto :eof

:: Detect available renderers
echo Available renderers:
echo.
set "R_NUM=0"
if exist "%SYSTEM_DIR%\D3D9Drv.dll" (
    set /a R_NUM+=1
    set "R!R_NUM!=D3D9Drv.D3D9RenderDevice"
    set "R!R_NUM!_NAME=Direct3D 9 (recommended)"
    echo   !R_NUM!. Direct3D 9 (recommended^) - works on all modern GPUs
)
if exist "%SYSTEM_DIR%\d3d10drv.dll" (
    set /a R_NUM+=1
    set "R!R_NUM!=d3d10drv.d3d10RenderDevice"
    set "R!R_NUM!_NAME=Direct3D 10 (Kentie)"
    echo   !R_NUM!. Direct3D 10 (Kentie^) - advanced features, may crash in editor
)
if exist "%SYSTEM_DIR%\OpenGlDrv.dll" (
    set /a R_NUM+=1
    set "R!R_NUM!=OpenGlDrv.OpenGLRenderDevice"
    set "R!R_NUM!_NAME=OpenGL"
    echo   !R_NUM!. OpenGL - may have issues on modern NVIDIA/AMD drivers
)
if exist "%SYSTEM_DIR%\D3DDrv.dll" (
    set /a R_NUM+=1
    set "R!R_NUM!=D3DDrv.D3DRenderDevice"
    set "R!R_NUM!_NAME=Direct3D (legacy)"
    echo   !R_NUM!. Direct3D (legacy^) - old, limited resolution support
)
if exist "%SYSTEM_DIR%\SoftDrv.dll" (
    set /a R_NUM+=1
    set "R!R_NUM!=SoftDrv.SoftwareRenderDevice"
    set "R!R_NUM!_NAME=Software"
    echo   !R_NUM!. Software - slow but always works, CPU-only rendering
)

if "!R_NUM!"=="0" echo   No renderers found in %SYSTEM_DIR% && goto :eof

:: Show current
for /f "tokens=1,* delims==" %%a in ('findstr "^GameRenderDevice=" "!CNN_INI_FILE!"') do set "CURRENT_RENDERER=%%b"
echo.
echo   Current: !CURRENT_RENDERER!
echo.
set /p "R_CHOICE=Select renderer (1-!R_NUM!, or Enter to keep current): "

if "!R_CHOICE!"=="" echo   Keeping current renderer. && goto :eof
if !R_CHOICE! LSS 1 echo   Invalid choice. && goto :eof
if !R_CHOICE! GTR !R_NUM! echo   Invalid choice. && goto :eof

set "NEW_RENDERER=!R%R_CHOICE%!"
set "NEW_RENDERER_NAME=!R%R_CHOICE%_NAME!"

:: Update CNN.ini
powershell -ExecutionPolicy Bypass -Command ^
    "$f='!CNN_INI_FILE!'; $ini=[IO.File]::ReadAllText($f); $ini=$ini -replace 'GameRenderDevice=.*','GameRenderDevice=!NEW_RENDERER!'; $ini=$ini -replace 'RenderDevice=.*','RenderDevice=!NEW_RENDERER!'; $ini=$ini -replace 'WindowedRenderDevice=.*','WindowedRenderDevice=!NEW_RENDERER!'; [IO.File]::WriteAllText($f,$ini)" 2>nul

echo.
echo   Renderer changed to: !NEW_RENDERER_NAME!
echo   Run "cnn install" to apply to the installed mod.
goto :eof

:: ============================================================================
:: VERSION - Show current version
:: ============================================================================
:version
echo %CNN_VERSION%
goto :eof

:: ============================================================================
:: BUMP - Increment version number
:: ============================================================================
:bump
set "BUMP_PART=%~2"
if "%BUMP_PART%"=="" set "BUMP_PART=patch"

if /i "%BUMP_PART%"=="patch" (
    set /a "VER_PATCH=VER_PATCH+1"
) else if /i "%BUMP_PART%"=="minor" (
    set /a "VER_MINOR=VER_MINOR+1"
    set "VER_PATCH=0"
) else if /i "%BUMP_PART%"=="major" (
    set /a "VER_MAJOR=VER_MAJOR+1"
    set "VER_MINOR=0"
    set "VER_PATCH=0"
) else (
    echo ERROR: Unknown version part "%BUMP_PART%". Use: patch, minor, or major
    goto :eof
)

set "CNN_VERSION=!VER_MAJOR!.!VER_MINOR!.!VER_PATCH!"
echo !CNN_VERSION!> "%VERSION_FILE%"
echo Version bumped: %CNN_VERSION% -^> !CNN_VERSION!
goto :eof

:: ============================================================================
:: ALL - Full build pipeline
:: ============================================================================
:all
call :compile
if errorlevel 1 goto :eof
call :package
if errorlevel 1 goto :eof
call :installer
goto :eof

:: ============================================================================
:: HELP
:: ============================================================================
:help
echo.
echo Codename Nebula Build Tool v%CNN_VERSION%
echo.
echo Usage: cnn ^<command^>
echo.
echo Commands:
echo   setup           First-time setup (junctions, DLLs, INI config)
echo   compile         Compile UnrealScript packages (CNN.u, CNNText.u)
echo   package         Copy compiled assets into distribution folder
echo   installer       Build Inno Setup installer (.exe)
echo   install         Deploy mod to local Deus Ex for testing
echo   test            Launch the mod in Deus Ex
echo   steam           Launch via Steam (overlay + play time tracking)
echo   reset           Regenerate CNN.ini/CNNUser.ini from player's config
echo   clean           Remove compiled packages
echo   bump [part]     Increment version (patch/minor/major, default: patch)
echo   version         Show current version
echo   hd              Detect and configure HD textures (NewVision/HDTP)
echo   renderer        Select graphics renderer (D3D9/OpenGL/Software)
echo   all             compile + package + installer
echo   help            Show this help
echo.
echo Environment:
echo   DEUSEX_ROOT   Path to Deus Ex installation (auto-detected)
echo   INNO_SETUP    Path to Inno Setup installation (auto-detected)
echo.
echo Current paths:
if defined DEUSEX_ROOT (echo   Deus Ex:  "%DEUSEX_ROOT%") else (echo   Deus Ex:  NOT FOUND)
if defined INNO_SETUP  (echo   Inno:     "%INNO_SETUP%")  else (echo   Inno:     NOT FOUND)
echo   Repo:     "%REPO_ROOT%"
echo.
goto :eof

