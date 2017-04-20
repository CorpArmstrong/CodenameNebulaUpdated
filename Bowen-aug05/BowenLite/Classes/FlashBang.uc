//=============================================================================
// FlashBang. 	(c) 2003 JimBowen
//=============================================================================
class FlashBang expands ThrownProjectile;

var(Bowen) int MaxGrenades;
var float	mpBlastRadius;
var float	mpProxRadius;
var float	mpFuselength;

/*
replication
{
	Reliable if (Role == ROLE_Authority)
		SpawnSmoke;
}
*//*
simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local DeusExPlayer p;
	local FlashBangEffect Effect;
	
		if (LifeSpan > Default.LifeSpan / 2)	
			foreach visibleactors (class'DeusExPlayer', p, BlastRadius)
				p.ClientFlash(2, vect(1000,1000,1000));
			
		Effect = spawn (class'BowenLite.FlashBangEffect',,,Location);
		if (effect != None)
		{
			effect.BlastRadius = BlastRadius;
			effect.OriginalBlastRadius = BlastRadius;
			effect.PawnOwner = Pawn(Owner);
		}
}
*/

auto state flying
{
	function Explode(vector HitLocation, vector HitNormal)
	{
		local DeusExPlayer p;
		local FlashBangEffect Effect;
	
		if (LifeSpan > Default.LifeSpan / 2)	
			foreach visibleactors (class'DeusExPlayer', p, BlastRadius)
				p.ClientFlash(2, vect(1000,1000,1000));
		if (Level.NetMode == NM_DedicatedServer	|| Level.NetMode == NM_Standalone)
			Effect = spawn (class'BowenLite.FlashBangEffect',,,Location);
		if (effect != None)
		{
			effect.BlastRadius = BlastRadius;
			effect.OriginalBlastRadius = BlastRadius;
			effect.PawnOwner = Pawn(Owner);
		}
		Super.Explode(HitLocation, HitNormal);
	}
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

function PostBeginPlay()
{
	local FlashBang FB, First;
	local bool bFoundFirst;
	local int NumFound;
		
		if (Role != ROLE_Authority || Level.NetMode == NM_Client)
			return;
		
		foreach allactors (Class'FlashBang',FB)
		{
			if (!bFoundFirst && FB != Self)
				First = FB;
			NumFound ++;
		}
		
		if (NumFound > MaxGrenades)
		{
			First.SpawnSmoke();
			First.Destroy();
		}	
		Super.PostBeginPlay();
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
	{
		blastRadius=mpBlastRadius;
		proxRadius=mpProxRadius;
		fuseLength=mpFuseLength;
		bIgnoresNanoDefense=True;
	}
}

//---END-CLASS---

defaultproperties
{
     MaxGrenades=5
     mpBlastRadius=1024.000000
     mpProxRadius=128.000000
     mpFuselength=1.000000
     fuseLength=3.000000
     proxRadius=256.000000
     blastRadius=750.000000
     ItemName="FlashBang Grenade"
     speed=1000.000000
     MaxSpeed=1000.000000
     Mesh=LodMesh'DeusExItems.EMPGrenadePickup'
     bAlwaysRelevant=True
}
