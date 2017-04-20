//================================================================================
// FireBomb.
//================================================================================
class FireBomb extends LAM;

var(bowen) int FlameDamage;
var(bowen) int MaxGrenades;
var(bowen) float SpawnPointCheckRadius;
var bool bDoneMsg;

replication
{
	reliable if ( Role == 4 )
		SpawnSmoke,bDoneMsg;
}

function PostBeginPlay ()
{
	local FireBomb FB;
	local FireBomb first;
	local bool bFoundFirst;
	local int NumFound;

	foreach AllActors(Class'FireBomb',FB)
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

auto simulated state Flying extends Flying
{
	simulated function Explode (Vector HitLocation, Vector HitNormal)
	{
		SpawnDamage(HitLocation);
		Super.Explode(HitLocation,HitNormal);
	}
	
}

simulated function Timer ()
{
	local PlayerStart Spawn;
	local SpawnExtension SpawnExt;

	if ( Level.NetMode == 0 )
	{
		Super.Timer();
		return;
	}
	foreach RadiusActors(Class'PlayerStart',Spawn,SpawnPointCheckRadius)
	{
		if ( FastTrace(Spawn.Location,Location) &&  !bDoneMsg )
		{
			if ( Owner.IsA('DeusExPlayer') )
			{
				DeusExPlayer(Owner).ClientMessage("Incendiary grenades are not allowed in spawn rooms");
				Log("FireLam placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
			}
			else
			{
				Log("FireLam was found in spawn room with no player owner");
			}
			SpawnSmoke();
			bDoneMsg=True;
			Destroy();
		}
		return;
	}
	continue;
	}
	foreach RadiusActors(Class'SpawnExtension',SpawnExt,SpawnPointCheckRadius)
	{
		if ( FastTrace(Spawn.Location,Location) &&  !bDoneMsg )
		{
			if ( Owner.IsA('DeusExPlayer') )
			{
				DeusExPlayer(Owner).ClientMessage("Incendiary grenades are not allowed in spawn rooms");
				Log("FireLam placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
			}
			else
			{
				Log("FireLam was found in spawn room with no player owner");
			}
			SpawnSmoke();
			bDoneMsg=True;
			Destroy();
		}
		return;
	}
	continue;
	}
	if (  !bDoneMsg )
	{
		Super.Timer();
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

function SpawnDamage (Vector HitLocation)
{
	local FireDamage Damage;

	if ( Role == 4 )
	{
		Damage=Spawn(Class'FireDamage',,,HitLocation);
		if ( Damage != None )
		{
			Damage.EffectRadius=blastRadius + 10;
			Damage.Damage=FlameDamage;
			Damage.PawnOwner=Pawn(Owner);
		}
	}
}

defaultproperties
{
    FlameDamage=20
    MaxGrenades=3
    SpawnPointCheckRadius=300.00
    mpBlastRadius=256.00
    mpProxRadius=200.00
    mpLAMDamage=0.00
    mpFuselength=2.00
    spawnWeaponClass=Class'FireLAM'
    ItemName="Incendiary Grenade"
    ItemArticle="an"
    Damage=0.00
    bAlwaysRelevant=True
}