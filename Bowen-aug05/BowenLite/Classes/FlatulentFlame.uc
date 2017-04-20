//=============================================================================
// FlatulentFlame. 	(c) 2003 JimBowen
//=============================================================================
class FlatulentFlame extends Fireball;

auto simulated state flying
{
	simulated function Touch(Actor Other)
	{
		if(Other != Owner)
			Super.Touch(Other);
	}
}

simulated function Touch(Actor Other)
{
	if(Other != Owner)
		Super.Touch(Other);
}

simulated function prebeginplay()
{
	damage = 0;
	mpdamage = 0;
}

//---END-CLASS---

defaultproperties
{
     ItemName="Bean Vindaloo"
}
