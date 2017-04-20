//================================================================================
// GODZTurretGun.
//================================================================================
class GODZTurretGun extends AutoTurretGun;

function TakeDamage (int Damage, Pawn EventInstigator, Vector HitLocation, Vector Momentum, name DamageType)
{
}

function HackAction (Actor Hacker, bool bHacked)
{
}

auto state Active extends Active
{
	function TakeDamage (int Damage, Pawn EventInstigator, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
}

defaultproperties
{
    bHackable=False
    hackStrength=1.00
}