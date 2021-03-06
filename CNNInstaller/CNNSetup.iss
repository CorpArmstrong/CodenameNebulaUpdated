; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Codename Nebula"
#define MyAppVersion "1.2.4"
#define MyAppPublisher "ApostleMod"
#define MyAppURL "https://apocalypseinside.heraldic.cloud/"
#define SetupDir "C:\Jenkins\workspace\CNN-Jenkins"

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
LicenseFile={#SetupDir}\CNNInstaller\InfoLicense.txt
InfoBeforeFile={#SetupDir}\CNNInstaller\InfoBeforeInstall.txt
OutputDir=C:\Dropbox\CNN
OutputBaseFilename=CodenameNebula_v1.2.4
;SetupIconFile={#SetupDir}\CodenameNebula\cnnico.ico
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

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; IconFilename: "{app}\cnnico.ico";
Name: "{app}\Play Codename Nebula"; Filename: "{app}\..\System\DeusEx.EXE"; WorkingDir: "{app}\..\System\"; Parameters: "-ini={app}\System\CNN.ini -userini={app}\System\CNNUser.ini"; IconFilename: "{app}\cnnico.ico";
Name: "{group}\Play Codename Nebula"; Filename: "{app}\..\System\DeusEx.EXE"; WorkingDir: "{app}\..\System\"; Parameters: "-ini={app}\System\CNN.ini -userini={app}\System\CNNUser.ini"; IconFilename: "{app}\cnnico.ico";

[Run]
Filename: "{app}\CNNInstallUtil.EXE"; Flags: nowait skipifsilent

;[Code]
