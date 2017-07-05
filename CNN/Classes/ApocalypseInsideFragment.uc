//=============================================================================
// DeusExFragment.
//=============================================================================
class ApocalypseInsideFragment expands DeusExFragment;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// DoNT (TAntalus) -- randomize the lifespan a bit so things don't all disappear at once
}

simulated function Tick(float deltaTime)
{
   if ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority))
      return;

	if (bSmoking && !IsInState('Dying') && (smokeGen == None))
		AddSmoke();

	// fade out the object smoothly 2 seconds before it dies completely
	if (LifeSpan <= 2)
	{
		LifeSpan = 10.00;
	}
}

defaultproperties
{
    LifeSpan=10.00
}
