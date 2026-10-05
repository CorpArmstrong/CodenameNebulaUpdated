//-----------------------------------------------------------
// CNNConPlay.
//-----------------------------------------------------------
class CNNConPlay extends ConPlay;

// ----------------------------------------------------------------------
// state ConPlayAnim
//
// Plays an animation and then runs the next event.
// Optionally will wait for the animation to finish
// ----------------------------------------------------------------------

state ConPlayAnim
{
Begin:
    CNNConEventAnimation(currentEvent).bLoopAnim =
        (CNNConEventAnimation(currentEvent).playMode == 0);

    // Check to see if we need to just play this animation once or loop it.
    if (CNNConEventAnimation(currentEvent).bLoopAnim)
    {
        CNNConEventAnimation(currentEvent).eventOwner
            .LoopAnim(CNNConEventAnimation(currentEvent).sequence);
    }
    else
    {
        CNNConEventAnimation(currentEvent).eventOwner
            .PlayAnim(CNNConEventAnimation(currentEvent).sequence);
    }

    // If we're not looping the animation and we need to wait for this one to
    // finish, then do so.
    if ((CNNConEventAnimation(currentEvent).playLength > 0))
    {
        Sleep(CNNConEventAnimation(currentEvent).playLength);
    }

    if ((!CNNConEventAnimation(currentEvent).bLoopAnim) &&
        (CNNConEventAnimation(currentEvent).bFinishAnim)
    )
    {
        CNNConEventAnimation(currentEvent).eventOwner.FinishAnim();
	}

    currentEvent = currentEvent.nextEvent;
    GotoState('PlayEvent');
}
