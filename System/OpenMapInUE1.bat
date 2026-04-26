@echo off
:: Drag-drop a .dx onto this bat to open it in the original SDK UnrealEd.
:: For a path-aware launcher with CU-editor preference, use "cnn edit <map>".
start "" "%~dp0UnrealEd.exe" "%~f1"
exit 0