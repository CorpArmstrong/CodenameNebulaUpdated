//=============================================================================
// GODZTurretGun.
//=============================================================================
class GODZTurretGun expands AutoTurretGun;

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
}

function HackAction(Actor Hacker, bool bHacked)
{
}

auto state active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
	}
}

//---END-CLASS---

defaultproperties
{
     bHackable=False
     hackStrength=1.000000
}
