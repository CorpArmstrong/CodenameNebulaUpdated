// ============================================================================
// ScreenUIMenuItem
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Menu item for Screen user interface.
// ============================================================================


class ScreenUIMenuItem extends AiUMenuModMenuItem;


// ============================================================================
// Execute
// ============================================================================

function Execute() {

  MenuItem.Owner.Root.CreateWindow(class 'ScreenUIFramedWindow', 0, 0, 300, 220, , true);
  }
defaultproperties
{
}
