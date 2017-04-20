//================================================================================
// RocketPod.
//================================================================================
class RocketPod extends DeusExDecoration;

var Pawn Target;
var bool bWaiting;
var bool bOutLastTime;
var bool bDeactivated;
var float ClickTime;
var int NumRockets;
var int HealthPct;
var string newName;
var ParticleGenerator sparkGen;
var ParticleGenerator smokeGen;
var(bowen) int MaxRockets;
var(bowen) float maxRange;
var(bowen) float FindAngle;
var(bowen) float ShotTime;
var(bowen) float DoubleClickTime;
var(bowen) float Health;
var(bowen) int FirePitch;
var(bowen) int EMPHitPoints;
var(bowen) string ItemName;
var(bowen) float SpawnPointCheckRadius;
var bool bDoneMsg;

replication
{
	reliable if ( Role == 4 )
		UpdateName,Target,bWaiting,bOutLastTime,bDeactivated,NumRockets,HealthPct,newName,Health,EMPHitPoints;
}

function Tick (float DeltaTime)
{
	local Pawn P;
	local float fangle;
	local Vector TargetLocation;
	local Vector dvect;
	local Vector vvect;
	local Vector X;
	local Vector Y;
	local Vector Z;

	UnfamiliarName=ItemName @ "-" @ string(NumRockets) @ "Rockets left," @ string(HealthPct) $ "% Health";
	newName=UnfamiliarName;
	UpdateName();
	if ( Role != 4 )
	{
		return;
	}
	if ( DeusExPlayer(Owner) == None )
	{
		Deactivate();
		return;
	}
	if ( bOutLastTime )
	{
		ClickTime += DeltaTime;
	}
	if ( ClickTime >= DoubleClickTime )
	{
		bOutLastTime=False;
		ClickTime=0.00;
	}
	if ( bWaiting )
	{
		return;
	}
	if ( Target != None )
	{
		P=Target.nextPawn;
	}
	else
	{
		P=Level.PawnList;
	}
JL00EE:
	if ( P != None )
	{
		if ( VSize(P.Location - Location) < maxRange )
		{
			vvect=Normal(vector(Rotation));
			dvect=Normal(P.Location - Location);
			fangle=ACos(vvect Dot dvect);
			if ( (fangle < FindAngle) && FastTrace(Location,P.Location) )
			{
				if ( P.IsA('DeusExPlayer') )
				{
					if ( TeamDMGame(DeusExPlayer(P).DXGame) != None )
					{
						if ( DeusExPlayer(P).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team )
						{
							P=P.nextPawn;
						}
						else
						{
							if ( (P == Owner) || P.IsA('Spectator') )
							{
								P=P.nextPawn;
							}
							else
							{
								Target=P;
								goto JL0284;
								goto JL0263;
								Target=None;
JL0263:
								goto JL026D;
								Target=None;
JL026D:
								P=P.nextPawn;
							}
						}
					}
				}
			}
		}
		goto JL00EE;
	}
JL0284:
	if ( Target != None )
	{
		if ( Target.IsInState('Dying') )
		{
			Target=None;
			return;
		}
		if ( NumRockets >= 1 )
		{
			SetTimer(ShotTime,False);
			bWaiting=True;
		}
		else
		{
			if ( Role == 4 )
			{
				PlayerPawn(Owner).ClientMessage("|P2Rocketpod: Out of rockets.");
			}
			bWaiting=True;
		}
	}
}

simulated function Timer ()
{
	local RPRocket Rocket;
	local Rotator FireRot;

	bWaiting=False;
	FireRot=Rotation;
	FireRot.Pitch += FirePitch;
	Rocket=Spawn(Class'RPRocket',Owner,,Location,FireRot);
	Rocket.Target=Target;
	Rocket.bTracking=True;
	NumRockets--;
}

simulated function Frob (Actor Frobber, Inventory frobWith)
{
	local AmmoRPRocket Ammo;
	local bool bFound;
	local int AmountToTake;

	if ( Frobber == Owner )
	{
		if ( NumRockets >= MaxRockets )
		{
			bWaiting=False;
			if ( bOutLastTime )
			{
				Pickup();
			}
			else
			{
				if ( Role == 4 )
				{
					DeusExPlayer(Frobber).ClientMessage("Rocket Pod is full. Click twice to pick up.");
				}
			}
			bOutLastTime=True;
			return;
		}
		foreach AllActors(Class'AmmoRPRocket',Ammo)
		{
			if ( Ammo.Owner == Owner )
			{
				bFound=True;
			}
			else
			{
				continue;
			}
		}
		if ( bFound )
		{
			if ( (Ammo.AmmoAmount >= 10) && (NumRockets <= MaxRockets - 10) )
			{
				Ammo.UseAmmo(10);
				NumRockets += 10;
				if ( Role == 4 )
				{
					DeusExPlayer(Frobber).ClientMessage("10 Rockets added.");
				}
				bOutLastTime=False;
			}
			else
			{
				if ( Ammo.AmmoAmount >= 1 )
				{
					AmountToTake=FMin(MaxRockets - NumRockets,Ammo.AmmoAmount);
					NumRockets += AmountToTake;
					if ( Role == 4 )
					{
						DeusExPlayer(Frobber).ClientMessage(string(AmountToTake) @ "Rockets added.");
					}
					Ammo.UseAmmo(AmountToTake);
					bOutLastTime=False;
				}
				else
				{
					if ( bOutLastTime )
					{
						Pickup();
					}
					else
					{
						if ( Role == 4 )
						{
							DeusExPlayer(Frobber).ClientMessage("You have no more rockets to put in. Click twice to pick up.");
						}
					}
					bOutLastTime=True;
				}
			}
		}
		else
		{
			if ( bOutLastTime )
			{
				Pickup();
			}
			else
			{
				if ( Role == 4 )
				{
					DeusExPlayer(Frobber).ClientMessage("You have no more rockets to put in. Click twice to pick up.");
				}
			}
			bOutLastTime=True;
		}
		if ( NumRockets >= 1 )
		{
			bWaiting=False;
		}
	}
	else
	{
		if ( Role == 4 )
		{
			DeusExPlayer(Frobber).ClientMessage("You do not own this pod.");
		}
	}
}

auto state Active extends Active
{
	simulated function TakeDamage (int Damage, Pawn EventInstigator, Vector HitLocation, Vector Momentum, name DamageType)
	{
		if ( (DeusExPlayer(EventInstigator) != None) && (EventInstigator != Owner) )
		{
			if ( TeamDMGame(DeusExPlayer(Owner).DXGame) != None )
			{
				if ( DeusExPlayer(EventInstigator).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team )
				{
					DeusExPlayer(EventInstigator).ClientMessage("You cannot damage a teammate's rocket pod");
					return;
				}
			}
		}
		if ( DamageType == 'EMP' )
		{
			EMPHitPoints -= Damage;
			if ( EMPHitPoints <= 0 )
			{
				SpawnSparks();
				SpawnSmoke();
				Deactivate();
			}
			else
			{
				SpawnSparks();
			}
		}
		else
		{
			if ( (DamageType == 'exploded') || (DamageType == 'None') )
			{
				Health -= 0.30 * Damage;
			}
			else
			{
				if ( DamageType == 'Tantalus' )
				{
					Health -= Health;
				}
				else
				{
					if ( (DamageType == 'Flamed') || (DamageType == 'Burned') || (DamageType == 'shot') )
					{
						Health -= 1.50 * Damage;
					}
				}
			}
		}
		if ( Health <= 0 )
		{
			Explode(Location);
			Destroy();
		}
		HealthPct=100 * Health / Default.Health;
	}
	
}

function Destroyed ()
{
	if ( (Role == 4) &&  !bDeactivated )
	{
		DeusExPlayer(Owner).ClientMessage("|P2Rocket Pod was destroyed.");
	}
}

simulated function Deactivate ()
{
	local RPT Pickup;

	Pickup=Spawn(Class'RPT',,,Location);
	Pickup.NumRockets=NumRockets;
	Pickup.Health=Health;
	Pickup.bTossedOut=True;
	Pickup.RespawnTime=0.00;
	Pickup.bSecondHand=True;
	if ( (Role == 4) && (Owner != None) )
	{
		DeusExPlayer(Owner).ClientMessage("|P2Rocket Pod was deactivated.");
	}
	bDeactivated=True;
	Destroy();
}

simulated function Pickup ()
{
	local RPT Pickup;
	local AmmoRPRocket Ammo;

	Pickup=Spawn(Class'RPT');
	Pickup.RespawnTime=0.00;
	Pickup.Health=Health;
	Pickup.bTossedOut=True;
	Pickup.bSecondHand=True;
	Pickup.Frob(Owner,None);
	GiveAmmo(Pawn(Owner));
	bDeactivated=True;
	Destroy();
}

function GiveAmmo (Pawn Other)
{
	local Ammo AmmoType;

	AmmoType=Ammo(Other.FindInventoryType(Class'AmmoRPRocket'));
	if ( AmmoType != None )
	{
		AmmoType.AddAmmo(NumRockets);
	}
	else
	{
		AmmoType=Spawn(Class'AmmoRPRocket');
		AmmoType.RespawnTime=0.00;
		Other.AddInventory(AmmoType);
		AmmoType.BecomeItem();
		AmmoType.AmmoAmount=NumRockets;
		AmmoType.GotoState('Idle2');
	}
}

simulated function SpawnSmoke ()
{
	local ParticleGenerator gen;

	gen=Spawn(Class'ParticleGenerator',self,,Location,rot(16384,0,0));
	if ( gen != None )
	{
		gen.RemoteRole=0;
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
		sparkGen.RemoteRole=0;
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

simulated function UpdateName ()
{
	UnfamiliarName=newName;
}

simulated function Setup (bool bAddInitialAmmo)
{
	local Inventory Ammo;

	HealthPct=100 * Health / Default.Health;
	Ammo=DeusExPlayer(Owner).FindInventoryType(Class'AmmoRPRocket');
	if ( DeusExAmmo(Ammo) != None )
	{
		if ( DeusExAmmo(Ammo).AmmoAmount >= 10 )
		{
			DeusExAmmo(Ammo).UseAmmo(10);
			NumRockets += 10;
			if ( Role == 4 )
			{
				DeusExPlayer(Owner).ClientMessage("10 Rockets added.");
			}
		}
		else
		{
			if ( Role == 4 )
			{
				DeusExPlayer(Owner).ClientMessage(string(DeusExAmmo(Ammo).AmmoAmount) @ "Rockets added.");
			}
			NumRockets += DeusExAmmo(Ammo).AmmoAmount;
			DeusExAmmo(Ammo).UseAmmo(DeusExAmmo(Ammo).AmmoAmount);
		}
	}
	if ( bAddInitialAmmo )
	{
		NumRockets += 3;
	}
}

static final function float ACos (float A)
{
	if ( (A > 1) || (A < -1) )
	{
		return 0.00;
	}
	if ( A == 0 )
	{
		return 3.14 / 2.00;
	}
	A=Atan(Sqrt(1.00 - Square(A)) / A);
	if ( A < 0 )
	{
		A += 3.14;
	}
	return A;
}

simulated function PostBeginPlay ()
{
	local PlayerStart Spawn;
	local SpawnExtension SpawnExt;

	if ( Level.NetMode == 0 )
	{
		Timer();
		return;
	}
	foreach RadiusActors(Class'PlayerStart',Spawn,SpawnPointCheckRadius)
	{
		if ( FastTrace(Spawn.Location,Location) &&  !bDoneMsg )
		{
			if ( Owner.IsA('DeusExPlayer') )
			{
				DeusExPlayer(Owner).ClientMessage("Rocket pods are not allowed in spawn rooms");
				Log("RocketPod placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
			}
			else
			{
				Log("RocketPod was found in spawn room with no player owner");
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
				DeusExPlayer(Owner).ClientMessage("Rocket pods are not allowed in spawn rooms");
				Log("RocketPod placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
			}
			else
			{
				Log("RocketPod was found in spawn room with no player owner");
			}
			SpawnSmoke();
			bDoneMsg=True;
			Destroy();
		}
		return;
	}
	continue;
	}
}

defaultproperties
{
    MaxRockets=30
    maxRange=1500.00
    FindAngle=0.75
    ShotTime=1.00
    DoubleClickTime=3.00
    Health=1000.00
    FirePitch=8500
    EMPHitPoints=100
    ItemName="Rocket Pod"
    SpawnPointCheckRadius=300.00
    HitPoints=1000
    minDamageThreshold=30
    Flammability=0.00
    bExplosive=True
    explosionDamage=1000
    explosionRadius=1000.00
    bPushable=False
    Mesh=LodMesh'DeusExItems.AssaultShotgun3rd'
    UnfamiliarName="Rocket Pod"
}