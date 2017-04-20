//================================================================================
// FlatulentFlame.
//================================================================================
class FlatulentFlame extends Fireball;

auto simulated state Flying extends Flying
{
	simulated function Touch (Actor Other)
	{
		if ( Other != Owner )
		{
			Super.Touch(Other);
		}
	}
	
}

simulated function Touch (Actor Other)
{
	if ( Other != Owner )
	{
		Super.Touch(Other);
	}
}

simulated function PreBeginPlay ()
{
	Damage=0.00;
	mpDamage=0.00;
}

defaultproperties
{
    ItemName="Bean Vindaloo"
}