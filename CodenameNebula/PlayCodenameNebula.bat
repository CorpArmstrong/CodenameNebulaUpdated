@echo off
cd /d "%~dp0..\System"
"%~dp0..\System\CodenameNebula.exe" INI="%~dp0System\CNN.ini" USERINI="%~dp0System\CNNUser.ini"
