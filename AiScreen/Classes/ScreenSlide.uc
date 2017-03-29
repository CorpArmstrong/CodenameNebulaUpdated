// ============================================================================
// ScreenSlide
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Abstract base class for slides that can be displayed on a Screen texture.
// ============================================================================


class ScreenSlide extends Info abstract;


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorSlide.bmp mips=off flags=2


// ============================================================================
// Types
// ============================================================================

enum EnumSlideScroll {

  SlideScroll_None,
  SlideScroll_Bounce,
  SlideScroll_Wrap,
  };


enum EnumSlideEffect {

  SlideEffect_Replace,
  SlideEffect_SlideTop,
  SlideEffect_SlideLeft,
  SlideEffect_SlideRight,
  SlideEffect_SlideBottom,
  SlideEffect_Fade,
  };


enum EnumSlideAlignHorz {

  SlideAlignHorz_Left,
  SlideAlignHorz_Center,
  SlideAlignHorz_Right,
  SlideAlignHorz_LeftAdjacent,
  SlideAlignHorz_RightAdjacent,
  };


enum EnumSlideAlignVert {

  SlideAlignVert_Top,
  SlideAlignVert_Middle,
  SlideAlignVert_Bottom,
  SlideAlignVert_TopAdjacent,
  SlideAlignVert_BottomAdjacent,
  };


// ============================================================================
// Properties
//
// Some or all of these properties might be ignored when set in UnrealEd and
// automatically set to whatever value suits the subclass.
// ============================================================================

var() EnumSlideAlignHorz AlignHorz;
var() EnumSlideAlignVert AlignVert;

var() Texture Background;
var() bool BackgroundScroll;
var() bool BackgroundTile;
var() Color BackgroundColor;

var() Texture Palette;

var() int ClientWidth;
var() int ClientHeight;
var() int ClientPaddingTop;
var() int ClientPaddingLeft;
var() int ClientPaddingRight;
var() int ClientPaddingBottom;

var() float Time;
var() EnumSlideScroll ScrollHorz;
var() EnumSlideScroll ScrollVert;
var() EnumSlideEffect EffectEntry;
var() EnumSlideEffect EffectExit;
var() float ScrollHorzSpeed;
var() float ScrollVertSpeed;
var() float EffectEntrySpeed;
var() float EffectExitSpeed;

var() ScreenSlide SlideNext;
var() ScreenSlide SlideOverlay;


// ============================================================================
// Variables
// ============================================================================

var bool FlagSeen;  // used exclusively in AiAddSlide


// ============================================================================
// Prepare
//
// Does whatever preparation is needed for displaying this slide. Called
// immediately before Draw. After calling this function, all properties of
// this slide are expected to represent whatever values will be used in the
// next Draw operation, particularly in regard to ClientWidth and ClientHeight.
// ============================================================================

simulated function Prepare(ScriptedTexture TextureCanvas) {

  // implemented in subclasses
  }


// ============================================================================
// Draw
//
// Draws the slide content onto the given ScriptedTexture at the given pixel
// position.
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int Left, int Top, float Fade) {

  // implemented in subclasses
  }


// ============================================================================
// Replace
//
// Replaces all occurrences of a substring in a string by another string and
// returns the result.
// ============================================================================

simulated function string Replace(coerce string TextOriginal, coerce string TextSearch, coerce string TextReplace) {

  local int IndexChar;
  local int IndexCharLast;
  local string TextResult;

  IndexChar = 0;
  TextResult = TextOriginal;

  while (true) {
    IndexCharLast = IndexChar;
    IndexChar = InStr(Mid(TextResult, IndexChar), TextSearch);

    if (IndexChar < 0) break;

    IndexChar += IndexCharLast;
    TextResult = Left(TextResult, IndexChar) $ TextReplace $ Mid(TextResult, IndexChar + Len(TextSearch));
    IndexChar += Len(TextReplace);
    }

  return TextResult;
  }


// ============================================================================
// FadeColor
//
// Returns a shade of the given color, faded by the given amount.
// ============================================================================

simulated function Color FadeColor(Color ColorFade, float Fade) {

  local Color ColorResult;

  ColorResult.R = BackgroundColor.R + (ColorFade.R - BackgroundColor.R) * Fade;
  ColorResult.G = BackgroundColor.G + (ColorFade.G - BackgroundColor.G) * Fade;
  ColorResult.B = BackgroundColor.B + (ColorFade.B - BackgroundColor.B) * Fade;

  return ColorResult;
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    AlignHorz=1
    AlignVert=1
    BackgroundScroll=True
    BackgroundTile=True
    ClientWidth=216
    ClientHeight=216
    ClientPaddingTop=20
    ClientPaddingLeft=20
    ClientPaddingRight=20
    ClientPaddingBottom=20
    ScrollHorz=1
    ScrollVert=1
    ScrollHorzSpeed=10.00
    ScrollVertSpeed=10.00
    EffectEntrySpeed=10.00
    EffectExitSpeed=10.00
    bNoDelete=True
    //FIXME Textures: CorpArmstrong
    //Texture=Texture'ActorSlide'
    Texture=Texture'Engine.S_Trigger'
}
