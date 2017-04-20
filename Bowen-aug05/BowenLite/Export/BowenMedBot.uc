//================================================================================
// BowenMedBot.
//================================================================================
class BowenMedBot extends MedicalBot;

function Frob (Actor Frobber, Inventory frobWith)
{
	local ExplosiveDisc disc;
	local int i;

	if ( Role == 4 )
	{
		foreach AllActors(Class'ExplosiveDisc',disc)
		{
			if ( disc.BlowUpActor == Frobber )
			{
				disc.Destroy();
				i++;
			}
			continue;
		}
	}
	if (! Frobber.IsA('DeusExPlayer') && (Role == 4) ) goto JL006F;
JL006F:
	if ( i > 1 )
	{
		DeusExPlayer(Frobber).ClientMessage(string(i) @ "discs removed");
	}
	else
	{
		if ( i == 1 )
		{
			DeusExPlayer(Frobber).ClientMessage(string(i) @ "disc removed");
		}
	}
	Super.Frob(Frobber,frobWith);
}

defaultproperties
{
    Orders='
    bInvincible=True
}