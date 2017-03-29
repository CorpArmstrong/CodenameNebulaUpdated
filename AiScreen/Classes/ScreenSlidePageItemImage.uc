// ============================================================================
// ScreenSlidePageItemImage
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlidePageItem that contains and displays an image.
// ============================================================================


class ScreenSlidePageItemImage extends ScreenSlidePageItem;


// ============================================================================
// Variables
// ============================================================================

var Texture Image;

var int ClipTop;
var int ClipLeft;
var int ClipWidth;
var int ClipHeight;


// ============================================================================
// Draw
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int OffsetLeft, int OffsetTop, float Fade) {

  TextureCanvas.DrawTile(Left + OffsetLeft, Top + OffsetTop, Width, Height,
                         ClipLeft, ClipTop, ClipWidth, ClipHeight, Image, Image.bMasked);
  }
defaultproperties
{
}
