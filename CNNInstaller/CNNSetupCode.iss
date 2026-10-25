; Codename Nebula installer logic, included by the script cnn.bat generates.
;
; The mod must sit directly in the Deus Ex folder as <Deus Ex>\CodenameNebula:
; CNN.ini reaches it as ..\CodenameNebula from the game's System. So the setup
; finds the game itself, shows <game>\CodenameNebula, and accepts another
; folder only if it is a Deus Ex folder (or that folder's CodenameNebula).

[Code]
const
  StockDeusExUSize = 5386972;   // DeusEx.u of Deus Ex 1112fm (Steam, GOG, GOTY CD)

function IsDeusExFolder(Dir: String): Boolean;
begin
  Result := (Dir <> '') and FileExists(AddBackslash(Dir) + 'System\DeusEx.exe');
end;

// Steam keeps games in libraries listed in steamapps\libraryfolders.vdf as
//   "path"  "D:\\SteamLibrary"
function FindInSteamLibraries(SteamPath: String): String;
var
  Lines: TArrayOfString;
  I: Integer;
  Line, Lib: String;
begin
  Result := '';
  if IsDeusExFolder(SteamPath + '\steamapps\common\Deus Ex') then
  begin
    Result := SteamPath + '\steamapps\common\Deus Ex';
    exit;
  end;
  if not LoadStringsFromFile(SteamPath + '\steamapps\libraryfolders.vdf', Lines) then
    exit;
  for I := 0 to GetArrayLength(Lines) - 1 do
  begin
    Line := Trim(Lines[I]);
    if Pos('"path"', Line) = 1 then
    begin
      Lib := Trim(Copy(Line, 7, Length(Line)));
      StringChangeEx(Lib, '"', '', True);
      StringChangeEx(Lib, '\\', '\', True);
      if IsDeusExFolder(Lib + '\steamapps\common\Deus Ex') then
      begin
        Result := Lib + '\steamapps\common\Deus Ex';
        exit;
      end;
    end;
  end;
end;

// Steam's install script and the retail/CD setup both write
// HKLM\SOFTWARE\Unreal Technology\Installed Apps\Deus Ex\Folder; GOG keeps its
// own key; otherwise look through the Steam libraries
function FindDeusEx(): String;
var
  Dir, SteamPath: String;
begin
  if RegQueryStringValue(HKLM, 'SOFTWARE\Unreal Technology\Installed Apps\Deus Ex', 'Folder', Dir) and IsDeusExFolder(Dir) then
  begin
    Result := RemoveBackslashUnlessRoot(Dir);
    exit;
  end;
  if RegQueryStringValue(HKLM, 'SOFTWARE\GOG.com\Games\1207658995', 'path', Dir) and IsDeusExFolder(Dir) then
  begin
    Result := RemoveBackslashUnlessRoot(Dir);
    exit;
  end;
  if RegQueryStringValue(HKCU, 'Software\Valve\Steam', 'SteamPath', SteamPath) then
  begin
    StringChangeEx(SteamPath, '/', '\', True);
    Result := FindInSteamLibraries(SteamPath);
    if Result <> '' then
      exit;
  end;
  Result := '';
end;

function DefaultModDir(Param: String): String;
var
  Game: String;
begin
  Game := FindDeusEx();
  if Game = '' then
    Game := ExpandConstant('{sd}\DeusEx');
  Result := Game + '\CodenameNebula';
end;

// Whatever folder the player picks, the mod ends up as <game>\CodenameNebula
function NextButtonClick(CurPageID: Integer): Boolean;
var
  Dir, Game: String;
  Size: Integer;
begin
  Result := True;
  if CurPageID <> wpSelectDir then
    exit;

  Dir := RemoveBackslashUnlessRoot(WizardForm.DirEdit.Text);
  if CompareText(ExtractFileName(Dir), 'CodenameNebula') = 0 then
    Game := ExtractFileDir(Dir)
  else
    Game := Dir;

  if not IsDeusExFolder(Game) then
  begin
    MsgBox('This is not a Deus Ex folder:' + #13#10 + Game + #13#10#13#10 +
           'Choose the folder Deus Ex is installed in - the one that contains the System folder ' +
           '(for Steam usually ...\steamapps\common\Deus Ex). Codename Nebula is installed into it ' +
           'as a CodenameNebula subfolder.', mbError, MB_OK);
    Result := False;
    exit;
  end;
  WizardForm.DirEdit.Text := Game + '\CodenameNebula';

  if FileSize(Game + '\System\DeusEx.u', Size) and (Size <> StockDeusExUSize) then
    Result := MsgBox('The game file System\DeusEx.u in this Deus Ex folder is not the one from Deus Ex 1112fm ' +
                     '(Game of the Year edition / patch 1112fm).' + #13#10#13#10 +
                     'Either the game is not patched to version 1112fm, or another mod (for example Shifter ' +
                     'or Biomod) replaced it. Codename Nebula may not work with it.' + #13#10#13#10 +
                     'Install anyway?', mbConfirmation, MB_YESNO) = IDYES;
end;

// Shortcuts earlier versions made (CNNInstallUtil and Inno), now one shortcut to the launcher
procedure RemoveOldShortcuts();
begin
  DeleteFile(ExpandConstant('{userdesktop}\Play Codename Nebula.lnk'));
  DeleteFile(ExpandConstant('{userdesktop}\Play Codename Nebula Steam.lnk'));
  DeleteFile(ExpandConstant('{userdesktop}\Play Codename Nebula.bat'));
  DeleteFile(ExpandConstant('{userprograms}\Codename Nebula\Play Codename Nebula.lnk'));
  DeleteFile(ExpandConstant('{userprograms}\Codename Nebula\Play Codename Nebula Steam.lnk'));
  DeleteFile(ExpandConstant('{userprograms}\Codename Nebula\Fix Renderer.lnk'));
  DeleteFile(ExpandConstant('{userprograms}\Codename Nebula\Fix Renderer (windowed).lnk'));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
    RemoveOldShortcuts();
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  Added: TArrayOfString;
  I: Integer;
  L, F: String;
begin
  // What the setup added to the game's own folders (native DLLs in System):
  // a file line is removed only while the file still holds what CNN put there,
  // a dir line only when empty -- nothing a player or another mod owns goes
  if CurUninstallStep = usUninstall then
    if LoadStringsFromFile(ExpandConstant('{app}\System\CNNGameFiles.txt'), Added) then
      for I := 0 to GetArrayLength(Added) - 1 do
      begin
        L := Added[I];
        F := Copy(L, 47, Length(L));
        if Copy(L, 1, 4) = 'dir ' then
          RemoveDir(Copy(L, 5, Length(L)))
        else if (Copy(L, 1, 5) = 'file ') and FileExists(F) then
          if CompareText(GetSHA1OfFile(F), Copy(L, 6, 40)) = 0 then
            DeleteFile(F);
      end;
  if CurUninstallStep = usPostUninstall then
  begin
    RemoveOldShortcuts();
    // the game writes CodenameNebula.log next to the CD copy's exe
    DeleteFile(ExpandConstant('{app}\..\System\CodenameNebula.log'));
  end;
end;
