// ============================================================================
// ScreenSlideMap
// Copyright 2001-2002 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlide that displays the positions of players in a map
// on a map of that map. Much legacy code here; if designed from scratch this
// class would be much more efficient. Compatibility is the name of the game.
// ============================================================================


class ScreenSlideMap extends ScreenSlide;


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorSlideMap.bmp mips=off flags=2

#exec obj load file=Textures\ScreenFonts.utx    package=ScreenFonts
#exec obj load file=Textures\ScriptedAiutx package=ScriptedScreen


// ============================================================================
// Replication
// ============================================================================

replication {

  reliable if (Role == ROLE_Authority)
    FlagMaster,
    InfoPlayer, LocationPlayer, HealthPlayer, FlagPlayerVisible, ZonePlayer;
  }


// ============================================================================
// Types
// ============================================================================

enum EnumCoordSelection {

  CoordSelection_X,
  CoordSelection_Y,
  CoordSelection_Z,
  };


enum EnumIconsType {

  IconsType_Teams,
  IconsType_Classes,
  };


enum EnumDisplayAlignHorz {

  DisplayAlignHorz_Left,
  DisplayAlignHorz_Center,
  DisplayAlignHorz_Right,
  };


enum EnumDisplayAlignVert {

  DisplayAlignVert_Top,
  DisplayAlignVert_Middle,
  DisplayAlignVert_Bottom,
  };


enum EnumZoneDisplay {

  ZoneDisplay_Inside,
  ZoneDisplay_Outside,
  };


// ============================================================================
// Properties
// ============================================================================

var() Font FontPlayers;
var() Color FontPlayersColor;

var() Texture Map;
var() Texture PlayerIcons;
var() EnumIconsType PlayerIconsType;
var() int PlayerIconsWidth;
var() int PlayerIconsHeight;

var() string PlayerDisplay;
var() EnumDisplayAlignHorz PlayerDisplayAlignHorz;
var() EnumDisplayAlignVert PlayerDisplayAlignVert;
var() int PlayerDisplayPaddingTop;
var() int PlayerDisplayPaddingLeft;
var() int PlayerDisplayPaddingRight;
var() int PlayerDisplayPaddingBottom;

var() bool ShowNeutral;
var() bool ShowRed;
var() bool ShowBlue;
var() bool ShowGreen;
var() bool ShowGold;

var() bool ShowNeutralInvisible;
var() bool ShowRedInvisible;
var() bool ShowBlueInvisible;
var() bool ShowGreenInvisible;
var() bool ShowGoldInvisible;

var() bool ShowDead;
var() bool ShowSelf;

var() int MapTop;
var() int MapLeft;
var() int MapRight;
var() int MapBottom;

var() EnumCoordSelection CoordHorz;
var() EnumCoordSelection CoordVert;
var() EnumCoordSelection CoordDepth;
var() int CoordDepthMin;
var() int CoordDepthMax;

var() float UpdateInterval;
var() Sound UpdateSound;
var() float UpdateSoundVolume;
var() bool UpdateSyncBackground;
var() bool UpdateSyncIcons;

var() ZoneInfo Zone;
var() class<ZoneInfo> ZoneClass;
var() EnumZoneDisplay ZoneDisplay;


// ============================================================================
// Variables
// ============================================================================

var bool FlagMaster;
var PlayerPawn PlayerLocal;
var ScreenSlideMap SlideMapMaster;

var PlayerReplicationInfo InfoPlayer[32];

var vector LocationPlayer[32];  // individual arrays for better replication
var int HealthPlayer[32];
var int FlagPlayerVisible[32];
var ZoneInfo ZonePlayer[32];

var vector LocationPlayerAck[32];
var int HealthPlayerAck[32];
var int FlagPlayerVisibleAck[32];
var ZoneInfo ZonePlayerAck[32];

var float TimeCreate;
var float TimeTick;
var float TimeUpdate;
var bool FlagUpdate;

var Texture TextureBackgroundAck;
var Texture TextureBackgroundNext;
var Texture TextureIconsAck;
var Texture TextureIconsNext;


// ============================================================================
// PreBeginPlay
// ============================================================================

event PreBeginPlay() {

  local ScreenSlideMap ThisSlide;

  foreach AllActors(class 'ScreenSlideMap', ThisSlide)
    if (ThisSlide.FlagMaster)
      break;

  if (ThisSlide == None)
    FlagMaster = true;
  else
    RemoteRole = ROLE_None;
  }


// ============================================================================
// Tick
// ============================================================================

event Tick(float TimeDelta) {

  local int IndexPlayer;
  local Pawn ThisPawn;

  if (!FlagMaster || Level.TimeSeconds < TimeTick + 0.1)
    return;

  for (IndexPlayer = 0; IndexPlayer < ArrayCount(InfoPlayer); IndexPlayer++)
    InfoPlayer[IndexPlayer] = None;

  for (ThisPawn = Level.PawnList; ThisPawn != None; ThisPawn = ThisPawn.NextPawn)
    if (ThisPawn.PlayerReplicationInfo != None      &&
       !ThisPawn.PlayerReplicationInfo.bIsSpectator &&
        ThisPawn.PlayerReplicationInfo.PlayerID < ArrayCount(InfoPlayer))
      SetInfo(ThisPawn.PlayerReplicationInfo.PlayerID, ThisPawn);

  IndexPlayer = 0;

  for (ThisPawn = Level.PawnList; ThisPawn != None; ThisPawn = ThisPawn.NextPawn)
    if (ThisPawn.PlayerReplicationInfo != None      &&
       !ThisPawn.PlayerReplicationInfo.bIsSpectator &&
        ThisPawn.PlayerReplicationInfo.PlayerID >= ArrayCount(InfoPlayer)) {

      while (IndexPlayer < ArrayCount(InfoPlayer) && InfoPlayer[IndexPlayer] != None)
        IndexPlayer++;
      if (IndexPlayer >= ArrayCount(InfoPlayer))
        break;

      SetInfo(IndexPlayer, ThisPawn);
      }

  TimeTick = Level.TimeSeconds;
  }


// ============================================================================
// SetInfo
//
// Fills the element at the given index of the various replicated arrays with
// information about the given player. Overwrite this function if you need to
// store and replicate your own information in subclasses.
// ============================================================================

function SetInfo(int IndexPlayer, Pawn PawnPlayer) {

  InfoPlayer    [IndexPlayer] = PawnPlayer.PlayerReplicationInfo;
  LocationPlayer[IndexPlayer] = PawnPlayer.Location;
  ZonePlayer    [IndexPlayer] = PawnPlayer.Region.Zone;
  HealthPlayer  [IndexPlayer] = PawnPlayer.Health;

  /* FIXME: CorpArmstrong, uncomment this later.
  FlagPlayerVisible[IndexPlayer] =
    int(PawnPlayer.FindInventoryType(class 'UT_Invisibility') == None &&
        PawnPlayer.FindInventoryType(class 'UT_Stealth')      == None);
        */
  }


// ============================================================================
// GetInfo
//
// Fills the element at the given index of the various replicated arrays with
// information taken from the given master slide. Called on all clients.
// Overwrite this function if you need to store and replicate your own
// information in subclasses.
// ============================================================================

simulated function GetInfo(int IndexPlayer, ScreenSlideMap SlideSource) {

  InfoPlayer       [IndexPlayer] = SlideSource.InfoPlayer       [IndexPlayer];
  LocationPlayer   [IndexPlayer] = SlideSource.GetLocationPlayer(IndexPlayer);
  HealthPlayer     [IndexPlayer] = SlideSource.HealthPlayer     [IndexPlayer];
  FlagPlayerVisible[IndexPlayer] = SlideSource.FlagPlayerVisible[IndexPlayer];
  ZonePlayer       [IndexPlayer] = SlideSource.ZonePlayer       [IndexPlayer];
  }


// ============================================================================
// GetLocationPlayer
//
// Access method for an element of the LocationPlayer array. It's the only one
// that cannot be directly accessed because it's too large.
// ============================================================================

simulated final function vector GetLocationPlayer(int IndexPlayer) {

  return LocationPlayer[IndexPlayer];
  }


// ============================================================================
// Prepare
// ============================================================================

simulated function Prepare(ScriptedTexture TextureCanvas) {

  local int IndexPlayer;
  local GameReplicationInfo InfoGame;

  if (PlayerLocal == None)
    foreach AllActors(class 'PlayerPawn', PlayerLocal)
      if (Viewport(PlayerLocal.Player) != None)
        break;

  InfoGame = PlayerLocal.GameReplicationInfo;
  if (InfoGame == None)
    return;

  for (IndexPlayer = 0; IndexPlayer < ArrayCount(InfoGame.PRIArray); IndexPlayer++) {
    if (InfoGame.PRIArray[IndexPlayer] == None)
      break;

    if (InfoGame.PRIArray[IndexPlayer].bIsSpectator ||
        InfoGame.PRIArray[IndexPlayer].PlayerID >= ArrayCount(InfoPlayer))
      continue;

    InfoPlayer[InfoGame.PRIArray[IndexPlayer].PlayerID] = InfoGame.PRIArray[IndexPlayer];
    }

  if (TimeCreate < 0.0)
    TimeCreate = Level.TimeSeconds;

  if (SlideMapMaster == None && Level.TimeSeconds < TimeCreate + 1.0)
    foreach AllActors(class 'ScreenSlideMap', SlideMapMaster)
      if (SlideMapMaster.FlagMaster)
        break;

  if (SlideMapMaster == None ||
      SlideMapMaster == Self)
    return;

  for (IndexPlayer = 0; IndexPlayer < ArrayCount(InfoPlayer); IndexPlayer++)
    GetInfo(IndexPlayer, SlideMapMaster);
  }


// ============================================================================
// Draw
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int Left, int Top, float Fade) {

  local GameReplicationInfo InfoGame;
  local int IndexPlayer;
  local int IdPlayerPrev;
  local int FlagDisplayed[32];
  local int CoordTopPlayer;
  local int CoordLeftPlayer;
  local int CoordDepthPlayer;
  local int OffsetTopPlayer[32];
  local int OffsetLeftPlayer[32];

  DrawMap(TextureCanvas, Left, Top);

  if (MapTop == MapBottom || MapLeft == MapRight)
    return;

  if (Level.TimeSeconds > TimeUpdate + UpdateInterval) {
    TimeUpdate = Level.TimeSeconds;
    Update();
    }

  InfoGame = PlayerLocal.GameReplicationInfo;
  if (InfoGame == None)
    return;

  for (IndexPlayer = 0; IndexPlayer < ArrayCount(InfoPlayer); IndexPlayer++) {
    if (InfoPlayer[IndexPlayer] == None)
      continue;

    IdPlayerPrev = InfoPlayer[IndexPlayer].PlayerID;
    InfoPlayer[IndexPlayer].PlayerID = IndexPlayer;

    if (IsDisplayed(InfoPlayer[IndexPlayer]) &&
        CalcOffset(LocationPlayerAck[IndexPlayer], OffsetLeftPlayer[IndexPlayer],
                                                   OffsetTopPlayer [IndexPlayer])) {

      DrawTag(TextureCanvas, InfoPlayer[IndexPlayer], Left + OffsetLeftPlayer[IndexPlayer],
                                                      Top  + OffsetTopPlayer [IndexPlayer],
                                                      PlayerIconsWidth,
                                                      PlayerIconsHeight, Fade);
      FlagDisplayed[IndexPlayer] = 1;
      }

    InfoPlayer[IndexPlayer].PlayerID = IdPlayerPrev;
    }


  for (IndexPlayer = 0; IndexPlayer < ArrayCount(InfoPlayer); IndexPlayer++)
    if (FlagDisplayed[IndexPlayer] != 0) {
      IdPlayerPrev = InfoPlayer[IndexPlayer].PlayerID;
      InfoPlayer[IndexPlayer].PlayerID = IndexPlayer;

      DrawIcon(TextureCanvas, InfoPlayer[IndexPlayer],
               Left + OffsetLeftPlayer[IndexPlayer],
               Top  + OffsetTopPlayer [IndexPlayer], Fade);

      InfoPlayer[IndexPlayer].PlayerID = IdPlayerPrev;
      }
  }


// ============================================================================
// Update
//
// Updates all information that is displayed on the slide with current
// information replicated by the server.
// ============================================================================

simulated function Update() {

  local int IndexPlayer;

  for (IndexPlayer = 0; IndexPlayer < ArrayCount(LocationPlayer); IndexPlayer++) {
    LocationPlayerAck   [IndexPlayer] = LocationPlayer   [IndexPlayer];
    HealthPlayerAck     [IndexPlayer] = HealthPlayer     [IndexPlayer];
    FlagPlayerVisibleAck[IndexPlayer] = FlagPlayerVisible[IndexPlayer];
    ZonePlayerAck       [IndexPlayer] = ZonePlayer       [IndexPlayer];
    }

  if (UpdateInterval == 0.0)
    return;

  if (UpdateSound != None)
    PlaySound(UpdateSound, , UpdateSoundVolume);

  if (Background != TextureBackgroundAck) {
    if (TextureBackgroundAck != None)
      TextureBackgroundAck.AnimNext = TextureBackgroundNext;
    TextureBackgroundNext = Background.AnimNext;
    TextureBackgroundAck = Background;
    Background.AnimNext = None;
    }

  if (PlayerIcons != TextureIconsAck) {
    if (TextureIconsAck != None)
      TextureIconsAck.AnimNext = TextureIconsNext;
    TextureIconsNext = PlayerIcons.AnimNext;
    TextureIconsAck = PlayerIcons;
    PlayerIcons.AnimNext = None;
    }

  if (UpdateSyncBackground && Background != None && TextureBackgroundNext != None)
    Background.AnimCurrent = TextureBackgroundNext;
  if (UpdateSyncIcons && PlayerIcons != None && TextureIconsNext != None)
    PlayerIcons.AnimCurrent = TextureIconsNext;
  }


// ============================================================================
// CalcOffset
//
// Fills in the pixel offsets on the slide that corresponds to the given
// location. Returns a boolean value that tells whether the given location is
// within the displayed bounds or not.
// ============================================================================

simulated function bool CalcOffset(vector VectorItem, optional out int OffsetLeftItem,
                                                      optional out int OffsetTopItem) {

  local float CoordDepthItem;

  CoordDepthItem = Component(VectorItem, CoordDepth);

  if (CoordDepthMin < CoordDepthMax && CoordDepthItem != Clamp(CoordDepthItem, CoordDepthMin, CoordDepthMax))
    return false;

  OffsetLeftItem = (Component(VectorItem, CoordHorz) - MapLeft) * ClientWidth  / (MapRight  - MapLeft);
  OffsetTopItem  = (Component(VectorItem, CoordVert) - MapTop)  * ClientHeight / (MapBottom - MapTop);

  return (OffsetLeftItem == Clamp(OffsetLeftItem, 0, ClientWidth)) &&
         (OffsetTopItem  == Clamp(OffsetTopItem,  0, ClientHeight));
  }


// ============================================================================
// DrawMap
//
// Draws the background map on the slide.
// ============================================================================

simulated function DrawMap(ScriptedTexture TextureCanvas, int Left, int Top) {

  if (Map != None)
    TextureCanvas.DrawTile(Left, Top, ClientWidth, ClientHeight, 0, 0, Map.USize, Map.VSize, Map, Map.bMasked);
  }


// ============================================================================
// DrawTag
//
// Draws the player's text tag on the screen with the given parameters at the
// given position.
// ============================================================================

simulated function DrawTag(ScriptedTexture TextureCanvas, PlayerReplicationInfo Info,
                           int OffsetLeft, int OffsetTop, int WidthIcon, int HeightIcon, float Fade) {

  local string TextDisplay;
  local int OffsetLeftText;
  local int OffsetTopText;
  local int OffsetLeftIcon;
  local int OffsetTopIcon;
  local float WidthText;
  local float HeightText;

  TextDisplay = PlayerDisplay;
  TextDisplay = Replace(TextDisplay, "%p", Info.PlayerName);
  TextDisplay = Replace(TextDisplay, "%h", HealthPlayerAck[Info.PlayerID]);
  TextDisplay = Replace(TextDisplay, "%s", int(Info.Score));

  if (Len(TextDisplay) > 0) {
    TextureCanvas.TextSize(TextDisplay, WidthText, HeightText, FontPlayers);

    OffsetTopIcon  = OffsetTop  - HeightIcon / 2;
    OffsetLeftIcon = OffsetLeft - WidthIcon  / 2;

    switch (PlayerDisplayAlignHorz) {
      case DisplayAlignHorz_Left:
        OffsetLeftText = OffsetLeftIcon - PlayerDisplayPaddingRight - int(WidthText);
        if (OffsetLeftText < 0)
          OffsetLeftText = OffsetLeftIcon + WidthIcon + PlayerDisplayPaddingLeft;
        break;

      case DisplayAlignHorz_Center:
        OffsetLeftText = OffsetLeft - int(WidthText / 2);
        break;

      case DisplayAlignHorz_Right:
        OffsetLeftText = OffsetLeftIcon + WidthIcon + PlayerDisplayPaddingLeft;
        if (OffsetLeftText + WidthText >= ClientWidth)
          OffsetLeftText = OffsetLeftIcon - PlayerDisplayPaddingRight - int(WidthText);
        break;
      }

    switch (PlayerDisplayAlignVert) {
      case DisplayAlignVert_Top:
        OffsetTopText = OffsetTopIcon - PlayerDisplayPaddingBottom - int(HeightText);
        if (OffsetTopText < 0)
          OffsetTopText = OffsetTopIcon + HeightIcon + PlayerDisplayPaddingTop;
        break;

      case DisplayAlignVert_Middle:
        OffsetTopText = OffsetTop - int(HeightText / 2);
        break;

      case DisplayAlignVert_Bottom:
        OffsetTopText = OffsetTopIcon + HeightIcon + PlayerDisplayPaddingTop;
        if (OffsetTopText + HeightText >= ClientHeight)
          OffsetTopText = OffsetTopIcon - PlayerDisplayPaddingBottom - int(HeightText);
        break;
      }

    TextureCanvas.DrawColoredText(OffsetLeftText, OffsetTopText,
                                  TextDisplay, FontPlayers, FadeColor(FontPlayersColor, Fade));
    }
  }


// ============================================================================
// DrawIcon
//
// Draws the player's icon on the screen with the given parameters at the given
// position.
// ============================================================================

simulated function DrawIcon(ScriptedTexture TextureCanvas, PlayerReplicationInfo Info,
                            int OffsetLeft, int OffsetTop, float Fade) {

  local int OffsetTopIconSource;
  local int OffsetLeftIconSource;
  local int OffsetTopIcon;
  local int OffsetLeftIcon;

  if (PlayerIcons == None)
    return;

  OffsetTopIconSource  = 0;
  OffsetLeftIconSource = 0;

  switch (PlayerIconsType) {
    case IconsType_Teams:
      if (Info.Team <= 4)
        OffsetLeftIconSource = PlayerIconsWidth + Info.Team * PlayerIconsWidth;
      break;

    case IconsType_Classes:
      if (Info == PlayerLocal.PlayerReplicationInfo)
        OffsetLeftIconSource = 0;
      else if (PlayerLocal.GameReplicationInfo.bTeamGame && Info.Team == PlayerLocal.PlayerReplicationInfo.Team)
        OffsetLeftIconSource = PlayerIconsWidth * 2;
      else
        OffsetLeftIconSource = PlayerIconsWidth;
      break;
    }

  if (FlagPlayerVisibleAck[Info.PlayerID] == 0)
    OffsetTopIconSource = PlayerIconsHeight;

  OffsetTopIcon  = OffsetTop  - PlayerIconsHeight / 2;
  OffsetLeftIcon = OffsetLeft - PlayerIconsWidth  / 2;

  TextureCanvas.DrawTile(OffsetLeftIcon,        OffsetTopIcon,        PlayerIconsWidth, PlayerIconsHeight,
                         OffsetLeftIconSource,  OffsetTopIconSource,  PlayerIconsWidth, PlayerIconsHeight,
                         PlayerIcons,
                         PlayerIcons.bMasked);
  }


// ============================================================================
// IsDisplayed
//
// Returns whether a player with the given parameters is displayed.
// ============================================================================

simulated function bool IsDisplayed(PlayerReplicationInfo Info) {

  return !Info.bIsSpectator &&

         (ShowDead || HealthPlayerAck[Info.PlayerID] > 0) &&
         (ShowSelf || Info != PlayerLocal.PlayerReplicationInfo) &&

         ((ZoneDisplay == ZoneDisplay_Inside &&
            ((ZoneClass == None ||  ZonePlayerAck[Info.PlayerID].IsA(ZoneClass.Name)) &&
             (Zone      == None ||  ZonePlayerAck[Info.PlayerID] == Zone))) ||
          (ZoneDisplay == ZoneDisplay_Outside &&
            ((ZoneClass == None || !ZonePlayerAck[Info.PlayerID].IsA(ZoneClass.Name)) &&
             (Zone      == None ||  ZonePlayerAck[Info.PlayerID] != Zone)))) &&

         ((Info.Team ==   0 && ShowRed     && (FlagPlayerVisibleAck[Info.PlayerID] != 0 || ShowRedInvisible))   ||
          (Info.Team ==   1 && ShowBlue    && (FlagPlayerVisibleAck[Info.PlayerID] != 0 || ShowBlueInvisible))  ||
          (Info.Team ==   2 && ShowGreen   && (FlagPlayerVisibleAck[Info.PlayerID] != 0 || ShowGreenInvisible)) ||
          (Info.Team ==   3 && ShowGold    && (FlagPlayerVisibleAck[Info.PlayerID] != 0 || ShowGoldInvisible))  ||
          (Info.Team == 255 && ShowNeutral && (FlagPlayerVisibleAck[Info.PlayerID] != 0 || ShowNeutralInvisible)));
  }


// ============================================================================
// Component
//
// Returns the selected component of a vector.
// ============================================================================

simulated function int Component(vector Location, EnumCoordSelection Selection) {

  switch (Selection) {
    case CoordSelection_X:  return Location.X;
    case CoordSelection_Y:  return Location.Y;
    case CoordSelection_Z:  return Location.Z;
    }
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    FontPlayers=Font'ScreenFonts.Tahoma10'
    FontPlayersColor=(R=192,G=192,B=192,A=0)//,
    PlayerIcons=Texture'ScriptedAiPlayerIcons'
    PlayerIconsWidth=3
    PlayerIconsHeight=3
    PlayerDisplay="%p (%h)"
    PlayerDisplayAlignHorz=2
    PlayerDisplayAlignVert=1
    PlayerDisplayPaddingLeft=2
    PlayerDisplayPaddingRight=1
    ShowNeutral=True
    ShowRed=True
    ShowBlue=True
    ShowGreen=True
    ShowGold=True
    ShowNeutralInvisible=True
    ShowRedInvisible=True
    ShowBlueInvisible=True
    ShowGreenInvisible=True
    ShowGoldInvisible=True
    ShowSelf=True
    MapTop=-1280
    MapLeft=-1280
    MapRight=1280
    MapBottom=1280
    CoordVert=1
    CoordDepth=2
    UpdateSound=Sound'Botpack.Translocator.ReturnTarget'
    UpdateSoundVolume=0.50
    TimeCreate=-1.00
    TimeTick=-1.00
    ClientWidth=256
    ClientHeight=256
    ClientPaddingTop=0
    ClientPaddingLeft=0
    ClientPaddingRight=0
    ClientPaddingBottom=0
    bAlwaysRelevant=True
    //FIXME: CorpArmstrong, uncomment this later. Texture=Texture'ActorSlideMap'
}
