//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MyConPlay extends ConPlay;

// ----------------------------------------------------------------------
// state ConPlayAnim
//
// Plays an animation and then runs the next event.
// Optionally will wait for the animation to finish
// ----------------------------------------------------------------------

state ConPlayAnim
{
Begin:
              MyConEventAnimation(currentEvent).bLoopAnim = (MyConEventAnimation(currentEvent).playMode == 0);
	// Check to see if we need to just play this animation once or
	// loop it.

	if ( MyConEventAnimation(currentEvent).bLoopAnim )
		MyConEventAnimation(currentEvent).eventOwner.LoopAnim( MyConEventAnimation(currentEvent).sequence );
	else
		MyConEventAnimation(currentEvent).eventOwner.PlayAnim( MyConEventAnimation(currentEvent).sequence );

	// If we're not looping the animation and we need to wait for this one to finish,
	// then do so.

    if ((MyConEventAnimation(currentEvent).playLength > 0))
		Sleep(MyConEventAnimation(currentEvent).playLength);

	if (( !MyConEventAnimation(currentEvent).bLoopAnim ) && ( MyConEventAnimation(currentEvent).bFinishAnim ))
		MyConEventAnimation(currentEvent).eventOwner.FinishAnim();

	currentEvent = currentEvent.nextEvent;
	GotoState('PlayEvent');
}

defaultproperties
{
}
