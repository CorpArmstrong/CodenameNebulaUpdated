//=============================================================================
// RocketPod. (c) 2003 JimBowen
//=============================================================================
class RocketPod expands DeusExDecoration
config(Bowen);

var pawn Target;
var bool bWaiting, bOutLastTime, bDeactivated;
var float ClickTime;
var int NumRockets, HealthPct;
var string NewName;
var ParticleGenerator SparkGen, SmokeGen;
var BowenGlowSprite GlowSprite;
var (Bowen) int MaxRockets;
var (Bowen) float MaxRange, FindAngle, ShotTime, DoubleClickTime, Health;
var (Bowen) int FirePitch, EMPHitPoints;
var (Bowen) string ItemName;
var (Bowen) float SpawnPointCheckRadius;
var (Bowen) config vector SpriteOffset;
var bool bDoneMsg, bDoneWarn;
var (Bowen) config bool bShowLight;
var (Bowen) config bool bSPShowLight;

const TEAM_UNATCO 	= 0;
const TEAM_NSF		= 1;

Replication
{
	Reliable if (Role == ROLE_Authority)
		bWaiting, bOutLastTime, bDeactivated, HealthPct, NumRockets, EMPHitPoints, Health, NewName, Target, UpdateName;
}

function tick (float deltatime)
{
	local pawn p;
	local float fangle;
	local vector TargetLocation, dvect, vvect, X, Y, Z;
	
		unfamiliarName = ItemName @ "-" @ NumRockets @ "Rockets left," @ HealthPct $ "% Health";
		NewName = unfamiliarName;
	//	log("Name is:" @ UnfamiliarName);
		UpdateName();
		
		if (Role != ROLE_Authority)
			return;
		
		if (DeusExPlayer(Owner) == None)
		{
			Deactivate();
			return;
		}
	
		if (bOutLastTime)
			ClickTime += DeltaTime;
		
		if (ClickTime >= DoubleClickTime)
		{
			bOutlastTime = False;
			ClickTime = 0;
		}
	
		if (bWaiting)
			return;
		if (Target != None)
			p = Target.NextPawn; 
		else
			p = Level.PawnList;
		
		while (p != None)
		{
			if (VSize(P.Location - Location) < MaxRange)
			{
				vvect = normal(vector(Rotation));
				dvect = normal(p.Location - Location);
				fangle = Acos(vvect dot dvect);
				if ((fangle < FindAngle) && FastTrace(Location, p.Location))
				{
					if (P.IsA('DeusExPlayer'))
						if  (TeamDMGame(DeusExPlayer(p).DXGame) != None)
							if (DeusExPlayer(p).PlayerReplicationInfo.team == DeusExPlayer(Owner).PlayerReplicationInfo.team)
							{
								p = p.NextPawn;
								continue;
							}
					if (p == Owner || p.IsA('Spectator'))
					{
						p = p.NextPawn;
						continue;
					}
						
					Target = p;
					//log ("RocketPod - aquired target: " @ p);
					break;
				}
				else target = None;
			}
			else target = None;
			p = p.NextPawn;
		}	
		
		if (Target != None)
		{
			if (Target.IsInState('Dying'))
			{
				Target = None;
				return;
			}
			if (NumRockets >= 1)
			{
				SetTimer(ShotTime, False);
				bWaiting = True;
			}
			else
			{
				if (Role == ROLE_Authority)
					PlayerPawn(Owner).ClientMessage("|P2Rocketpod: Out of rockets.");
				bWaiting = True;
			}
		}

}

simulated function Timer()
{
	local RPRocket Rocket;
	local rotator FireRot;
	
		bWaiting = False;
		
		FireRot = Rotation;
		FireRot.Pitch += FirePitch;

		Rocket = Spawn(class'RPRocket', Owner,, Location, FireRot);
		
		Rocket.Target = Target;
		Rocket.bTracking = True;
		bDoneWarn=False;
	
		NumRockets --;
}


simulated function frob (Actor Frobber, Inventory FrobWith)
{
	local AmmoRPRocket Ammo;
	local bool bFound;
	local int AmountToTake;
	
		if (Frobber == Owner)
		{
			if (NumRockets >= MaxRockets)
			{
				bWaiting = False;
				if (bOutLastTime)
					PickUp();
				else if (Role == ROLE_Authority)
					DeusExPlayer(Frobber).ClientMessage("Rocket Pod is full. Click twice to pick up.");
				bOutLastTime = True;
				return;				
			}
		
			foreach allactors (class'AmmoRPRocket', Ammo)
				if (Ammo.Owner == Owner)
				{
					bFound = True;
					break;
				}

				if(bFound)
				{
					if (Ammo.AmmoAmount >= 10 && NumRockets <= MaxRockets - 10)
					{
						Ammo.UseAmmo(10);
						NumRockets += 10;
						if (Role == ROLE_Authority)
							DeusExPlayer(Frobber).ClientMessage("10 Rockets added.");
						bOutLastTime = False;
					}
					else if (Ammo.AmmoAmount >= 1)
					{
						AmountToTake = FMin((MaxRockets - Numrockets), Ammo.AmmoAmount);
						NumRockets += AmountToTake;
						if (Role == ROLE_Authority)
							DeusExPlayer(Frobber).ClientMessage(AmountToTake @ "Rockets added.");
						Ammo.UseAmmo(AmountToTake);
						bOutLastTime = False;
					}
					else
					{
						if (bOutLastTime)
							PickUp();
						else if (Role == ROLE_Authority)
							DeusExPlayer(Frobber).ClientMessage("You have no more rockets to put in. Click twice to pick up.");
						bOutLastTime = True;
					}
				}
				else
				{
					if (bOutLastTime)
						PickUp();
					else if (Role == ROLE_Authority)
						DeusExPlayer(Frobber).ClientMessage("You have no more rockets to put in. Click twice to pick up.");
					bOutLastTime = True;
				}

				
				if (NumRockets >= 1)
					bWaiting = False;
				
		}
		else if (Role == ROLE_Authority)
			DeusExPlayer(Frobber).ClientMessage("You do not own this pod.");

}

auto state active
{
	simulated function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		if (DeusExPlayer(EventInstigator) !=None && EventInstigator != Owner)
			if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
				if (DeusExPlayer(EventInstigator).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerreplicationInfo.Team)
				{
					if(!bDoneWarn)
						DeusExPlayer(EventInstigator).ClientMessage("You cannot damage a teammate's rocket pod");
					bDoneWarn=True;
					return;
				}
	 
		if (DamageType == 'EMP')
			{
				EMPHitPoints -= Damage;
				if (EMPHitPoints <= 0)
				{
					SpawnSparks();
					SpawnSmoke();
					Deactivate();
				}
				else
					SpawnSparks();
			}
			else if (DamageType == 'Exploded' || DamageType == '')
				Health -= 0.3*Damage;
			else if (DamageType == 'Tantalus')
				Health -= Health;
			else if (DamageType == 'Flamed' || DamageType == 'Burned' || DamageType == 'Shot')
				Health -= 1.5*Damage;
			
			if (Health <= 0)
			{
				Explode(Location);
				Destroy();
			}
			
			HealthPct = int (100*(Health / Default.Health));
	}
}

function Destroyed()
{
	if (Role == ROLE_Authority && !bDeactivated)
		DeusExPlayer(Owner).ClientMessage("|P2Rocket Pod was destroyed.");
	if (GlowSprite != None)
		GlowSprite.Destroy();
}

function Deactivate()
{
	local RPT Pickup;
		
		Pickup = Spawn (Class'RPT',,,Location);
		Pickup.NumRockets = NumRockets;
		Pickup.Health = Health;
		Pickup.bTossedOut = True;
		Pickup.RespawnTime = 0;
		Pickup.bSecondHand = True;
		if (Role == ROLE_Authority && Owner != None)
			DeusExPlayer(Owner).ClientMessage("|P2Rocket Pod was deactivated.");
		bDeactivated = True;
		Destroy();
}

simulated function PickUp()
{
	local RPT Pickup;
	local AmmoRPRocket Ammo;
	
		if (bDeactivated)
			Return;
		bDeactivated = True;
		Pickup = Spawn (Class'RPT');
		Pickup.RespawnTime = 0;
		Pickup.Health = Health;
		Pickup.bTossedOut = True;
		Pickup.bSecondHand = True;
		Pickup.frob(Owner, None);	
		GiveAmmo(Pawn(Owner));
		Destroy();
}

function GiveAmmo( Pawn Other )
{
	local ammo AmmoType;
		AmmoType = Ammo(Other.FindInventoryType(class'AmmoRPRocket'));
		if ( AmmoType != None )
			AmmoType.AddAmmo(NumRockets);
		else
		{
			AmmoType = Spawn(class'AmmoRPRocket');	// Create ammo type required	
			AmmoType.RespawnTime = 0;	
			Other.AddInventory(AmmoType);		// and add to player's inventory
			AmmoType.BecomeItem();
			AmmoType.AmmoAmount = numRockets; 
			AmmoType.GotoState('Idle2');
		}
}	


simulated function SpawnSmoke()
{
	local ParticleGenerator gen;
	
				gen = Spawn(class'ParticleGenerator', Self,, Location, rot(16384,0,0));
				if (gen != None)
				{
					gen.remoterole = Role_None;
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

simulated function SpawnSparks()
{
	local Vector loc;

	if ((sparkGen == None) || (sparkGen.bDeleteMe))
	{
		loc = Location;
		loc.z += CollisionHeight/2;
		sparkGen = Spawn(class'ParticleGenerator', Self,, loc, rot(16384,0,0));
		if (sparkGen != None)
			sparkGen.SetBase(Self);
			sparkgen.remoterole = ROLE_None;
	}

			if (sparkGen != None)
			{
				sparkGen.particleTexture = Texture'Effects.Fire.SparkFX1';
				sparkGen.particleDrawScale = 0.2;
				sparkGen.bRandomEject = True;
				sparkGen.ejectSpeed = 100.0;
				sparkGen.bGravity = True;
				sparkGen.bParticlesUnlit = True;
				sparkGen.frequency = 0.2;
				sparkGen.riseRate = 10;
				sparkGen.spawnSound = Sound'Spark2';
				sparkGen.LifeSpan = 2;
			}
}

simulated function UpdateName()
{
	UnfamiliarName = NewName;
}

simulated function SetUp(bool bAddInitialAmmo)
{
	local Inventory Ammo;
	
		HealthPct = int(100*(Health / Default.Health));
		Ammo = DeusExPlayer(Owner).FindInventoryType(class'AmmoRPRocket');
		if (DeusExAmmo(Ammo) != None)
		{
			if (DeusExAmmo(Ammo).AmmoAmount >= 10)
			{
				DeusExAmmo(Ammo).UseAmmo(10);
				NumRockets += 10;
				if (Role == ROLE_Authority)
					DeusExPlayer(Owner).ClientMessage("10 Rockets added.");
			}
			else
			{
				if (Role == ROLE_Authority)
					DeusExPlayer(Owner).ClientMessage(DeusExAmmo(Ammo).AmmoAmount @ "Rockets added.");
				NumRockets += DeusExAmmo(Ammo).AmmoAmount;
				DeusExAmmo(Ammo).UseAmmo(DeusExAmmo(Ammo).AmmoAmount);
			}
		}	
		if(bAddInitialAmmo)
			NumRockets += 3;

			
}

static final function float ACos  ( float A )	// thanks to UnrealWiki for this
{
  if (A>1||A<-1) //outside domain!
    return 0;
  if (A==0) //div by 0 check
    return (Pi/2.0);
  A=ATan(Sqrt(1.0-Square(A))/A);
  if (A<0)

    A+=Pi;
  Return A;
}


function PostBeginPlay()
{

	local PlayerStart SpawnPoint;
	local SpawnExtension SpawnExt;
	
		if (Level.NetMode == NM_Standalone)
		{
			if(bSPShowLight)
			{
				GlowSprite = Spawn (class'BowenGlowSprite',Self,,Location+SpriteOffset);
				GlowSprite.Texture = Texture'DeusExDeco.Skins.AlarmLightTex4';
				GlowSprite.LightHue = 160;
			}
			Bump(Owner);
			return;
		}

		if(Role == ROLE_Authority && Level.NetMode != NM_Client && bShowLight)
		{
			GlowSprite = Spawn (class'BowenGlowSprite',Self,,Location+SpriteOffset);
			if (GlowSprite != None)
			{
				if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
				{
					if (DeusExPlayer(Owner).PlayerReplicationInfo.Team == TEAM_NSF)
					{
						GlowSprite.Texture = Texture'DeusExDeco.Skins.AlarmLightTex2';
						GlowSprite.LightHue = 0;
					}
					else if (DeusExPlayer(Owner).PlayerReplicationInfo.Team == TEAM_UNATCO)
					{
						GlowSprite.Texture = Texture'DeusExDeco.Skins.AlarmLightTex6';
						GlowSprite.LightHue = 64;
					}
				}
			}
		}

		foreach RadiusActors (class 'PlayerStart', SpawnPoint, SpawnPointCheckRadius)
		{
			if (FastTrace(SpawnPoint.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
			{
				if (Owner.IsA('DeusExPlayer'))
				{
					DeusExPlayer(Owner).ClientMessage("Rocket pods are not allowed in spawn rooms");
					log("RocketPod placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
				}
				else log ("RocketPod was found in spawn room with no player owner");
				SpawnSmoke();
				bDoneMsg = True;
				Destroy();
				return;
			}
		}
		
		foreach RadiusActors (class 'SpawnExtension', SpawnExt, SpawnPointCheckRadius)
		{
			if (FastTrace(SpawnPoint.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
			{
				if (Owner.IsA('DeusExPlayer'))
				{
					DeusExPlayer(Owner).ClientMessage("Rocket pods are not allowed in spawn rooms");
					log("RocketPod placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
				}
				else log ("RocketPod was found in spawn room with no player owner");
				SpawnSmoke();
				bDoneMsg = True;
				Destroy();
				return;
			}
		}

}

//---END-CLASS---

defaultproperties
{
     MaxRockets=30
     maxRange=1500.000000
     FindAngle=0.750000
     ShotTime=1.000000
     DoubleClickTime=3.000000
     Health=1000.000000
     FirePitch=8500
     EMPHitPoints=50
     SpriteOffset=(0,0,75)
     ItemName="Rocket Pod"
     SpawnPointCheckRadius=300.000000
     HitPoints=1000
     minDamageThreshold=30
     Flammability=0.000000
     bExplosive=True
     explosionDamage=1000
     explosionRadius=1000.000000
     bPushable=False
     Mesh=LodMesh'DeusExItems.AssaultShotgun3rd'
     UnfamiliarName="Rocket Pod"
     bShowLight=True
     bSPShowLight=False
}
