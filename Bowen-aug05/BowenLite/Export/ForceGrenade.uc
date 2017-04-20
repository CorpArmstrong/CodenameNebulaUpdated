//================================================================================
// ForceGrenade.
//================================================================================
class ForceGrenade extends DeusExProjectile;

var ParticleGenerator smokeGen;

auto simulated state Flying extends Flying
{
	simulated function Explode (Vector HitLocation, Vector HitNormal)
	{
		local Actor A;
		local Vector VelocityToSet;
		local float dist;
	
		foreach VisibleActors(Class'Actor',A,blastRadius)
		{
			if ( A.IsA('DeusExPlayer') && (TeamDMGame(DeusExPlayer(Owner).DXGame) != None) )
			{
				if ( (DeusExPlayer(A).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team) && (A != Owner) )
				{
				}
				return;
			}
		}
		dist=VSize(A.Location - HitLocation);
		VelocityToSet=blastRadius / dist ** 1.10 * Normal(A.Location - HitLocation) * 5800;
		VelocityToSet.Z += 30;
		VelocityToSet += HitNormal * blastRadius / dist ** 1.30 * 1300;
		if ( A != None )
		{
			if ( A.IsA('PlayerPawn') )
			{
				A.SetPhysics(2);
				A.Velocity += VelocityToSet;
			}
			else
			{
				if ( A.IsA('ScriptedPawn') )
				{
					A.SetPhysics(2);
					ScriptedPawn(A).ImpartMomentum(VelocityToSet * 6000,Pawn(Owner));
					A.GotoState('FallingState');
				}
				else
				{
					if ( A.IsA('DeusExDecoration') )
					{
						if ( DeusExDecoration(A).bPushable )
						{
							A.SetPhysics(2);
							A.Velocity += VelocityToSet * 80 / A.Mass;
						}
					}
					else
					{
						if ( A.IsA('Carcass') )
						{
							A.SetPhysics(2);
							A.Velocity += VelocityToSet * 80 / A.Mass;
						}
					}
				}
			}
		}
		continue;
		}
		Super.Explode(HitLocation,HitNormal);
	}
	
}

function PostBeginPlay ()
{
	Super.PostBeginPlay();
	if ( Level.NetMode == 1 )
	{
		return;
	}
	SpawnSmokeEffects();
}

simulated function PostNetBeginPlay ()
{
	Super.PostNetBeginPlay();
	if ( Role != 4 )
	{
		SpawnSmokeEffects();
	}
}

simulated function SpawnSmokeEffects ()
{
	smokeGen=Spawn(Class'ParticleGenerator',self);
	if ( smokeGen != None )
	{
		smokeGen.particleTexture=FireTexture'SmokePuff1';
		smokeGen.particleDrawScale=0.30;
		smokeGen.checkTime=0.02;
		smokeGen.RiseRate=8.00;
		smokeGen.ejectSpeed=0.00;
		smokeGen.particleLifeSpan=2.00;
		smokeGen.bRandomEject=True;
		smokeGen.SetBase(self);
		smokeGen.RemoteRole=0;
	}
}

simulated function Destroyed ()
{
	if ( smokeGen != None )
	{
		smokeGen.DelayedDestroy();
	}
	Super.Destroyed();
}

simulated function DrawExplosionEffects (Vector HitLocation, Vector HitNormal)
{
	local ShockRing ring;
	local ExplosionLight Light;

	Light=Spawn(Class'ExplosionLight',,,HitLocation);
	if ( Light != None )
	{
		Light.RemoteRole=0;
	}
	ring=Spawn(Class'ShockRing',,,HitLocation,rotator(HitNormal));
	if ( ring != None )
	{
		ring.RemoteRole=0;
		ring.size=blastRadius / 32.00;
	}
	ring=Spawn(Class'ShockRing',,,HitLocation,rotator(HitNormal));
	if ( ring != None )
	{
		ring.RemoteRole=0;
		ring.size=blastRadius / 64.00;
	}
	ring=Spawn(Class'ShockRing',,,HitLocation,rotator(HitNormal));
	if ( ring != None )
	{
		ring.RemoteRole=0;
		ring.size=blastRadius / 128.00;
	}
	ring=Spawn(Class'ShockRing',,,HitLocation,rotator(HitNormal));
	if ( ring != None )
	{
		ring.RemoteRole=0;
		ring.size=blastRadius / 256.00;
	}
}

defaultproperties
{
    bExplodes=True
    bBlood=True
    bDebris=True
    blastRadius=512.00
    DamageType=exploded
    AccurateRange=400
    maxRange=800
    ItemName="Force Grenade"
    ItemArticle="a"
    speed=1000.00
    MaxSpeed=1000.00
    Damage=20.00
    MomentumTransfer=40000
    SpawnSound=Sound'DeusExSounds.Weapons.GEPGunFire'
    ImpactSound=Sound'DeusExSounds.Generic.MediumExplosion2'
    ExplosionDecal=Class'DeusEx.ScorchMark'
    Mesh=LodMesh'DeusExItems.HECannister20mm'
}