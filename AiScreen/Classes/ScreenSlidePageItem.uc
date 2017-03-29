// ============================================================================
// ScreenSlidePageItem
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Abstract base class for a single positioned atomic item to be displayed on a
// ScreenSlideText slide for a Screen actor.
// ============================================================================


class ScreenSlidePageItem extends Object abstract;


// ============================================================================
// Variables
// ============================================================================

var int Top;
var int Left;
var int Width;
var int Height;

var Color ColorBase;

var ScreenSlidePageItem ItemNext;


// ============================================================================
// Prepare
//
// Performs any preparation that is needed for drawing the item. This method is
// called only once immediately after the item is set and placed.
// ============================================================================

simulated function Prepare(ScriptedTexture TextureCanvas) {

  // implemented in subclasses
  }


// ============================================================================
// Draw
//
// Draws the item, shifted by the given offsets.
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int OffsetLeft, int OffsetTop, float Fade) {

  // implemented in subclasses
  }


// ============================================================================
// AddItem
//
// Adds an item to the item list. The item list is ordered by the position of
// the upper-left corner of the item to allow for some optimizations when
// displaying the items. Returns whether the new item was added after the
// one for which this method was called.
// ============================================================================

function bool AddItem(ScreenSlidePageItem NewItem) {

  if (NewItem.Top < Top || (NewItem.Top == Top && NewItem.Left < Left))
    return false;
  
  if (ItemNext == None || !ItemNext.AddItem(NewItem)) {
    NewItem.ItemNext = ItemNext;
    ItemNext = NewItem;
    }

  return true;
  }
defaultproperties
{
}
