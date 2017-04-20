//=============================================================================
// BowenMedBot. 	(c) 2003 JimBowen
//=============================================================================
class BowenMedBot expands MedicalBot;

function Frob(Actor Frobber, Inventory frobWith)
{
	local explosivedisc disc;
	local int i;

		if (Role == ROLE_Authority)
			foreach allactors (class'explosivedisc', disc)
				if (disc.BlowUpActor == Frobber)
				{
					disc.Destroy();
					i++;
				}
			
		if(Frobber.IsA('DeusExPlayer') && Role == ROLE_Authority);
			if (i > 1)
				DeusExPlayer(Frobber).ClientMessage(i @ "discs removed");
			else if (i == 1)
				DeusExPlayer(Frobber).ClientMessage(i @ "disc removed");

	Super.Frob(Frobber, FrobWith);
}

//---END-CLASS---

defaultproperties
{
     Orders=Standing
     bInvincible=True
     GroundSpeed=0
}
