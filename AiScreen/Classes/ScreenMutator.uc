// ============================================================================
// ScreenMutator
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Displays stuff on the user's heads-up display.
// ============================================================================


class ScreenMutator extends AMutator;


// ============================================================================
// Compiler Directives
// ============================================================================

// DEPRECATED!
//#exec obj load file=Textures\ScreenFonts.utx package=ScreenFonts

#exec Font Import File=Textures\Tahoma10.pcx Name=Tahoma10
#exec Font Import File=Textures\TahomaB10.pcx Name=TahomaB10

// ============================================================================
// Constants
// ============================================================================

const TimeDisplay = 15.0;
const TimeFade = 3.0;


// ============================================================================
// Variables
// ============================================================================

var float TimeLast;
var Font FontDisplayNormal;
var Font FontDisplayBold;

var Color ColorDisplayBlue;
var Color ColorDisplayWhite;
var Color ColorDisplayGray;

var bool FlagDisplayVersion;
var float TimeDisplayVersion;
var int VersionDisplayClient;
var int VersionDisplayServer;

var bool FlagDisplayCached;


// ============================================================================
// Spawned
// ============================================================================

simulated function Spawned() {

  FontDisplayNormal = Font'Tahoma10';
  FontDisplayBold   = Font'TahomaB10';

  ColorDisplayWhite.R = 224;
  ColorDisplayWhite.G = 224;
  ColorDisplayWhite.B = 224;

  ColorDisplayBlue.R  =  28;
  ColorDisplayBlue.G  =  58;
  ColorDisplayBlue.B  = 127;

  ColorDisplayGray.R  =  64;
  ColorDisplayGray.G  =  64;
  ColorDisplayGray.B  =  64;
  }


// ============================================================================
// ModifyPlayer
// ============================================================================

function ModifyPlayer(Pawn PawnPlayer) {

  local ScreenClient ThisClient;

  Super.ModifyPlayer(PawnPlayer);

  foreach AllActors(class 'ScreenClient', ThisClient)
    if (ThisClient.Owner == PawnPlayer)
      return;

  PawnPlayer.Spawn(class 'ScreenClient', PawnPlayer);
  }



// ============================================================================
// MutatorTeamMessage
// ============================================================================
function bool MutatorTeamMessage(Actor ActorSender, Pawn PawnReceiver, PlayerReplicationInfo Info, coerce string TextMessage, name NameType, optional bool FlagBeep) {

  local ScreenClient ThisClient;

  if (ActorSender == PawnReceiver)
    foreach AllActors(class 'ScreenClient', ThisClient)
      if (ThisClient.Owner == ActorSender)
        ThisClient.Say(TextMessage, NameType);

  return Super.MutatorTeamMessage(ActorSender, PawnReceiver, Info, TextMessage, NameType, FlagBeep);
  }

// ============================================================================
// PostRender
// ============================================================================

simulated function PostRender(canvas Canvas) {

  local float TimeDelta;
  local float FactorOpacity;
  local float WidthText;
  local float HeightText;
  local int CoordTopText;

  if (TimeLast > 0.0)
    TimeDelta = Level.TimeSeconds - TimeLast;
  TimeLast = Level.TimeSeconds;

  if (FlagDisplayVersion) {
    TimeDisplayVersion += TimeDelta;

    Canvas.Font = FontDisplayNormal;
    Canvas.Style = ERenderStyle.STY_Translucent;

    FactorOpacity = 1.0;
    if (TimeDisplayVersion > TimeDisplay)
      FactorOpacity = FMax(0.0, 1.0 - (TimeDisplayVersion - TimeDisplay) / TimeFade);

    Canvas.DrawColor.R = ColorDisplayWhite.R * FactorOpacity;
    Canvas.DrawColor.G = ColorDisplayWhite.G * FactorOpacity;
    Canvas.DrawColor.B = ColorDisplayWhite.B * FactorOpacity;

    Canvas.TextSize("X", WidthText, HeightText);

    Canvas.CurY = Canvas.ClipY * 0.7;
    FormattedDrawCentered(Canvas, FontDisplayNormal, FontDisplayBold, "This server is running |Screen" @ VersionDisplayServer $ "|.");

    Canvas.CurY += HeightText * 0.6;
    FormattedDrawCentered(Canvas, FontDisplayNormal, FontDisplayBold, "The version of the Screen component installed");
    FormattedDrawCentered(Canvas, FontDisplayNormal, FontDisplayBold, "on your computer, |Screen" @ VersionDisplayClient $ "|, is outdated.");

    Canvas.CurY += HeightText * 0.6;
    FormattedDrawCentered(Canvas, FontDisplayNormal, FontDisplayBold, "Please see the |Configure Screens| dialog in the");
    FormattedDrawCentered(Canvas, FontDisplayNormal, FontDisplayBold, "|Mod| menu for information how to update.");

    if (TimeDisplayVersion > TimeDisplay + TimeFade)
      FlagDisplayVersion = false;
    }

  if (FlagDisplayCached) {
    Canvas.Font = FontDisplayNormal;
    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.DrawColor = ColorDisplayGray;

    Canvas.CurY = 10;
    FormattedDrawCentered(Canvas, FontDisplayNormal, FontDisplayBold, "cached content");

    FlagDisplayCached = false;
    }


	if (NextHUDMutator != None) {
		NextHUDMutator.PostRender(Canvas);
    }
  }


// ============================================================================
// FormattedWidth
//
// Returns the width of basic formatted text.
// ============================================================================

simulated function int FormattedWidth(canvas Canvas, Font FontNormal, Font FontBold, coerce string Text) {

  local bool FlagBold;
  local int IndexCharSeparator;
  local int WidthTextAccu;
  local float WidthText;
  local float HeightText;

  while (Len(Text) > 0) {
    IndexCharSeparator = InStr(Text, "|");
    if (IndexCharSeparator < 0)
      IndexCharSeparator = Len(Text);

    if (FlagBold)
      Canvas.Font = FontBold;
    else
      Canvas.Font = FontNormal;
    FlagBold = !FlagBold;

    Canvas.TextSize(Left(Text, IndexCharSeparator), WidthText, HeightText);
    WidthTextAccu += WidthText;

    Text = Mid(Text, IndexCharSeparator + 1);
    }

  return WidthTextAccu;
  }


// ============================================================================
// FormattedDraw
//
// Draws basic formatted text.
// ============================================================================

simulated function FormattedDraw(canvas Canvas, Font FontNormal, Font FontBold, coerce string Text) {

  local bool FlagBold;
  local int IndexCharSeparator;
  local int CoordTop;
  local int CoordLeft;
  local float WidthText;
  local float HeightText;
  local string TextChunk;

  CoordTop  = Canvas.CurY;
  CoordLeft = Canvas.CurX;

  while (Len(Text) > 0) {
    IndexCharSeparator = InStr(Text, "|");
    if (IndexCharSeparator < 0)
      IndexCharSeparator = Len(Text);

    if (FlagBold)
      Canvas.Font = FontBold;
    else
      Canvas.Font = FontNormal;
    FlagBold = !FlagBold;

    TextChunk = Left(Text, IndexCharSeparator);

    Canvas.SetPos(CoordLeft, CoordTop);
    Canvas.TextSize(TextChunk, WidthText, HeightText);
    Canvas.DrawText(TextChunk);
    CoordLeft += WidthText;

    Text = Mid(Text, IndexCharSeparator + 1);
    }

  Canvas.CurY = CoordTop + HeightText;
  }


// ============================================================================
// FormattedDrawCentered
//
// Draws centered basic formatted text.
// ============================================================================

simulated function FormattedDrawCentered(canvas Canvas, Font FontNormal, Font FontBold, coerce string Text) {

  Canvas.CurX = (Canvas.ClipX - FormattedWidth(Canvas, FontNormal, FontBold, Text)) / 2;
  FormattedDraw(Canvas, FontNormal, FontBold, Text);
  }


// ============================================================================
// DrawTextCentered
//
// Draws centered text on the given canvas at the given vertical position and
// increases the vertical position by the text height.
// ============================================================================

simulated function DrawTextCentered(canvas Canvas, out int CoordTopText, coerce string Text) {

  local float WidthText;
  local float HeightText;

  Canvas.TextSize(Text, WidthText, HeightText);
  Canvas.SetPos((Canvas.ClipX - WidthText) / 2, CoordTopText);
  Canvas.DrawText(Text);

  CoordTopText += HeightText;
  }


// ============================================================================
// DisplayInit
//
// Initializes heads-up display rendering for this mutator. Can be safely
// called multiple times.
// ============================================================================

simulated function DisplayInit() {

  if (bHUDMutator)
    return;

  RegisterHUDMutator();
  TimeLast = Level.TimeSeconds;
  }


// ============================================================================
// DisplayVersion
//
// Displays a heads-up message notifying the user that the server is running a
// newer Screen version.
// ============================================================================

simulated function DisplayVersion(int VersionClient, int VersionServer) {

  DisplayInit();

  FlagDisplayVersion = true;
  TimeDisplayVersion = 0.0;
  VersionDisplayClient = VersionClient;
  VersionDisplayServer = VersionServer;
  }


// ============================================================================
// DisplayCached
//
// Displays a heads-up message notifying the user that they are looking at a
// slide displaying cached content.
// ============================================================================

simulated function DisplayCached() {

  DisplayInit();

  FlagDisplayCached = true;
  }
defaultproperties
{
}
