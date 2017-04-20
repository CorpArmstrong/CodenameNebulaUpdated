//================================================================================
// ProxDisc.
//================================================================================
class ProxDisc extends DeusExProjectile;

const TEAM_NSF= 1;
const TEAM_UNATCO= 0;
var(bowen) Sound ExplodeSound;
var(bowen) float proxRadius;
var(bowen) float SpawnPointCheckRadius;
var(bowen) float mpBlastRadius;
var(bowen) float GravMult;
var(bowen) Texture UNATCOTEX;
var(bowen) Texture NSFTEX;
var(bowen) Texture DEADTEX;
var(bowen) int Health;
var(bowen) int mpHealth;
var(bowen) int MaxAreaDiscs;
var(bowen) int MaxTotalDiscs;
var(bowen) int mpMaxAreaDiscs;
var(bowen) int mpMaxTotalDiscs;
var Actor BlowUpActor;
var bool bWaiting;
var bool bDisabled;
var bool bDestroyedDamage;
var bool bTriedDetonate;
var bool bDoneMsg;
var int SmokeTimer;
var int DieTimer;
var(bowen) int smokeTime;
var(bowen) int DieTime;
var(bowen) int mpDamage;
var ParticleGenerator sparkGen;

replication
{
	reliable if ( Role == 4 )
		SpawnSparks,SpawnSmoke,SetDeadTex,BlowUpActor,bWaiting;
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
		if ( Other == Owner )
		{
			return;
		}
		if ( Owner.IsA('DeusExPlayer') && Other.IsA('DeusExPlayer') )
		{
			if ( TeamDMGame(DeusExPlayer(Owner).DXGame) != None )
			{
				if ( DeusExPlayer(Other).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team )
				{
					return;
				}
			}
		}
		DrawType=0;
		bBlockActors=False;
		bBlockPlayers=False;
		BlowUpActor=Other;
		Detonate();
	}
	
	simulated function HitWall (Vector HitNormal, Actor Wall)
	{
		local ProxDisc disc;
		local ProxDisc FirstDisc;
		local PlayerStart Spawn;
		local SpawnExtension SpawnExt;
		local int i;
	
		if ( Wall.IsA('Mover') && bStuck )
		{
			return;
		}
		if ( Level.NetMode == 0 )
		{
			Super.HitWall(HitNormal,Wall);
			return;
		}
		foreach RadiusActors(Class'ProxDisc',disc,blastRadius * 3)
		{
			if ( disc.Owner == Owner )
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
			}
			continue;
		}
		foreach AllActors(Class'ProxDisc',disc)
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
		foreach RadiusActors(Class'PlayerStart',Spawn,SpawnPointCheckRadius)
		{
			if ( FastTrace(Spawn.Location,Location) &&  !bDoneMsg )
			{
				if ( Owner.IsA('DeusExPlayer') )
				{
					DeusExPlayer(Owner).ClientMessage("Prox discs are not allowed in spawn rooms");
					Log("ProxDisc placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
				}
				else
				{
					Log("ProxDisc was found in spawn room with no player owner");
				}
				SpawnSmoke();
				bDoneMsg=True;
				Destroy();
			}
			continue;
		}
		foreach RadiusActors(Class'SpawnExtension',SpawnExt,SpawnPointCheckRadius)
		{
			if ( FastTrace(SpawnExt.Location,Location) &&  !bDoneMsg )
			{
				if ( Owner.IsA('DeusExPlayer') )
				{
					DeusExPlayer(Owner).ClientMessage("Prox discs are not allowed in spawn rooms");
					Log("ProxDisc placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
				}
				else
				{
					Log("ProxDisc was found in spawn room with no player owner");
				}
				SpawnSmoke();
				bDoneMsg=True;
				Destroy();
			}
			continue;
		}
		Super.HitWall(HitNormal,Wall);
	}
	
}

function Frob (Actor Frobber, Inventory frobWith)
{
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

function PostBeginPlay ()
{
	SetTexture();
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
	if ( bDisabled )
	{
		MultiSkins[1]=DEADTEX;
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
			if (! Owner.IsA('Pawn') ) goto JL007F;
		}
	}
JL007F:
	if ( (Pawn(Owner).HealthHead == 0) || (Pawn(Owner).HealthTorso == 0) )
	{
		Destroy();
	}
	if ( bStuck &&  !bWaiting )
	{
		bWaiting=True;
		SetCollisionSize(proxRadius,proxRadius);
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
	bExplodes=True;
	ImpactSound=ExplodeSound;
	Explode(Location,vect(0.00,0.00,0.00));
	DrawEffects(Location);
}

simulated function DrawEffects (Vector HitLocation)
{
	local ExplosionLight Light;
	local AnimatedSprite expeffect;
	local ShockRing ring;

	expeffect=Spawn(Class'ExplosionMedium',,,HitLocation);
	if ( bStuck )
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
    proxRadius=20.00
    SpawnPointCheckRadius=400.00
    mpBlastRadius=200.00
    GravMult=0.13
    UNATCOTEX=Texture'DeusExDeco.Skins.AlarmLightTex5'
    NSFTEX=Texture'DeusExDeco.Skins.AlarmLightTex3'
    DEADTEX=Texture'UWindow.BlackTexture'
    Health=200
    mpHealth=80
    MaxAreaDiscs=64
    MaxTotalDiscs=1024
    mpMaxAreaDiscs=10
    mpMaxTotalDiscs=60
    smokeTime=30
    DieTime=10000
    mpDamage=130
    bStickToWall=True
    blastRadius=150.00
    DamageType=exploded
    AccurateRange=0
    maxRange=1000
    bIgnoresNanoDefense=True
    ItemName="proximity disc"
    ItemArticle="a"
    speed=1750.00
    MaxSpeed=3000.00
    Damage=600.00
    ImpactSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
    LifeSpan=0.00
    Skin=Texture'Editor.Bkgnd'
    Mesh=LodMesh'DeusExItems.BioCell'
    MultiSkins(0)=Texture'DeusExUI.UserInterface.ConWindowActiveBackground'
    MultiSkins(1)=Texture'DeusExDeco.Skins.AlarmLightTex7'
    MultiSkins(2)=Texture'Editor.BkgndHi'
    MultiSkins(3)=Texture'Editor.BkgndHi'
    MultiSkins(4)=Texture'Editor.BkgndHi'
    MultiSkins(5)=Texture'Editor.BkgndHi'
    MultiSkins(6)=Texture'Editor.BkgndHi'
    MultiSkins(7)=Texture'Editor.BkgndHi'
}