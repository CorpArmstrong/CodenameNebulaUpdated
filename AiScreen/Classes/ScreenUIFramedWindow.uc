// ============================================================================
// ScreenUIFramedWindow
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Dialog box frame for Screen user interface.
// ============================================================================


class ScreenUIFramedWindow extends AiUWindowFramedWindow;


// ============================================================================
// Created
// ============================================================================

function Created() {
  
  ClientClass = class 'ScreenUIClientWindow';
  WindowTitle = "Screen Configuration";

  Super.Created();

  WinLeft = (Root.WinWidth  - WinWidth)  / 2;
  WinTop  = (Root.WinHeight - WinHeight) / 2;
  }
defaultproperties
{
}
