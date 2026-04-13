@echo off
echo ========================================
echo  Codename Nebula - Steam Launch
echo ========================================
echo.
echo  Launches CNN via Steam for:
echo    - Play time tracking
echo    - "Playing Deus Ex" status
echo    - Steam overlay
echo ========================================
echo.

set "CNN_INI=%~dp0System\CNN.ini"
set "CNN_USER_INI=%~dp0System\CNNUser.ini"

if not exist "%CNN_INI%" (
    echo ERROR: CNN.ini not found at %CNN_INI%
    echo Please run the installer or "cnn install" first.
    pause
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "%~dp0..\tools\steam_launch.ps1" -CnnIniPath "%CNN_INI%" -CnnUserIniPath "%CNN_USER_INI%"
