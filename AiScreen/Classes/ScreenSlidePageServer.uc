// ============================================================================
// ScreenSlidePageServer
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlidePage that displays information about a game server.
// ============================================================================


class ScreenSlidePageServer extends ScreenSlidePage;


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorSlidePageServer.bmp mips=off flags=2


// ============================================================================
// Replication
// ============================================================================

replication {

  reliable if (Role == ROLE_Authority)
    VersionLatest,
    AddressServer, AddressPort;
  }


// ============================================================================
// Structures
// ============================================================================

struct TPlayer {

  var int Id;
  var string Name;
  var int Score;
  var int Ping;
  var int Team;
  };


// ============================================================================
// Enumerations
// ============================================================================

enum EnumPlayersSort {

  PlayersSort_Id,
  PlayersSort_Name,
  PlayersSort_Score,
  PlayersSort_Ping,
  PlayersSort_Team,
  };


// ============================================================================
// Properties
// ============================================================================

var() string AddressServer;
var() int AddressPort;

var() string Template;
var() string TemplatePlayer;

var() int PlayersCount;
var() EnumPlayersSort PlayersSort;
var() bool PlayersSortReverse;

var() bool NetworkGameOnly;


// ============================================================================
// Variables
// ============================================================================

var PlayerPawn PlayerLocal;
var ScreenUdpLinkServer Link;

var string TextResult;
var int CountPlayers;
var TPlayer Players[32];

var int VersionLatest;
var int VersionCurrent;
var bool FlagDisabled;
var bool FlagReloading;


// ============================================================================
// PreBeginPlay
// ============================================================================

simulated event PreBeginPlay() {

  Super.PreBeginPlay();

  FlagDisabled = class 'Screen'.default.Network == ConfigNetwork_Never ||
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
// Reload
//
// Reloads the slide's content.
// ============================================================================

simulated function Reload() {

  if (FlagReloading)
    return;

  VersionCurrent = VersionLatest;

  if (FlagDisabled || AddressServer == "")
    return;

  FlagReloading = true;

  Link = PlayerLocal.GetEntryLevel().Spawn(class 'ScreenUdpLinkServer');
  Link.Page = Self;
  Link.AddressServer = AddressServer;
  Link.AddressPort   = AddressPort;
  
  CountPlayers = 0;
  
  Link.GetInfoServer();
  }


// ============================================================================
// ReceiveInfoServer
//
// Called by ScreenUdpLinkServer when server info is received.
// ============================================================================

simulated function ReceiveInfoServer(string TextInfo) {

  TextResult = Template;
  
  TextResult = Replace(TextResult, "%sn", GetItem(TextInfo, "hostname"));
  TextResult = Replace(TextResult, "%sp", GetItem(TextInfo, "hostport"));

  TextResult = Replace(TextResult, "%mt", GetItem(TextInfo, "maptitle"));
  TextResult = Replace(TextResult, "%mn", GetItem(TextInfo, "mapname"));

  TextResult = Replace(TextResult, "%gt", GetItem(TextInfo, "gametype"));

  TextResult = Replace(TextResult, "%pn", GetItem(TextInfo, "numplayers"));
  TextResult = Replace(TextResult, "%pm", GetItem(TextInfo, "maxplayers"));

  if (InStr(Template, "%pl") >= 0 ||
      InStr(Template, "%gs") >= 0 ||
      InStr(Template, "%a")  >= 0)
    Link.GetInfoGame();

  else {
    Text = TextResult;

    Link.Destroy();
    }
  }


// ============================================================================
// ReceiveInfoGame
//
// Called by ScreenUdpLinkServer when game info is received.
// ============================================================================

simulated function ReceiveInfoGame(string TextInfo) {

  local int IdPlayer;
  local int IndexCharSeparator;
  local int IndexPlayer;
  local string TextItemName;
  local string TextPlayer;
  local string TextPlayerList;

  while (TextInfo != "") {
    TextItemName = GetItemNext(TextInfo);
    IndexCharSeparator = InStr(TextItemName, "_");
  
    if (IndexCharSeparator >= 0) {
      IdPlayer = int(Mid(TextItemName, IndexCharSeparator + 1));
      TextItemName = Left(TextItemName, IndexCharSeparator + 1);
      }
  
    switch (Caps(TextItemName)) {
      case "GAMESTYLE":   TextResult = Replace(TextResult, "%gs", GetItemNext(TextInfo));  break;
      case "ADMINNAME":   TextResult = Replace(TextResult, "%an", GetItemNext(TextInfo));  break;
      case "ADMINEMAIL":  TextResult = Replace(TextResult, "%am", GetItemNext(TextInfo));  break;
    
      case "PLAYER_":  Players[GetPlayerIndex(IdPlayer)].Name  =     GetItemNext(TextInfo);   break;
      case "FRAGS_":   Players[GetPlayerIndex(IdPlayer)].Score = int(GetItemNext(TextInfo));  break;
      case "PING_":    Players[GetPlayerIndex(IdPlayer)].Ping  = int(GetItemNext(TextInfo));  break;
      case "TEAM_":    Players[GetPlayerIndex(IdPlayer)].Team  = int(GetItemNext(TextInfo));  break;

      case "FINAL":
        PlayersSorting();

        for (IndexPlayer = 0; IndexPlayer < Min(CountPlayers, PlayersCount); IndexPlayer++) {
          TextPlayer = TemplatePlayer;
          
          TextPlayer = Replace(TextPlayer, "%pi", Players[IndexPlayer].Id);
          TextPlayer = Replace(TextPlayer, "%pp", Players[IndexPlayer].Name);
          TextPlayer = Replace(TextPlayer, "%ps", Players[IndexPlayer].Score);
          TextPlayer = Replace(TextPlayer, "%pr", Players[IndexPlayer].Ping);
          TextPlayer = Replace(TextPlayer, "%pt", Players[IndexPlayer].Team);
          
          switch (Players[IndexPlayer].Team) {
            case   0:  TextPlayer = Replace(TextPlayer, "%pc", "red");     break;
            case   1:  TextPlayer = Replace(TextPlayer, "%pc", "blue");    break;
            case   2:  TextPlayer = Replace(TextPlayer, "%pc", "green");   break;
            case   3:  TextPlayer = Replace(TextPlayer, "%pc", "yellow");  break;
            case 255:  TextPlayer = Replace(TextPlayer, "%pc", "gray");    break;
            }
          
          TextPlayerList = TextPlayerList $ TextPlayer;
          }
      
        TextResult = Replace(TextResult, "%pl", TextPlayerList);
        Text = TextResult;

        Link.Destroy();
        break;
    
      default:
        GetItemNext(TextInfo);
        break;
      }
    }
  }


// ============================================================================
// Timeout
//
// Called by ScreenUdpLinkServer when a query times out.
// ============================================================================

simulated function Timeout() {

  Link.Destroy();
  }


// ============================================================================
// PlayersSorting
//
// Sorts the array of players according to the current sorting criteria.
// ============================================================================

simulated function PlayersSorting() {

  local int IndexPlayer1;
  local int IndexPlayer2;

  for (IndexPlayer1 = 0; IndexPlayer1 < CountPlayers - 1; IndexPlayer1++)
    for (IndexPlayer2 = CountPlayers - 1; IndexPlayer2 > IndexPlayer1; IndexPlayer2--)
      if (PlayersCompare(Players[IndexPlayer2], Players[IndexPlayer1]))
        PlayersSwap(Players[IndexPlayer2], Players[IndexPlayer1]);
  }


// ============================================================================
// PlayersCompare
//
// Compares the given two players according to the current sorting criteria.
// Returns whether the first should be sorted before the second.
// ============================================================================

simulated function bool PlayersCompare(TPlayer Player1, TPlayer Player2) {

  local bool Result;

  switch (PlayersSort) {
    case PlayersSort_Id:
      Result = (Player1.Id < Player2.Id);
      break;
    
    case PlayersSort_Name:
      Result = (Caps(Player1.Name) < Caps(Player2.Name));
      break;
    
    case PlayersSort_Score:
      Result = (Player1.Score <  Player2.Score) ||
               (Player1.Score == Player2.Score &&
                 (Caps(Player1.Name) < Caps(Player2.Name)));
      break;

    case PlayersSort_Ping:
      Result = (Player1.Ping <  Player2.Ping) ||
               (Player1.Ping == Player2.Ping &&
                 (Caps(Player1.Name) < Caps(Player2.Name)));
      break;

    case PlayersSort_Team:
      Result = (Player1.Team <  Player2.Team) ||
               (Player1.Team == Player2.Team &&
                 (Caps(Player1.Name) < Caps(Player2.Name)));
      break;
    }

  return (Result != PlayersSortReverse);
  }


// ============================================================================
// PlayersSwap
//
// Swaps the given two players.
// ============================================================================

simulated final function PlayersSwap(out TPlayer Player1, out TPlayer Player2) {

  local TPlayer PlayerTemp;
  
  PlayerTemp = Player1;
  Player1 = Player2;
  Player2 = PlayerTemp;
  }


// ============================================================================
// GetPlayerIndex
//
// Returns the index of a player info array entry corresponding to the given
// player id. If such an entry isn't found, clears and initializes a new one
// and returns its index.
// ============================================================================

simulated function int GetPlayerIndex(int Id) {

  local int IndexPlayer;
  
  for (IndexPlayer = 0; IndexPlayer < CountPlayers; IndexPlayer++)
    if (Players[IndexPlayer].Id == Id)
      return IndexPlayer;

  Players[CountPlayers].Id    = Id;
  Players[CountPlayers].Name  = "";
  Players[CountPlayers].Score = 0;
  Players[CountPlayers].Ping  = 0;
  Players[CountPlayers].Team  = 255;
  
  return CountPlayers++;
  }


// ============================================================================
// GetItem
//
// Gets a named item from the given list of items. If the item isn't present,
// returns the given default value instead.
// ============================================================================

simulated function string GetItem(string TextItems, string TextName, optional string TextDefault) {

  local int IndexChar;
  
  IndexChar = InStr(Caps(TextItems), "\\" $ Caps(TextName) $ "\\");
  if (IndexChar < 0)
    return TextDefault;
  
  TextItems = Mid(TextItems, IndexChar + Len(TextName) + 2);
  
  return GetItemNext(TextItems);
  }


// ============================================================================
// GetItemNext
//
// Gets the next item name or value from the given list of items, returns it
// and removes it from the list.
// ============================================================================

simulated function string GetItemNext(out string TextItems) {

  local int IndexChar;
  local string TextItem;

  if (Left(TextItems, 1) == "\\")
    TextItems = Mid(TextItems, 1);

  IndexChar = InStr(TextItems $ "\\", "\\");
  
  TextItem = Left(TextItems, IndexChar);
  TextItems = Mid(TextItems, IndexChar + 1);
  
  return TextItem;
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    AddressPort=7778
    Template="<p><b>%mt</b> (%gt)<br><font color=gray>%sn</font></p><p>%pn people playing (%pm players max)</font></p><p>%pl</p>"
    TemplatePlayer="<font color=%pc><b>%pp</b></font> <font color=gray>(%ps frags)</font><br>"
    PlayersCount=32
    PlayersSort=4
    NetworkGameOnly=True
    Text="<p align=center><font color=gray>[No Information]</font></p>"
    Texture=Texture'ActorSlidePageServer'
}
