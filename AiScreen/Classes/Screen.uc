// ============================================================================
// Screen
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Provides an implementation of a ClientScriptedTexture that is able to
// display slides of type ScreenSlide and its subclasses.
// ============================================================================


class Screen extends AiScreen.ClientScriptedTexture config(Screen);


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorAibmp mips=off flags=2


// ============================================================================
// Replication
// ============================================================================

replication {

  reliable if (Role == ROLE_Authority)
    VersionServer;
  reliable if (Role == ROLE_Authority && SwitchTriggered.SlideSwitch != None)
    SwitchTriggered;
  }


// ============================================================================
// Types
// ============================================================================

enum EnumSlideAction {

  SlideAction_None,
  SlideAction_Entering,
  SlideAction_Scrolling,
  SlideAction_Exiting,
  };


enum EnumConfigNetwork {

  ConfigNetwork_Always,
  ConfigNetwork_Network,
  ConfigNetwork_Never,
  };


struct StructSwitch {

  var ScreenSlide SlideSwitch;
  var int Update;
  };


// ============================================================================
// Configuration
// ============================================================================

var config EnumConfigNetwork Network;
var config int VersionLatest;


// ============================================================================
// Properties
// ============================================================================

var() editconst int Version;

var() ScreenSlide SlideCurrent;
var() Texture ScreenBackground;
var() Texture ScreenForeground;

var() int Top;
var() int Left;
var() int Width;
var() int Height;

var() int TileTop;
var() int TileLeft;
var() Screen TileMaster;


// ============================================================================
// Variables
// ============================================================================

var int VersionServer;
var bool FlagVersionAck;

var ScreenMutator MutatorScreen;

var ScreenSlide SlideCurrentAck;
var StructSwitch SwitchTriggered;
var Palette PaletteOriginal;

var EnumSlideAction Action;
var int DirectionHorz;
var int DirectionVert;

var int CountSlides;
var int OffsetTopSlide[32];
var int OffsetLeftSlide[32];

var float TimeDisplayed;

var float Fade;
var float OffsetTop;
var float OffsetLeft;


// ============================================================================
// Constants
// ============================================================================

const FlagDebug = false;


// ============================================================================
// PreBeginPlay
// ============================================================================

simulated function PreBeginPlay()
{
	local GameInfo ThisGame;
	//local AiGameInfo ThisGame;

	Super.PreBeginPlay();

	if (PaletteOriginal == None)
		PaletteOriginal = ScriptedTexture.Palette;

	if (Level.NetMode != NM_Client)
		VersionServer = Version;

	foreach AllActors(class 'ScreenMutator', MutatorScreen)
		break;

	if (MutatorScreen == None)
	{
		MutatorScreen = Spawn(class 'ScreenMutator');

		foreach AllActors(class 'GameInfo', ThisGame)
			break;

		if (ThisGame != None)
		{
			/* @CorpArmstrong
			 * These lines doesn't work, 'cause DeusEx GameInfo
			 * have Mutator of wrong type.
			 * Must be AiMutator but has Mutator.
			 *
			 * ThisGame.BaseMutator.AddMutator(MutatorScreen);
			 * ThisGame.RegisterMessageMutator(MutatorScreen);
			 */

			ThisGame.BaseMutator.AddMutator(MutatorScreen);	// +
			//ThisGame.RegisterMessageMutator(MutatorScreen);	// +
		}
    }
}


// ============================================================================
// Tick
// ============================================================================

simulated function Tick(float TimeDelta) {

  local ScriptedTexture TextureCanvas;
  local bool FlagCompleted;
  local bool FlagCompletedHorz;
  local bool FlagCompletedVert;
  local int IndexSlide;
  local int ClientWidthTotal;
  local int ClientHeightTotal;
  local int ClientWidthDisplayed;
  local int ClientHeightDisplayed;
  local int OffsetTopTarget;
  local int OffsetLeftTarget;
  local int OffsetTopDisplayed;
  local int OffsetLeftDisplayed;
  local int OffsetTopTotal;
  local int OffsetLeftTotal;
  local int OffsetRightTotal;
  local int OffsetBottomTotal;
  local int DirectionVertPrev;
  local int DirectionHorzPrev;
  local int ThisOffsetTop;
  local int ThisOffsetLeft;
  local ScreenSlide ThisSlide;
  local ScreenSlide ThisSlidePrev;
  local EnumSlideAction ActionPrev;

  VersionCheck();

  if (Level.NetMode == NM_DedicatedServer)
    return;

  if (TileMaster != None)
    return;

  TextureCanvas = ScriptedTexture(ScriptedTexture);
  if (TextureCanvas == None)
    return;


  // ================================================================
  // Slides Switched
  // ================================================================

  ActionPrev = Action;

  if (SlideCurrent == None) {
    if (SwitchTriggered.SlideSwitch == None)
      return;

    SlideCurrent = SwitchTriggered.SlideSwitch;
    SlideCurrentAck = None;
    SwitchTriggered.SlideSwitch = None;
    }

  if (SwitchTriggered.SlideSwitch == SlideCurrent && Action != SlideAction_Exiting)
    SwitchTriggered.SlideSwitch = None;

  if (SlideCurrentAck != SlideCurrent) {
    Action = SlideAction_Entering;
    ActionPrev = SlideAction_None;

    SlideCurrentAck = SlideCurrent;
    }


  // ================================================================
  // Calculate Animation
  // ================================================================

  if (SlideCurrent != None) {

    // ====================================================
    // Prepare Slide
    // ====================================================

    SlideCurrent.Prepare(TextureCanvas);

    OffsetTopTotal    = -GetClientHeightTotal(SlideCurrent) / 2;
    OffsetLeftTotal   = -GetClientWidthTotal (SlideCurrent) / 2;
    OffsetRightTotal  =  OffsetLeftTotal + GetClientWidthTotal (SlideCurrent);
    OffsetBottomTotal =  OffsetTopTotal  + GetClientHeightTotal(SlideCurrent);

    ThisOffsetTop  = OffsetTopTotal;
    ThisOffsetLeft = OffsetLeftTotal;

    CountSlides = 1;
    OffsetTopSlide [0] = ThisOffsetTop;
    OffsetLeftSlide[0] = ThisOffsetLeft;

    ThisSlidePrev = SlideCurrent;
    for (ThisSlide = SlideCurrent.SlideOverlay; ThisSlide != None; ThisSlide = ThisSlide.SlideOverlay) {
      if (CountSlides == ArrayCount(OffsetLeftSlide) - 1) {
        Log("Screen: Too many layered slides, starting with slide" @ SlideCurrent.Name);
        break;
        }

      ThisSlide.Prepare(TextureCanvas);

      switch (ThisSlide.AlignHorz) {
        case SlideAlignHorz_Left:
          OffsetRightTotal = Max(OffsetRightTotal, ThisOffsetLeft + GetClientWidthTotal(ThisSlide));
          break;

        case SlideAlignHorz_LeftAdjacent:
          ThisOffsetLeft -= GetClientWidthTotal(ThisSlide);
          OffsetLeftTotal = Min(OffsetLeftTotal, ThisOffsetLeft);
          break;

        case SlideAlignHorz_Center:
          ThisOffsetLeft += (GetClientWidthTotal(ThisSlidePrev) - GetClientWidthTotal(ThisSlide)) / 2;
          OffsetLeftTotal  = Min(OffsetLeftTotal,  ThisOffsetLeft);
          OffsetRightTotal = Max(OffsetRightTotal, ThisOffsetLeft + GetClientWidthTotal(ThisSlide));
          break;

        case SlideAlignHorz_Right:
          ThisOffsetLeft += GetClientWidthTotal(ThisSlidePrev) - GetClientWidthTotal(ThisSlide);
          OffsetLeftTotal = Min(OffsetLeftTotal, ThisOffsetLeft);
          break;

        case SlideAlignHorz_RightAdjacent:
          ThisOffsetLeft += GetClientWidthTotal(ThisSlidePrev);
          OffsetRightTotal = Max(OffsetRightTotal, ThisOffsetLeft + GetClientWidthTotal(ThisSlide));
          break;
        }

      switch (ThisSlide.AlignVert) {
        case SlideAlignVert_Top:
          OffsetBottomTotal = Max(OffsetBottomTotal, ThisOffsetTop + GetClientHeightTotal(ThisSlide));
          break;

        case SlideAlignVert_TopAdjacent:
          ThisOffsetTop -= GetClientHeightTotal(ThisSlide);
          OffsetTopTotal = Min(OffsetTopTotal, ThisOffsetTop);
          break;

        case SlideAlignVert_Middle:
          ThisOffsetTop += (GetClientHeightTotal(ThisSlidePrev) - GetClientHeightTotal(ThisSlide)) / 2;
          OffsetTopTotal    = Min(OffsetTopTotal,    ThisOffsetTop);
          OffsetBottomTotal = Max(OffsetBottomTotal, ThisOffsetTop + GetClientHeightTotal(ThisSlide));
          break;

        case SlideAlignVert_Bottom:
          ThisOffsetTop += GetClientHeightTotal(ThisSlidePrev) - GetClientHeightTotal(ThisSlide);
          OffsetTopTotal = Min(OffsetTopTotal, ThisOffsetTop);
          break;

        case SlideAlignVert_BottomAdjacent:
          ThisOffsetTop += GetClientHeightTotal(ThisSlidePrev);
          OffsetBottomTotal = Max(OffsetBottomTotal, ThisOffsetTop + GetClientHeightTotal(ThisSlide));
          break;
        }

      OffsetTopSlide [CountSlides] = ThisOffsetTop;
      OffsetLeftSlide[CountSlides] = ThisOffsetLeft;
      CountSlides++;

      ThisSlidePrev = ThisSlide;
      }

    for (IndexSlide = 0; IndexSlide < CountSlides; IndexSlide++) {
      OffsetTopSlide [IndexSlide] -= OffsetTopTotal;
      OffsetLeftSlide[IndexSlide] -= OffsetLeftTotal;
      }

    ClientWidthTotal  = OffsetRightTotal  - OffsetLeftTotal;
    ClientHeightTotal = OffsetBottomTotal - OffsetTopTotal;
    ClientWidthDisplayed  = Clamp(ClientWidthTotal,  0, Width);
    ClientHeightDisplayed = Clamp(ClientHeightTotal, 0, Height);

    switch (SlideCurrent.AlignHorz) {
      case SlideAlignHorz_Left:
      case SlideAlignHorz_LeftAdjacent:  OffsetLeftTarget = 0;                           break;
      case SlideAlignHorz_Center:        OffsetLeftTarget = Width / 2 + OffsetLeftTotal; break;
      case SlideAlignHorz_Right:
      case SlideAlignHorz_RightAdjacent: OffsetLeftTarget = Width - ClientWidthTotal;    break;
      }

    switch (SlideCurrent.AlignVert) {
      case SlideAlignVert_Top:
      case SlideAlignVert_TopAdjacent:    OffsetTopTarget = 0;                            break;
      case SlideAlignVert_Middle:         OffsetTopTarget = Height / 2 + OffsetTopTotal;  break;
      case SlideAlignVert_Bottom:
      case SlideAlignVert_BottomAdjacent: OffsetTopTarget = Height - ClientHeightTotal;   break;
      }

    OffsetTopDisplayed  = Clamp(OffsetTopTarget,  0, Height);
    OffsetLeftDisplayed = Clamp(OffsetLeftTarget, 0, Width);

    TimeDisplayed += TimeDelta;


    // ====================================================
    // Scroll Slide
    // ====================================================

    do {
      if (Action != ActionPrev) {
        switch (Action) {
          case SlideAction_Entering:
            Fade = 1.0;
            OffsetLeft = OffsetLeftTarget;
            OffsetTop  = OffsetTopTarget;

            switch (SlideCurrent.EffectEntry) {
              case SlideEffect_Replace:                                      break;
              case SlideEffect_SlideTop:    OffsetTop  =  Height;            break;
              case SlideEffect_SlideLeft:   OffsetLeft =  Width;             break;
              case SlideEffect_SlideRight:  OffsetLeft = -ClientWidthTotal;  break;
              case SlideEffect_SlideBottom: OffsetTop  = -ClientHeightTotal; break;
              case SlideEffect_Fade:        Fade = 0.0;                      break;
              }

            break;

          case SlideAction_Scrolling:
            TimeDisplayed = 0.0;
            DirectionHorz = 1;
            DirectionVert = 1;
            break;
          }

        ActionPrev = Action;
        }

      switch (Action) {

        // ================================================
        // Entry Animation

        case SlideAction_Entering:
          switch (SlideCurrent.EffectEntry) {
            case SlideEffect_Replace:
              FlagCompleted = true;
              break;

            case SlideEffect_SlideTop:
              OffsetTop -= SlideCurrent.EffectEntrySpeed * TimeDelta;
              OffsetTop = FMax(OffsetTop, OffsetTopTarget);
              FlagCompleted = (OffsetTop <= OffsetTopTarget);
              break;

            case SlideEffect_SlideLeft:
              OffsetLeft -= SlideCurrent.EffectEntrySpeed * TimeDelta;
              OffsetLeft = FMax(OffsetLeft, OffsetLeftTarget);
              FlagCompleted = (OffsetLeft <= OffsetLeftTarget);
              break;

            case SlideEffect_SlideRight:
              OffsetLeft += SlideCurrent.EffectEntrySpeed * TimeDelta;
              OffsetLeft = FMin(OffsetLeft, OffsetLeftTarget);
              FlagCompleted = (OffsetLeft >= OffsetLeftTarget);
              break;

            case SlideEffect_SlideBottom:
              OffsetTop += SlideCurrent.EffectEntrySpeed * TimeDelta;
              OffsetTop = FMin(OffsetTop, OffsetTopTarget);
              FlagCompleted = (OffsetTop >= OffsetTopTarget);
              break;

            case SlideEffect_Fade:
              Fade += SlideCurrent.EffectEntrySpeed / 100.0 * TimeDelta;
              Fade = FClamp(Fade, 0.0, 1.0);
              FlagCompleted = (Fade == 1.0);
              break;
            }

          if (FlagCompleted) {
            OffsetTop  = OffsetTopTarget;
            OffsetLeft = OffsetLeftTarget;
            Action = SlideAction_Scrolling;
            }

          break;


        // ================================================
        // Scrolling

        case SlideAction_Scrolling:
          switch (SlideCurrent.ScrollVert) {
            case SlideScroll_None:
              OffsetTop = OffsetTopTarget;
              FlagCompletedVert = true;
              break;

            case SlideScroll_Wrap:
              FlagCompletedVert = (ClientHeightTotal <= Height && OffsetTop == OffsetTopTarget);

              if (!FlagCompletedVert) {
                if (OffsetTop + ClientHeightTotal <= 0)
                  OffsetTop = Height;
                OffsetTop -= SlideCurrent.ScrollVertSpeed * TimeDelta;
                OffsetTop = FMax(OffsetTop, -ClientHeightTotal);

                FlagCompletedVert = (OffsetTop + ClientHeightTotal <= 0);
                }

              break;

            case SlideScroll_Bounce:
              DirectionVertPrev = DirectionVert;

              FlagCompletedVert = (ClientHeightTotal <= Height && OffsetTop == OffsetTopTarget);
              if (!FlagCompletedVert) {
                if (DirectionVert == 1 && OffsetTop + ClientHeightTotal <= OffsetTopDisplayed + ClientHeightDisplayed)
                  DirectionVert = -1;
                else if (DirectionVert == -1 && OffsetTop >= OffsetTopDisplayed)
                  DirectionVert = 1;
                else
                  if (DirectionVert == 1)
                    OffsetTop -= SlideCurrent.ScrollVertSpeed * TimeDelta;
                  else
                    OffsetTop += SlideCurrent.ScrollVertSpeed * TimeDelta;

                OffsetTop = FClamp(OffsetTop, OffsetTopDisplayed + ClientHeightDisplayed - ClientHeightTotal,
                                              OffsetTopDisplayed);

                FlagCompletedVert = (DirectionVert != DirectionVertPrev);
                }

              break;
            }

          switch (SlideCurrent.ScrollHorz) {
            case SlideScroll_None:
              OffsetLeft = OffsetLeftTarget;
              FlagCompletedHorz = true;
              break;

            case SlideScroll_Wrap:
              FlagCompletedHorz = (ClientWidthTotal <= Width && OffsetLeft == OffsetLeftTarget);

              if (!FlagCompletedHorz) {
                if (OffsetLeft + ClientWidthTotal <= 0)
                  OffsetLeft = Width;
                OffsetLeft -= SlideCurrent.ScrollHorzSpeed * TimeDelta;
                OffsetLeft = FMax(OffsetLeft, -ClientWidthTotal);

                FlagCompletedHorz = (OffsetLeft + ClientWidthTotal <= 0);
                }

              break;

            case SlideScroll_Bounce:
              DirectionHorzPrev = DirectionHorz;

              FlagCompletedHorz = (ClientWidthTotal <= Width && OffsetLeft == OffsetLeftTarget);
              if (!FlagCompletedHorz) {
                if (DirectionHorz == 1 && OffsetLeft + ClientWidthTotal <= OffsetLeftDisplayed + ClientWidthDisplayed)
                  DirectionHorz = -1;
                else if (DirectionHorz == -1 && OffsetLeft >= OffsetLeftDisplayed)
                  DirectionHorz =  1;
                else
                  if (DirectionHorz == 1)
                    OffsetLeft -= SlideCurrent.ScrollHorzSpeed * TimeDelta;
                  else
                    OffsetLeft += SlideCurrent.ScrollHorzSpeed * TimeDelta;

                OffsetLeft = FClamp(OffsetLeft, OffsetLeftDisplayed + ClientWidthDisplayed - ClientWidthTotal,
                                                OffsetLeftDisplayed);

                FlagCompletedHorz = (DirectionHorz != DirectionHorzPrev);
                }

              break;
            }

          FlagCompleted = FlagCompletedHorz && FlagCompletedVert;
          if (FlagCompleted && ((TimeDisplayed >= SlideCurrent.Time && SlideCurrent.SlideNext != None) ||
                                SwitchTriggered.SlideSwitch != None))
            Action = SlideAction_Exiting;
          break;


        // ================================================
        // Exit Animation

        case SlideAction_Exiting:
          switch (SlideCurrent.EffectExit) {
            case SlideEffect_Replace:
              FlagCompleted = true;
              break;

            case SlideEffect_SlideTop:
              OffsetTop -= SlideCurrent.EffectExitSpeed * TimeDelta;
              FlagCompleted = (OffsetTop + ClientHeightTotal <= 0);
              break;

            case SlideEffect_SlideLeft:
              OffsetLeft -= SlideCurrent.EffectExitSpeed * TimeDelta;
              FlagCompleted = (OffsetLeft + ClientWidthTotal <= 0);
              break;

            case SlideEffect_SlideRight:
              OffsetLeft += SlideCurrent.EffectExitSpeed * TimeDelta;
              FlagCompleted = (OffsetLeft >= Width);
              break;

            case SlideEffect_SlideBottom:
              OffsetTop += SlideCurrent.EffectExitSpeed * TimeDelta;
              FlagCompleted = (OffsetTop >= Height);
              break;

            case SlideEffect_Fade:
              Fade -= SlideCurrent.EffectExitSpeed / 100.0 * TimeDelta;
              Fade = FClamp(Fade, 0.0, 1.0);
              FlagCompleted = (Fade == 0.0);
              break;
            }

          break;
        }

      } until (Action == ActionPrev);


    // ====================================================
    // Switch Slides
    // ====================================================

    if (Action == SlideAction_Exiting && FlagCompleted) {
      if (SwitchTriggered.SlideSwitch == None)
        SwitchTriggered.SlideSwitch = SlideCurrent.SlideNext;

      SlideCurrent = None;

      if (FlagDebug)
        Log("Switching to slide" @ SwitchTriggered.SlideSwitch.Name);
      }
    }
  }


// ============================================================================
// GetClientWidthTotal
//
// Calculates and returns the total client width of a slide.
// ============================================================================

simulated function int GetClientWidthTotal(ScreenSlide Slide) {

  return Slide.ClientPaddingLeft +
         Slide.ClientWidth +
         Slide.ClientPaddingRight;
  }


// ============================================================================
// GetClientHeightTotal
//
// Calculates and returns the total client height of a slide.
// ============================================================================

simulated function int GetClientHeightTotal(ScreenSlide Slide) {

  return Slide.ClientPaddingTop +
         Slide.ClientHeight +
         Slide.ClientPaddingBottom;
  }


// ============================================================================
// RenderTexture
// ============================================================================

simulated event RenderTexture(ScriptedTexture TextureCanvas) {

  local Color ColorDebug;
  local Screen ScreenMaster;
  local ScreenSlide ThisSlide;
  local int IndexSlide;

  ScreenMaster = TileMaster;
  if (ScreenMaster == None)
    ScreenMaster = Self;

  if (ScreenMaster.SlideCurrentAck == None)
    return;

  if (ScreenMaster.SlideCurrentAck.Palette != None)
    TextureCanvas.Palette = ScreenMaster.SlideCurrentAck.Palette.Palette;
  else
    TextureCanvas.Palette = PaletteOriginal;


  // ================================================================
  // Screen Background
  // ================================================================

  if (ScreenMaster.ScreenBackground != None)
    TextureCanvas.DrawTile(Left - TileLeft,
                           Top  - TileTop,
                           ScreenMaster.Width,
                           ScreenMaster.Height,
                           0, 0,
                           ScreenMaster.ScreenBackground.USize,
                           ScreenMaster.ScreenBackground.VSize,
                           ScreenMaster.ScreenBackground,
                           ScreenMaster.ScreenBackground.bMasked);


  // ================================================================
  // Slides
  // ================================================================

  for (ThisSlide = ScreenMaster.SlideCurrentAck; ThisSlide != None; ThisSlide = ThisSlide.SlideOverlay) {
    if (ThisSlide.Background != None)
      if (ThisSlide.BackgroundScroll)
        Tile(TextureCanvas,
             ThisSlide.Background,
             Left - TileLeft + ScreenMaster.OffsetLeftSlide[IndexSlide] + int(ScreenMaster.OffsetLeft),
             Top  - TileTop  + ScreenMaster.OffsetTopSlide [IndexSlide] + int(ScreenMaster.OffsetTop),
             ThisSlide.BackgroundTile);
      else
        Tile(TextureCanvas,
             ThisSlide.Background,
             Left - TileLeft + ScreenMaster.OffsetLeftSlide[IndexSlide],
             Top  - TileTop  + ScreenMaster.OffsetTopSlide [IndexSlide],
             ThisSlide.BackgroundTile);

    ThisSlide.Draw(TextureCanvas,
      Left - TileLeft + ScreenMaster.OffsetLeftSlide[IndexSlide] +
        int(ScreenMaster.OffsetLeft) + ThisSlide.ClientPaddingLeft,
      Top  - TileTop  + ScreenMaster.OffsetTopSlide [IndexSlide] +
        int(ScreenMaster.OffsetTop)  + ThisSlide.ClientPaddingTop,
      ScreenMaster.Fade);

    IndexSlide++;
    if (IndexSlide == ArrayCount(OffsetLeftSlide))
      break;
    }


  // ================================================================
  // Screen Foreground
  // ================================================================

  if (ScreenMaster.ScreenForeground != None)
    TextureCanvas.DrawTile(Left - TileLeft,
                           Top  - TileTop,
                           ScreenMaster.Width,
                           ScreenMaster.Height,
                           0, 0,
                           ScreenMaster.ScreenForeground.USize,
                           ScreenMaster.ScreenForeground.VSize,
                           ScreenMaster.ScreenForeground,
                           ScreenMaster.ScreenForeground.bMasked);

  if (FlagDebug) {
    ColorDebug.R = 255;
    ColorDebug.G =   0;
    ColorDebug.B =   0;

    TextureCanvas.DrawColoredText(Left, Top,
      int(Left - TileLeft + ScreenMaster.OffsetLeft + ScreenMaster.SlideCurrentAck.ClientPaddingLeft) @ "x" @
      int(Top  - TileTop  + ScreenMaster.OffsetTop  + ScreenMaster.SlideCurrentAck.ClientPaddingTop),
      Font 'Engine.SmallFont', ColorDebug);
    }
  }


// ============================================================================
// Tile
//
// Draws a texture repeatedly onto another texture, starting at the given
// offset.
// ============================================================================

simulated function Tile(ScriptedTexture TextureCanvas, Texture TextureTile,
                        int OffsetLeft, int OffsetTop, bool FlagTiled) {

  local int OffsetTopTexture;
  local int OffsetLeftTexture;

  for (OffsetLeftTexture = OffsetLeft; OffsetLeftTexture < TextureCanvas.USize; OffsetLeftTexture += TextureTile.USize) {
    if (OffsetLeftTexture + TextureTile.USize > 0)
      for (OffsetTopTexture = OffsetTop; OffsetTopTexture < TextureCanvas.VSize; OffsetTopTexture += TextureTile.VSize) {
        if (OffsetTopTexture + TextureTile.VSize > 0)
          TextureCanvas.DrawTile(OffsetLeftTexture, OffsetTopTexture, TextureTile.USize, TextureTile.VSize,
                                 0, 0, TextureTile.USize, TextureTile.VSize, TextureTile, TextureTile.bMasked);
        if (!FlagTiled) break;
        }

    if (!FlagTiled) break;
    }
  }


// ============================================================================
// VersionCheck
//
// Compares this client's Screen version with the version running on the
// server and notifies the user of updates.
// ============================================================================

simulated function VersionCheck() {

  local ScreenMutator ThisScreenMutator;
  local Mutator ThisMutator;

  if (FlagVersionAck)
    return;

  FlagVersionAck = (VersionServer > 0);

  /*  CorpArmstrong
  if (VersionServer > Version)
    MutatorAiDisplayVersion(Version, VersionServer);
    */
  VersionLatest = Max(VersionLatest, VersionServer);
  SaveConfig();
  }


// ============================================================================
// AddSlide
//
// Adds a slide to the end of the Screen's current slide list. If the current
// last slide wraps around to a previous slide, so will the appended slide.
// ============================================================================

simulated function AddSlide(ScreenSlide NewSlide) {

  local ScreenSlide ThisSlide;
  local ScreenSlide SlidePrevious;

  SlidePrevious = None;

  for (ThisSlide = SlideCurrent; ThisSlide != None && !ThisSlide.FlagSeen; ThisSlide = ThisSlide.SlideNext) {
    ThisSlide.FlagSeen = true;
    SlidePrevious = ThisSlide;
    }

  if (SlidePrevious == None) {
    NewSlide.SlideNext = SlideCurrent;
    SlideCurrent = NewSlide;
    }

  else {
    NewSlide.SlideNext = ThisSlide;
    SlidePrevious.SlideNext = NewSlide;
    }

  NewSlide.FlagSeen = true;
  for (ThisSlide = SlideCurrent; ThisSlide != None && ThisSlide.FlagSeen; ThisSlide = ThisSlide.SlideNext)
    ThisSlide.FlagSeen = false;
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    Version=132
    Width=256
    Height=256
    bAlwaysTick=True
    //FIXME Textures: CorpArmstrong
    //Texture=Texture'ActorScreen'
    Texture=Texture'Engine.S_Trigger'
}
