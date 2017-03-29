// ============================================================================
// ScreenUIScrollClientAbout
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Scrolling client area for About tab in Screen user interface.
// ============================================================================


class ScreenUIScrollClientAbout extends AiUWindowScrollingDialogClient;


// ============================================================================
// Created
// ============================================================================

function Created() {

  ClientClass = class 'ScreenUIPageAbout';
  FixedAreaClass = None;

  Super.Created();
  }
defaultproperties
{
}
