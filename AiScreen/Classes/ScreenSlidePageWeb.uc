// ============================================================================
// ScreenSlidePageWeb
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlidePage that gets its data dynamically from the web.
// ============================================================================


class ScreenSlidePageWeb extends ScreenSlidePage perobjectconfig;


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorSlidePageWeb.bmp mips=off flags=2


// ============================================================================
// Replication
// ============================================================================

replication {

  reliable if (Role == ROLE_Authority)
    VersionLatest,
    AddressHost, AddressPort, AddressPath;
  }


// ============================================================================
// Properties
// ============================================================================

var() string AddressHost;
var() int AddressPort;
var() string AddressPath;

var() bool Cached;
var() bool NetworkGameOnly;


// ============================================================================
// Configuration
// ============================================================================

var config string CacheText[32];


// ============================================================================
// Variables
// ============================================================================

var PlayerPawn PlayerLocal;

var ScreenTcpLinkWeb Link;
var ScreenMutator MutatorScreen;

var int VersionLatest;
var int VersionCurrent;
var bool FlagCached;
var bool FlagReloading;


// ============================================================================
// PreBeginPlay
// ============================================================================

simulated function PreBeginPlay() {

  Super.PreBeginPlay();

  if (Cached)
    CacheLoad();

  FlagCached = class 'Screen'.default.Network == ConfigNetwork_Never ||
    (Level.NetMode == NM_Standalone &&
      (NetworkGameOnly || class 'Screen'.default.Network == ConfigNetwork_Network)) ||
    (Level.NetMode == NM_DedicatedServer);

  VersionCurrent = -1;
  }


// ============================================================================
// Tick
// ============================================================================

simulated function Tick(float TimeDelta) {

  Super.Tick(TimeDelta);

  if (PlayerLocal == None)
    foreach AllActors(class 'PlayerPawn', PlayerLocal)
      if (Viewport(PlayerLocal.Player) != None)
        break;

  if (VersionLatest > VersionCurrent && PlayerLocal != None)
    Reload();
  }


// ============================================================================
// Trigger
// ============================================================================

function Trigger(Actor Other, Pawn EventInstigator) {

  Super.Trigger(Other, EventInstigator);

  VersionLatest++;
  }


// ============================================================================
// Draw
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int Left, int Top, float Fade) {

  if (MutatorScreen == None)
    foreach AllActors(class 'ScreenMutator', MutatorScreen)
      break;

  //  CorpArmstrong
  if (FlagCached)
    //MutatorAiDisplayCached();


  Super.Draw(TextureCanvas, Left, Top, Fade);
  }


// ============================================================================
// Reload
//
// Reloads the slide's content.
// ============================================================================

simulated function Reload() {

  if (FlagReloading)
    return;

  VersionCurrent = VersionLatest;

  if (FlagCached)
    return;

  FlagReloading = true;

  Link = PlayerLocal.GetEntryLevel().Spawn(class 'ScreenTcpLinkWeb');
  Link.Page = Self;
  Link.AddressHost = AddressHost;
  Link.AddressPort = AddressPort;
  Link.AddressPath = AddressPath;

  Link.Start();
  }


// ============================================================================
// CacheLoad
//
// Retrieves all information from the cache.
// ============================================================================

simulated function CacheLoad() {

  local string TextChunk;
  local string TextEscaped;
  local int IndexChar;
  local int IndexSlot;

  for (IndexSlot = 0; IndexSlot < ArrayCount(CacheText); IndexSlot++) {
    TextChunk = CacheText[IndexSlot];
    if (Left (TextChunk, 1) == "\"") TextChunk = Mid (TextChunk, 1);
    if (Right(TextChunk, 1) == "\"") TextChunk = Left(TextChunk, Len(TextChunk) - 1);
    CacheText[IndexSlot] = "\"" $ TextChunk $ "\"";

    TextEscaped = TextEscaped $ TextChunk;
    }

  while (true) {
    IndexChar = InStrFrom(IndexChar, TextEscaped, "\\");
    if (IndexChar < 0)
      break;

    switch (Mid(TextEscaped, IndexChar + 1, 1)) {
      case "n":  TextEscaped = Left(TextEscaped, IndexChar) $ Chr(10) $ Mid(TextEscaped, IndexChar + 2); break;
      case "r":  TextEscaped = Left(TextEscaped, IndexChar) $ Chr(13) $ Mid(TextEscaped, IndexChar + 2); break;
      case "q":  TextEscaped = Left(TextEscaped, IndexChar) $ "\""    $ Mid(TextEscaped, IndexChar + 2); break;
      default:   TextEscaped = Left(TextEscaped, IndexChar) $           Mid(TextEscaped, IndexChar + 1); break;
      }

    IndexChar++;
    }

  if (Len(TextEscaped) > 0)
    Text = TextEscaped;

  SaveConfig();
  }


// ============================================================================
// CacheSave
//
// Saves all cacheable information in a, well, cache.
// ============================================================================

simulated function CacheSave() {

  local string TextEscaped;
  local int IndexChar;
  local int IndexSlot;

  TextEscaped = Text;

  while (true) {
    IndexChar = InStrFrom(IndexChar, TextEscaped, "\\");
    if (IndexChar < 0)
      break;
    TextEscaped = Left(TextEscaped, IndexChar) $ "\\\\" $ Mid(TextEscaped, IndexChar + 1);
    IndexChar += 2;
    }

  while (true) {
    IndexChar = InStr(TextEscaped, Chr(10));
    if (IndexChar < 0)
      break;
    TextEscaped = Left(TextEscaped, IndexChar) $ "\\n" $ Mid(TextEscaped, IndexChar + 1);
    }

  while (true) {
    IndexChar = InStr(TextEscaped, Chr(13));
    if (IndexChar < 0)
      break;
    TextEscaped = Left(TextEscaped, IndexChar) $ "\\r" $ Mid(TextEscaped, IndexChar + 1);
    }

  while (true) {
    IndexChar = InStr(TextEscaped, "\"");
    if (IndexChar < 0)
      break;
    TextEscaped = Left(TextEscaped, IndexChar) $ "\\q" $ Mid(TextEscaped, IndexChar + 1);
    }

  IndexChar = 0;
  for (IndexSlot = 0; IndexSlot < ArrayCount(CacheText); IndexSlot++) {
    CacheText[IndexSlot] = "\"" $ Mid(TextEscaped, IndexChar, 1022) $ "\"";
    IndexChar += 1022;
    }

  SaveConfig();
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    AddressHost="mb.link-m.de"
    AddressPort=80
    AddressPath="/screen/news.html"
    Cached=True
    NetworkGameOnly=True
    Text="<p align=center><font color=gray>[No Data]</font></p>"
    bAlwaysTick=True
    RemoteRole=2

    //FIXME Textures: CorpArmstrong
	//Texture=Texture'ActorSlidePageWeb'
	Texture=Texture'Engine.S_Trigger'
}
