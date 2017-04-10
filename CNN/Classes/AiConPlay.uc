//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AiConPlay extends ConPlay;

// ----------------------------------------------------------------------
// state ConPlayAnim
//
// Plays an animation and then runs the next event.
// Optionally will wait for the animation to finish
// ----------------------------------------------------------------------

state ConPlayAnim
{
Begin:
    AiConEventAnimation(currentEvent).bLoopAnim = (AiConEventAnimation(currentEvent).playMode == 0);

	// Check to see if we need to just play this animation once or
    // loop it.

    if (AiConEventAnimation(currentEvent).bLoopAnim)
    {
	    AiConEventAnimation(currentEvent).eventOwner.LoopAnim(AiConEventAnimation(currentEvent).sequence);
	}
    else
    {
    	AiConEventAnimation(currentEvent).eventOwner.PlayAnim(AiConEventAnimation(currentEvent).sequence);
	}

    // If we're not looping the animation and we need to wait for this one to finish,
    // then do so.

    if ((AiConEventAnimation(currentEvent).playLength > 0))
    {
    	Sleep(AiConEventAnimation(currentEvent).playLength);
	}

    if ((!AiConEventAnimation(currentEvent).bLoopAnim) && (AiConEventAnimation(currentEvent).bFinishAnim))
    {
    	AiConEventAnimation(currentEvent).eventOwner.FinishAnim();
	}

    currentEvent = currentEvent.nextEvent;
    GotoState('PlayEvent');
}

DefaultProperties
{
}