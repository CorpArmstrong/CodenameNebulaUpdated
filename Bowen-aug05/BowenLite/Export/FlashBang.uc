//================================================================================
// FlashBang.
//================================================================================
class FlashBang extends ThrownProjectile;

var(bowen) int MaxGrenades;
var float mpBlastRadius;
var float mpProxRadius;
var float mpFuselength;

auto state Flying extends Flying
{
	function Explode (Vector HitLocation, Vector HitNormal)
	{
		local DeusExPlayer P;
		local FlashBangEffect Effect;
	
		if ( LifeSpan > Default.LifeSpan / 2 )
		{
			foreach VisibleActors(Class'DeusExPlayer',P,blastRadius)
			{
				P.ClientFlash(2.00,vect(1000.00,1000.00,1000.00));
				continue;
			}
		}
		Effect=Spawn(Class'FlashBangEffect',,,Location);
		if ( Effect != None )
		{
			Effect.blastRadius=blastRadius;
			Effect.OriginalBlastRadius=blastRadius;
			Effect.PawnOwner=Pawn(Owner);
		}
		Super.Explode(HitLocation,HitNormal);
	}
	
}

simulated function SpawnSmoke ()
{
	local ParticleGenerator gen;

	gen=Spawn(Class'ParticleGenerator',self,,Location,rot(16384,0,0));
	if ( gen != None )
	{
		gen.checkTime=0.25;
		gen.LifeSpan=2.00;
		gen.particleDrawScale=0.30;
		gen.bRandomEject=True;
		gen.ejectSpeed=10.00;
		gen.bGravity=False;
		gen.bParticlesUnlit=True;
		gen.Frequency=0.50;
		gen.RiseRate=10.00;
		gen.SpawnSound=Sound'Spark2';
		gen.particleTexture=FireTexture'SmokePuff1';
		gen.SetBase(self);
	}
}

function PostBeginPlay ()
{
	local FlashBang FB;
	local FlashBang first;
	local bool bFoundFirst;
	local int NumFound;

	if ( (Role != 4) || (Level.NetMode == 3) )
	{
		return;
	}
	foreach AllActors(Class'FlashBang',FB)
	{
		if (  !bFoundFirst && (FB != self) )
		{
			first=FB;
		}
		NumFound++;
		continue;
	}
	if ( NumFound > MaxGrenades )
	{
		first.SpawnSmoke();
		first.Destroy();
	}
	Super.PostBeginPlay();
}

simulated function PreBeginPlay ()
{
	Super.PreBeginPlay();
	if ( Level.NetMode != 0 )
	{
		blastRadius=mpBlastRadius;
		proxRadius=mpProxRadius;
		fuseLength=mpFuselength;
		bIgnoresNanoDefense=True;
	}
}

defaultproperties
{
    MaxGrenades=5
    mpBlastRadius=1024.00
    mpProxRadius=128.00
    mpFuselength=1.00
    fuseLength=3.00
    proxRadius=256.00
    blastRadius=750.00
    ItemName="FlashBang Grenade"
    speed=1000.00
    MaxSpeed=1000.00
    Mesh=LodMesh'DeusExItems.EMPGrenadePickup'
    bAlwaysRelevant=True
}