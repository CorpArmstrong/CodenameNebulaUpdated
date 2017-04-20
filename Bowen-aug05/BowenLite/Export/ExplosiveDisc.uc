//================================================================================
// ExplosiveDisc.
//================================================================================
class ExplosiveDisc extends DeusExProjectile;

const TEAM_NSF= 1;
const TEAM_UNATCO= 0;
var(bowen) Sound ExplodeSound;
var(bowen) int Health;
var(bowen) int mpHealth;
var(bowen) int mpDamage;
var(bowen) Texture UNATCOTEX;
var(bowen) Texture NSFTEX;
var(bowen) Texture DEADTEX;
var(bowen) int MaxAreaDiscs;
var(bowen) int MaxTotalDiscs;
var(bowen) int mpMaxAreaDiscs;
var(bowen) int mpMaxTotalDiscs;
var(bowen) float mpBlastRadius;
var(bowen) float GravMult;
var Actor BlowUpActor;
var bool bWaiting;
var bool bDisabled;
var bool bDestroyedDamage;
var bool bTriedDetonate;
var bool bDead;
var int SmokeTimer;
var int DieTimer;
var(bowen) int smokeTime;
var(bowen) int DieTime;
var ParticleGenerator sparkGen;
var bool bDetonated;

replication
{
	reliable if ( Role == 4 )
		SpawnSparks,SpawnSmoke,SetDeadTex,BlowUpActor,bWaiting,bDead;
}

simulated function PreBeginPlay ()
{
	if ( Level.NetMode != 0 )
	{
		Damage=mpDamage;
		blastRadius=mpBlastRadius;
		MaxAreaDiscs=mpMaxAreaDiscs;
		MaxTotalDiscs=mpMaxTotalDiscs;
		Health=mpHealth;
	}
	Super.PreBeginPlay();
}

auto simulated state Flying extends Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other == Owner) || bWaiting )
		{
			return;
		}
		DrawType=0;
		bBlockActors=False;
		bBlockPlayers=False;
		BlowUpActor=Other;
		bWaiting=True;
		if ( Other.IsA('Pawn') )
		{
			if ( Pawn(Other).ReducedDamageType == 'All' )
			{
				Detonate();
				return;
			}
		}
		if ( Role == 4 )
		{
			Other.TakeDamage(Damage / 90,Pawn(Owner),Other.Location,vect(0.00,0.00,0.00),DamageType);
		}
		if ( Other.IsA('DeusExPlayer') && (Role == 4) )
		{
			DeusExPlayer(Other).ClientMessage("You have a remote detonated disc stuck to you!");
		}
	}
	
	simulated function HitWall (Vector HitNormal, Actor Wall)
	{
		local ExplosiveDisc disc;
		local ExplosiveDisc FirstDisc;
		local int i;
	
		if ( Wall.IsA('Mover') && bStuck )
		{
			return;
		}
		foreach RadiusActors(Class'ExplosiveDisc',disc,blastRadius * 3)
		{
			if ( (FirstDisc == None) && (disc != None) )
			{
				FirstDisc=disc;
			}
			i++;
			if ( i > MaxAreaDiscs )
			{
				FirstDisc.Destroy();
			}
			continue;
		}
		foreach AllActors(Class'ExplosiveDisc',disc)
		{
			if ( disc.Owner == Owner )
			{
				if ( (FirstDisc == None) && (disc != None) )
				{
					FirstDisc=disc;
				}
				i++;
				if ( i > MaxTotalDiscs )
				{
					FirstDisc.Destroy();
				}
			}
			continue;
		}
		Super.HitWall(HitNormal,Wall);
	}
	
}

function Frob (Actor Frobber, Inventory frobWith)
{
}

function PostBeginPlay ()
{
	SetTexture();
}

simulated function TakeDamage (int Dam, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	if (  !(DamageType == 'EMP') || (DamageType == 'Stunned') || (DamageType == 'Poison') )
	{
		if ( Dam > Health )
		{
			Detonate();
			bDestroyedDamage=True;
		}
		Health -= Dam / 5;
	}
	if ( DamageType == 'EMP' )
	{
		if ( Level.NetMode != 0 )
		{
			LifeSpan=60.00;
		}
		if (  !bDisabled )
		{
			Health=Default.Health / 2;
		}
		bDisabled=True;
		SetDeadTex();
	}
}

simulated function SetTexture ()
{
	if ( Owner.IsA('DeusExPlayer') )
	{
		if ( TeamDMGame(DeusExPlayer(Owner).DXGame) != None )
		{
			if ( DeusExPlayer(Owner).PlayerReplicationInfo.Team == 0 )
			{
				MultiSkins[1]=UNATCOTEX;
			}
			else
			{
				if ( DeusExPlayer(Owner).PlayerReplicationInfo.Team == 1 )
				{
					MultiSkins[1]=NSFTEX;
				}
			}
		}
	}
}

function Timer ()
{
}

simulated function SetDeadTex ()
{
	MultiSkins[1]=DEADTEX;
}

simulated function Tick (float DeltaTime)
{
	local float dist;

	Super.Tick(DeltaTime);
	if ( bDead && (Level.NetMode == 3) )
	{
		Destroy();
	}
	dist=Abs(VSize(initLoc - Location));
	if ( dist > AccurateRange )
	{
		Acceleration=GravMult * Region.Zone.ZoneGravity;
	}
	if ( bWaiting )
	{
		if ( Owner == None )
		{
			Destroy();
		}
		else
		{
			if (! Owner.IsA('Pawn') ) goto JL00A4;
		}
	}
JL00A4:
	if ( (Pawn(Owner).HealthHead == 0) || (Pawn(Owner).HealthTorso == 0) )
	{
		Destroy();
	}
	if ( bStuck )
	{
		bWaiting=True;
	}
	if ( bDisabled )
	{
		SmokeTimer++;
		DieTimer++;
	}
	if ( SmokeTimer == smokeTime )
	{
		SpawnSmoke();
		SmokeTimer=0;
	}
	if ( DieTimer == DieTime )
	{
		Destroy();
	}
	if ( BlowUpActor != None )
	{
		SetLocation(BlowUpActor.Location);
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

simulated function SpawnSparks ()
{
	local Vector Loc;

	if ( (sparkGen == None) || sparkGen.bDeleteMe )
	{
		Loc=Location;
		Loc.Z += CollisionHeight / 2;
		sparkGen=Spawn(Class'ParticleGenerator',self,,Loc,rot(16384,0,0));
		if ( sparkGen != None )
		{
			sparkGen.SetBase(self);
		}
	}
	if ( sparkGen != None )
	{
		sparkGen.particleTexture=FireTexture'SparkFX1';
		sparkGen.particleDrawScale=0.20;
		sparkGen.bRandomEject=True;
		sparkGen.ejectSpeed=100.00;
		sparkGen.bGravity=True;
		sparkGen.bParticlesUnlit=True;
		sparkGen.Frequency=0.20;
		sparkGen.RiseRate=10.00;
		sparkGen.SpawnSound=Sound'Spark2';
		sparkGen.LifeSpan=2.00;
	}
}

function Detonate ()
{
	if ( bDisabled &&  !bDestroyedDamage )
	{
		SpawnSparks();
		if ( (Level.NetMode != 0) &&  !bTriedDetonate )
		{
			LifeSpan=5.00;
		}
		bTriedDetonate=True;
		return;
	}
	bDetonated=True;
	bExplodes=True;
	ImpactSound=ExplodeSound;
	if ( BlowUpActor == None )
	{
		Explode(Location,vect(0.00,0.00,0.00));
		DrawEffects(Location);
	}
	else
	{
		Explode(BlowUpActor.Location,vect(0.00,0.00,0.00));
		if ( Role == 4 )
		{
			BlowUpActor.TakeDamage(Damage,Pawn(Owner),BlowUpActor.Location,vect(0.00,0.00,0.00),DamageType);
		}
		DrawEffects(BlowUpActor.Location);
	}
}

function Destroyed ()
{
	bDead=True;
	Super.Destroyed();
}

simulated function DrawEffects (Vector HitLocation)
{
	local ExplosionLight Light;
	local AnimatedSprite expeffect;
	local ShockRing ring;

	expeffect=Spawn(Class'ExplosionMedium',,,HitLocation);
	if ( bStuck && (BlowUpActor == None) )
	{
		Light=Spawn(Class'ExplosionLight',,,HitLocation);
		if ( Light != None )
		{
			Light.size=4;
		}
		ring=Spawn(Class'ShockRing',,,HitLocation,rot(16384,0,0));
		if ( ring != None )
		{
			ring.size=blastRadius / 32.00;
		}
		ring=Spawn(Class'ShockRing',,,HitLocation,rot(0,0,0));
		if ( ring != None )
		{
			ring.size=blastRadius / 32.00;
		}
		ring=Spawn(Class'ShockRing',,,HitLocation,rot(0,16384,0));
		if ( ring != None )
		{
			ring.size=blastRadius / 32.00;
		}
	}
}

defaultproperties
{
    ExplodeSound=Sound'DeusExSounds.Generic.SmallExplosion1'
    Health=200
    mpHealth=100
    mpDamage=100
    UNATCOTEX=Texture'DeusExDeco.Skins.AlarmLightTex5'
    NSFTEX=Texture'DeusExDeco.Skins.AlarmLightTex3'
    DEADTEX=Texture'UWindow.BlackTexture'
    MaxAreaDiscs=30
    MaxTotalDiscs=100
    mpMaxAreaDiscs=15
    mpMaxTotalDiscs=40
    mpBlastRadius=200.00
    GravMult=0.13
    smokeTime=30
    DieTime=10000
    bStickToWall=True
    blastRadius=200.00
    DamageType=exploded
    AccurateRange=0
    maxRange=1000
    bIgnoresNanoDefense=True
    ItemName="Remote detonated disc"
    ItemArticle="a"
    speed=1750.00
    MaxSpeed=3000.00
    Damage=1000.00
    ImpactSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
    LifeSpan=0.00
    Skin=Texture'Editor.BkgndHi'
    Mesh=LodMesh'DeusExItems.BioCell'
    MultiSkins(0)=Texture'Editor.BkgndHi'
    MultiSkins(1)=Texture'DeusExDeco.Skins.AlarmLightTex7'
    MultiSkins(2)=Texture'Editor.BkgndHi'
    MultiSkins(3)=Texture'Editor.BkgndHi'
    MultiSkins(4)=Texture'Editor.BkgndHi'
    MultiSkins(5)=Texture'Editor.BkgndHi'
    MultiSkins(6)=Texture'Editor.BkgndHi'
    MultiSkins(7)=Texture'Editor.BkgndHi'
}