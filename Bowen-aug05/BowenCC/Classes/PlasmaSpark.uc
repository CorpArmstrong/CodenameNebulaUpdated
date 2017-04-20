//=============================================================================
// PlasmaSpark.
//=============================================================================
class PlasmaSpark expands DeusExFragment;

var int numwallhits;
var(bowen) int maxwallhits;

	simulated singular function ZoneChange( ZoneInfo NewZone )
	{
		local float splashsize;
		local actor splash;

		if ( NewZone.bWaterZone )
		{
			Velocity = 0.2 * Velocity;
			SpawnSmoke();
			lifeSpan = FRand();
		}
/*		if ( NewZone.bPainZone && (NewZone.DamagePerSec > 0) )
			Destroy();*/
	}
	

simulated function SpawnSmoke()
{
	local ParticleGenerator gen;
	
				gen = Spawn(class'ParticleGenerator', Self,, Location, rot(16384,0,0));
				if (gen != None)
				{
					gen.checkTime = 0.25;
					gen.LifeSpan = 2;
					gen.particleDrawScale = 0.3;
					gen.bRandomEject = True;
					gen.ejectSpeed = 10.0;
					gen.bGravity = False;
					gen.bParticlesUnlit = True;
					gen.frequency = 0.5;
					gen.riseRate = 10.0;
					gen.spawnSound = Sound'Spark2';
					gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
					gen.SetBase(Self);
				}
}

state Dying	
{

	simulated function hitwall (vector hitnormal, actor wall)
	{
		numwallhits ++;
		
		if (numwallhits > (maxwallhits/2) && maxwallhits != -1 && velocity != vect(0,0,0))
		{	
			velocity = vect(0,0,0);			// this is to stop slowdown when fragments get stuck on sloping ground
			mass = 0;
		}
		
		if (numwallhits > maxwallhits && maxwallhits != -1 && velocity == vect(0,0,0))
			destroy(); // just incase it misbehaves
			
		super.HitWall(HitNormal, Wall);
	}
	
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
	//	Destroy();
	}

}	

//---END-CLASS---

defaultproperties
{
     maxwallhits=100
     speed=10000.000000
     MaxSpeed=10000.000000
     MomentumTransfer=100
     LifeSpan=45.000000
     AnimRate=10.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'BowenCust.Effects.frg_a00'
     DrawScale=0.250000
     LightBrightness=128
     LightHue=80
     LightSaturation=240
     LightRadius=9
     LightPeriod=75
     LightPhase=100
     NetPriority=0.500000
     NetUpdateFrequency=20.000000
}
