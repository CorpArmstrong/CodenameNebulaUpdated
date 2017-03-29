// ============================================================================
// ScreenTrigger
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Provides a trigger that switches a Screen actor to a given slide.
// ============================================================================


class ScreenTrigger extends Triggers;


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorTrigger.bmp mips=off flags=2


// ============================================================================
// Properties
// ============================================================================

var() ScreenSlide SlideSwitch;


// ============================================================================
// Trigger
// ============================================================================

function Trigger(Actor Other, Pawn EventInstigator) {

  local Screen ThisScreen;
														/* CorpArmstrong
  foreach AllActors(class 'Screen', ThisScreen, Event) {
    ThisAiSwitchTriggered.SlideSwitch = SlideSwitch;
    ThisAiSwitchTriggered.Update++;
    }
    */
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    Texture=Texture'ActorTrigger'
}
