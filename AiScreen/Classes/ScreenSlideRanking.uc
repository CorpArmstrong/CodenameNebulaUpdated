// ============================================================================
// ScreenSlideRanking
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlide that displays the current player ranking.
// ============================================================================


class ScreenSlideRanking extends ScreenSlide;


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorSlideRanking.bmp mips=off flags=2

#exec obj load file=Textures\ScreenFonts.utx package=ScreenFonts


// ============================================================================
// Properties
// ============================================================================

var() int EntryCount;
var() int EntryHeight;
var() int EntryPadding;

var() string Caption;
var() bool CaptionCaps;
var() Font CaptionFont;
var() Color CaptionColor;
var() bool CaptionColorTeam;

var() string Info;
var() bool InfoCaps;
var() Font InfoFont;
var() Color InfoColor;

var() bool ShowNeutral;
var() bool ShowRed;
var() bool ShowBlue;
var() bool ShowGreen;
var() bool ShowGold;


// ============================================================================
// Variables
// ============================================================================

var PlayerPawn PlayerLocal;

var float TimeUpdated;
var int CountRanked;
var PlayerReplicationInfo InfoPlayerRanked[32];


// ============================================================================
// Prepare
// ============================================================================

simulated function Prepare(ScriptedTexture TextureCanvas) {

  if (TimeUpdated == 0.0 || Level.TimeSeconds - TimeUpdated >= 0.1) {
    Rank();
    TimeUpdated = Level.TimeSeconds;
    }

  if (CountRanked > 0)
    ClientHeight = CountRanked * EntryHeight + (CountRanked - 1) * EntryPadding;
  else
    ClientHeight = 0;
  }


// ============================================================================
// Rank
//
// Determines the current player rankings and fills the global variables with
// this information. This function isn't necessarily called each time the slide
// is rendered.
// ============================================================================

simulated function Rank() {

  local GameReplicationInfo InfoGame;
  local PlayerReplicationInfo InfoPlayerSwap;
  local PlayerReplicationInfo ThisInfo;
  local int IndexInfo;
  local int IndexInfoInsert;
  local int IndexInfoShift;

  if (PlayerLocal == None)
    foreach AllActors(class 'PlayerPawn', PlayerLocal)
      if (Viewport(PlayerLocal.Player) != None)
        break;

  InfoGame = PlayerLocal.GameReplicationInfo;
  if (InfoGame == None)
    return;
  
  CountRanked = 0;

  for (IndexInfo = 0; IndexInfo < ArrayCount(InfoGame.PRIArray); IndexInfo++) {
    ThisInfo = InfoGame.PRIArray[IndexInfo];
    if (ThisInfo == None)
      break;
    
    if ((ThisInfo.bIsSpectator && !ThisInfo.bWaitingPlayer) || !RankInclude(ThisInfo))
      continue;

    for (IndexInfoInsert = CountRanked; IndexInfoInsert > 0; IndexInfoInsert--)
      if (RankCompare(InfoPlayerRanked[IndexInfoInsert - 1], ThisInfo) > 0)
        break;

    for (IndexInfoShift = CountRanked; IndexInfoShift > IndexInfoInsert; IndexInfoShift--)
      InfoPlayerRanked[IndexInfoShift] = InfoPlayerRanked[IndexInfoShift - 1];

    InfoPlayerRanked[IndexInfoInsert] = ThisInfo;
    CountRanked++;
    }

  CountRanked = Min(CountRanked, EntryCount);
  }


// ============================================================================
// RankInclude
//
// Returns whether this player should be included in the ranking.
// ============================================================================

simulated function bool RankInclude(PlayerReplicationInfo Info) {

  return (Info.Team ==   0 && ShowRed)   ||
         (Info.Team ==   1 && ShowBlue)  ||
         (Info.Team ==   2 && ShowGreen) ||
         (Info.Team ==   3 && ShowGold)  ||
         (Info.Team == 255 && ShowNeutral);
  }


// ============================================================================
// RankCompare
//
// Compares two players and returns a positive value if the first item is
// larger than the second, a negative value if the first item is smaller than
// the second, or zero if both are equal. 
// ============================================================================

simulated function int RankCompare(PlayerReplicationInfo InfoFirst, PlayerReplicationInfo InfoSecond) {

  if (InfoFirst.Score >  InfoSecond.Score ||
     (InfoFirst.Score == InfoSecond.Score &&
       (InfoFirst.Deaths <  InfoSecond.Deaths ||
       (InfoFirst.Deaths == InfoSecond.Deaths &&
         (InfoFirst.PlayerID < InfoSecond.PlayerID)))))
    return 1;
  
  return -1;
  }


// ============================================================================
// Draw
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int Left, int Top, float Fade) {

  local int IndexPawn;
  local int IndexRanked;
  local int PositionTop;
  local int TimePlayer;
  local float HeightTextCaption;
  local float HeightTextInfo;
  local float WidthText;
  local string TextInfo;
  local string TextCaption;
  local Color ColorCaption;

  if (CountRanked <= 0)
    return;
 
  TextureCanvas.TextSize("X", WidthText, HeightTextCaption, CaptionFont);
  TextureCanvas.TextSize("X", WidthText, HeightTextInfo, InfoFont);

  PositionTop = Top;
  
  for (IndexRanked = 0; IndexRanked < CountRanked; IndexRanked++) {
    if (InfoPlayerRanked[IndexRanked].TalkTexture != None)
      TextureCanvas.DrawTile(Left, PositionTop, EntryHeight, EntryHeight,
                             0, 0,
                             InfoPlayerRanked[IndexRanked].TalkTexture.USize,
                             InfoPlayerRanked[IndexRanked].TalkTexture.VSize,
                             InfoPlayerRanked[IndexRanked].TalkTexture,
                             InfoPlayerRanked[IndexRanked].TalkTexture.bMasked);

    TimePlayer = (Level.TimeSeconds + PlayerLocal.PlayerReplicationInfo.StartTime - 
                  InfoPlayerRanked[IndexRanked].StartTime) / 60;

    ColorCaption = CaptionColor;
    if (CaptionColorTeam)
      switch (InfoPlayerRanked[IndexRanked].Team) {
        case 0: ColorCaption.R = 255; ColorCaption.G =   0; ColorCaption.B =   0; break;
        case 1: ColorCaption.R =   0; ColorCaption.G =   0; ColorCaption.B = 255; break;
        case 2: ColorCaption.R =   0; ColorCaption.G = 255; ColorCaption.B =   0; break;
        case 3: ColorCaption.R = 255; ColorCaption.G = 255; ColorCaption.B =   0; break;
        }

    TextCaption = Caption;
    TextCaption = Replace(TextCaption, "%p", InfoPlayerRanked[IndexRanked].PlayerName);
    TextCaption = Replace(TextCaption, "%s", int(InfoPlayerRanked[IndexRanked].Score));
    TextCaption = Replace(TextCaption, "%d", int(InfoPlayerRanked[IndexRanked].Deaths));
    TextCaption = Replace(TextCaption, "%t", TimePlayer);
    
    if (CaptionCaps)
      TextCaption = Caps(TextCaption);

    TextureCanvas.DrawColoredText(Left + EntryHeight + 16, PositionTop,
                                  TextCaption, CaptionFont, FadeColor(ColorCaption, Fade));

    TextInfo = Info;
    TextInfo = Replace(TextInfo, "%p", InfoPlayerRanked[IndexRanked].PlayerName);
    TextInfo = Replace(TextInfo, "%s", int(InfoPlayerRanked[IndexRanked].Score));
    TextInfo = Replace(TextInfo, "%d", int(InfoPlayerRanked[IndexRanked].Deaths));
    TextInfo = Replace(TextInfo, "%t", TimePlayer);

    if (InfoCaps)
      TextInfo = Caps(TextInfo);

    TextureCanvas.DrawColoredText(Left + EntryHeight + 16,
                                  PositionTop + EntryHeight - HeightTextInfo,
                                  TextInfo, InfoFont, FadeColor(InfoColor, Fade));

    PositionTop += EntryHeight + EntryPadding;
    }
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    EntryCount=3
    EntryHeight=32
    EntryPadding=16
    Caption="%p"
    CaptionFont=Font'ScreenFonts.TahomaB20'
    CaptionColor=(R=192,G=192,B=192,A=0),
    CaptionColorTeam=True
    Info="%s frags, %d deaths, %t min"
    InfoFont=Font'ScreenFonts.Tahoma10'
    InfoColor=(R=192,G=192,B=192,A=0),
    ShowNeutral=True
    ShowRed=True
    ShowBlue=True
    ShowGreen=True
    ShowGold=True
    bAlwaysRelevant=True
    Texture=Texture'ActorSlideRanking'
}
