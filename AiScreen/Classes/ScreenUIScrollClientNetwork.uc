// ============================================================================
// ScreenUIScrollClientNetwork
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Scrolling client area for Network tab in Screen user interface.
// ============================================================================


class ScreenUIScrollClientNetwork extends AiUWindowScrollingDialogClient;


// ============================================================================
// Created
// ============================================================================

function Created() {

  ClientClass = class 'ScreenUIPageNetwork';
  FixedAreaClass = None;

  Super.Created();
  }
defaultproperties
{
}
