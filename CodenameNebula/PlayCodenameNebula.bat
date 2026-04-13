@echo off
cd /d "%~dp0..\System"
:: Launch CNN using DeusEx.exe with custom INI files
:: Steam overlay and play time tracking work because we use the original exe
if exist "%~dp0..\System\DeusEx.exe" (
    "%~dp0..\System\DeusEx.exe" INI="%~dp0System\CNN.ini" USERINI="%~dp0System\CNNUser.ini"
) else (
    echo ERROR: DeusEx.exe not found. Please verify your Deus Ex installation.
    pause
)
