; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Codename Nebula"
#define MyAppVersion "1.1"
#define MyAppPublisher "DeusGroup, Inc."
#define MyAppURL "https://apocalypseinside.heraldic.cloud/"
#define SetupDir "E:\Games\DeusEx\steamapps\common\Deus Ex"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{C4AE68BE-8529-47A6-8659-4CC0EF7311CA}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
;DefaultDirName={pf}\CodenameNebula
DefaultDirName={sd}\Games\DeusEx\CodenameNebula
DefaultGroupName={#MyAppName}
;AllowNoIcons=yes
LicenseFile={#SetupDir}\CNNInstaller\InfoLicense.txt
InfoBeforeFile={#SetupDir}\CNNInstaller\InfoBeforeInstall.txt
InfoAfterFile={#SetupDir}\CNNInstaller\InfoAfterInstall.txt
OutputDir=E:\Games\CNNInstaller\
OutputBaseFilename=CodenameNebula_v1.2.1
SetupIconFile={#SetupDir}\CodenameNebula\cnnico.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Files]
Source: "{#SetupDir}\CodenameNebula\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{app}\Play Codename Nebula"; Filename: "{app}\..\System\DeusEx.EXE"; WorkingDir: "{app}\..\System\"; Parameters: "-ini={app}\System\CNN.ini -userini={app}\System\CNNUser.ini"; IconFilename: "{app}\cnnico.ico";
Name: "{group}\Play Codename Nebula"; Filename: "{app}\..\System\DeusEx.EXE"; WorkingDir: "{app}\..\System\"; Parameters: "-ini={app}\System\CNN.ini -userini={app}\System\CNNUser.ini"; IconFilename: "{app}\cnnico.ico";

[Run]
Filename: "{app}\CNNInstallUtil.EXE"; Flags: nowait skipifsilent
;Description: "Setup will now create ini-files"; StatusMsg: "Creating ini-files..."; Flags: postinstall nowait skipifsilent checked

;[Code]
