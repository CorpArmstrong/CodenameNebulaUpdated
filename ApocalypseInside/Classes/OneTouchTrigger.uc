//-----------------------------------------------------------
// OneTouchTrigger:
// This trigger is that it doesn't call untouch event.
// Epic Games did not provide that option. 
//-----------------------------------------------------------
class OneTouchTrigger expands Trigger;

function UnTouch (actor Other)
{
    // Do nothing.
}
