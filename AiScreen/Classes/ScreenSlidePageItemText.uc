// ============================================================================
// ScreenSlidePageItemText
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlidePageItem that contains and displays an atomic chunk
// of text.
// ============================================================================


class ScreenSlidePageItemText extends ScreenSlidePageItem;


// ============================================================================
// Variables
// ============================================================================

var string Text;
var Font FontText;
var Color ColorText;
var bool FlagUnderline;

var string TextUnderline;
var int OffsetUnderlinePad;


// ============================================================================
// Prepare
// ============================================================================

simulated function Prepare(ScriptedTexture TextureCanvas) {

  local int IndexUnderline;
  local int LengthUnderline;
  local float WidthTextUnderline;
  local float HeightTextUnderline;

  if (FlagUnderline) {
    TextureCanvas.TextSize("_", WidthTextUnderline, HeightTextUnderline, FontText);

    TextUnderline = "";

    LengthUnderline = Width / WidthTextUnderline;
    for (IndexUnderline = 0; IndexUnderline < LengthUnderline; IndexUnderline++)
      TextUnderline = TextUnderline $ "_";

    OffsetUnderlinePad = Max(0, Width - WidthTextUnderline);
    }
  }
  

// ============================================================================
// Draw
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int OffsetLeft, int OffsetTop, float Fade) {

  local Color ColorFade;
  
  ColorFade.R = ColorBase.R + (ColorText.R - ColorBase.R) * Fade;
  ColorFade.G = ColorBase.G + (ColorText.G - ColorBase.G) * Fade;
  ColorFade.B = ColorBase.B + (ColorText.B - ColorBase.B) * Fade;

  TextureCanvas.DrawColoredText(OffsetLeft + Left, OffsetTop + Top, Text, FontText, ColorFade);

  if (FlagUnderline) {
    TextureCanvas.DrawColoredText(OffsetLeft + Left, OffsetTop + Top, TextUnderline, FontText, ColorFade);
    TextureCanvas.DrawColoredText(OffsetLeft + Left + OffsetUnderlinePad, OffsetTop + Top, "_", FontText, ColorFade);
    }
  }
defaultproperties
{
}
