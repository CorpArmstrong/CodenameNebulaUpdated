//=============================================================================
// RadiationEffect. 	(c) 2003 JimBowen
//=============================================================================
class RadiationEffect expands Effects;

var(Bowen) int Damage;
var(Bowen) float Radius;
var float radtimer;

	function Tick(float deltaTime)
	{
		local Actor A;
		local Vector offset;

		Super.Tick(deltaTime);
		
			radTimer += deltaTime;

			if (radTimer > 1.0 && Role == ROLE_Authority)
			{
				radTimer = 0;
				if (FRand() > 0.75);
					HurtRadius (Damage, Radius, 'Radiation', 0, Location, True);
			}
	}

//---END-CLASS---

defaultproperties
{
}
