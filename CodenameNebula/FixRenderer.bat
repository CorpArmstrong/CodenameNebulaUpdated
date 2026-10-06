@echo off
echo ========================================
echo  Codename Nebula - Fix Renderer
echo ========================================
echo.
echo  Use this when the game does not start, shows a black
echo  screen, or stops with "Failed resetting mode".
echo  It switches CNN.ini to the Direct3D9 renderer
echo  (OpenGL if Direct3D9 is missing) and 32-bit colour.
echo  The old file is kept as CNN.ini.bak.
echo.
echo  Monitor black but the game is running? Use the
echo  "Fix Renderer (windowed)" shortcut instead.
echo ========================================
echo.
set "CNN_WINDOWED="
if /i "%~1"=="windowed" set "CNN_WINDOWED=-Windowed"
powershell -ExecutionPolicy Bypass -File "%~dp0tools\fix_renderer.ps1" -Ini "%~dp0System\CNN.ini" %CNN_WINDOWED%
echo.
pause
