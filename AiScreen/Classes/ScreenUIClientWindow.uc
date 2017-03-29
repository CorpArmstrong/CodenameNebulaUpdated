// ============================================================================
// ScreenUIClientWindow
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Dialog box content for Screen user interface.
// ============================================================================


class ScreenUIClientWindow extends AiUWindowDialogClientWindow;


// ============================================================================
// Controls
// ============================================================================

var AiUWindowPageControl Pages;
var AiUWindowSmallCloseButton ButtonClose;
var AiUWindowTabControlItem PageNetwork;
var AiUWindowTabControlItem PageAbout;


// ============================================================================
// Created
// ============================================================================

function Created() {
  
  WinWidth += 4;
  
  Pages = AiUWindowPageControl(CreateWindow(class 'AiUWindowPageControl', 0, 0, WinWidth, WinHeight - 24));
  Pages.SetMultiLine(true);
  
  PageNetwork = Pages.AddPage("Network", class 'ScreenUIScrollClientNetwork');
  PageAbout   = Pages.AddPage("About",   class 'ScreenUIScrollClientAbout');

  if (class 'Screen'.default.VersionLatest > class 'Screen'.default.Version) {
    PageAbout.SetCaption("Update");
    PageAbout.bFlash = true;
    }

  ButtonClose = AiUWindowSmallCloseButton(CreateControl(class 'AiUWindowSmallCloseButton', WinWidth - 53, WinHeight - 21, 48, 16));

  Super.Created();
  }


// ============================================================================
// Paint
// ============================================================================

function Paint(Canvas CanvasBackground, float X, float Y) {

  local Texture TextureBackground;

  TextureBackground = GetLookAndFeelTexture();
  DrawUpBevel(CanvasBackground, 0, 0, WinWidth, WinHeight, TextureBackground);
  }
defaultproperties
{
}
