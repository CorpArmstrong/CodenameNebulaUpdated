//-----------------------------------------------------------
// CASConPlay
//-----------------------------------------------------------
class CASConPlay extends ConPlay;

// ----------------------------------------------------------------------
// state ConPlayAnim
//
// Plays an animation and then runs the next event.
// Optionally will wait for the animation to finish
// ----------------------------------------------------------------------

state ConPlayAnim
{
Begin:
    CASConEventAnimation(currentEvent).bLoopAnim = (CASConEventAnimation(currentEvent).playMode == 0);

	// Check to see if we need to just play this animation once or
    // loop it.

    if (CASConEventAnimation(currentEvent).bLoopAnim)
    {
	    CASConEventAnimation(currentEvent).eventOwner.LoopAnim(CASConEventAnimation(currentEvent).sequence);
	}
    else
    {
    	CASConEventAnimation(currentEvent).eventOwner.PlayAnim(CASConEventAnimation(currentEvent).sequence);
	}

    // If we're not looping the animation and we need to wait for this one to finish,
    // then do so.

    if ((CASConEventAnimation(currentEvent).playLength > 0))
    {
    	Sleep(CASConEventAnimation(currentEvent).playLength);
	}

    if ((!CASConEventAnimation(currentEvent).bLoopAnim) && (CASConEventAnimation(currentEvent).bFinishAnim))
    {
    	CASConEventAnimation(currentEvent).eventOwner.FinishAnim();
	}

    currentEvent = currentEvent.nextEvent;
    GotoState('PlayEvent');
}

DefaultProperties
{
}