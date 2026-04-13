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
powershell -ExecutionPolicy Bypass -File "%~dp0tools\steam_launch.ps1" -CnnIniPath "%~dp0System\CNN.ini" -CnnUserIniPath "%~dp0System\CNNUser.ini"
