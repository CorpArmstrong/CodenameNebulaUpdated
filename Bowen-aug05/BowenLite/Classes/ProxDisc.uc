//=============================================================================
// ProxDisc. 	(c) 2003 JimBowen
//=============================================================================
class ProxDisc extends DeusExProjectile;

var(Bowen) Sound ExplodeSound;
var(Bowen) float ProxRadius, SpawnPointCheckRadius, mpBlastRadius, GravMult;
var(Bowen) texture UNATCOTEX, NSFTEX, DEADTEX;
var(Bowen) int Health, mpHealth;
var(Bowen) int MaxAreaDiscs, MaxTotalDiscs, mpMaxAreaDiscs, mpMaxTotalDiscs;
var actor BlowUpActor;
var bool bWaiting, bDisabled, bDestroyedDamage, bTriedDetonate, bDoneMsg;
var int SmokeTimer, DieTimer;
var(Bowen) int SmokeTime, DieTime, mpDamage;
var ParticleGenerator SparkGen;
var int Team;

const TEAM_UNATCO 	= 0;
const TEAM_NSF		= 1;

replication
{
	reliable if (Role == ROLE_Authority)
		BlowUpActor, bWaiting, SpawnSparks, SpawnSmoke, SetDeadTex;
}

simulated function PreBeginPlay()
{
	if(Level.NetMode != NM_Standalone)
	{
		Damage = mpDamage;
		BlastRadius = mpBlastRadius;
		MaxAreaDiscs = mpMaxAreaDiscs;
		MaxTotalDiscs = mpMaxTotalDiscs;
		Health = mpHealth;
		if (Owner.IsA('DeusExPlayer')) 
			if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)	
				Team = DeusExPlayer(Owner).PlayerReplicationInfo.Team;
	}
	Super.PreBeginPlay();
}

auto simulated state flying
{
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if (Other == Owner)
			return;
		if (Owner.IsA('DeusExPlayer') && Other.IsA('DeusExPlayer')) 
			if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)	
				if (DeusExPlayer(Other).PlayerReplicationInfo.Team == Team)
					return;
			
		DrawType = DT_None;
		bBlockActors = false;
		bBlockPlayers = false;
		BlowUpActor = Other;
		Detonate();
	}
	
	
	simulated function HitWall(vector HitNormal, actor Wall)
	{
		local proxdisc disc;
		local proxdisc FirstDisc;
		local PlayerStart Spawn;
		local SpawnExtension SpawnExt;
		local int i;
			
		if (Wall.IsA('Mover') && bStuck)  	// screw movers
			return;							// they cause servers to crash
			
		if (Level.NetMode == NM_Standalone)
		{
			Super.HitWall(HitNormal, Wall);
			return;
		}
			
			foreach radiusactors (class 'ProxDisc', disc, blastradius * 3 )
			{
				if (disc.Owner == Owner)
				{
					if (FirstDisc == None && Disc != None)
						FirstDisc = Disc;
					i++;	
					if (i > MaxAreaDiscs)
						FirstDisc.Destroy();
				}
			
			}
			
			foreach allactors (class 'ProxDisc', disc)
			{
				if (disc.Owner == Owner)
				{
					if (FirstDisc == None && Disc != None)
						FirstDisc = Disc;
					i++;	
					if (i > MaxTotalDiscs)
						FirstDisc.Destroy();
				}
			
			}

			
			foreach RadiusActors (class 'PlayerStart', Spawn, SpawnPointCheckRadius)
			{
				if (FastTrace(Spawn.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
				{
					if (Owner.IsA('DeusExPlayer'))
					{
						DeusExPlayer(Owner).ClientMessage("Prox discs are not allowed in spawn rooms");
						log("ProxDisc placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
					}
					else log ("ProxDisc was found in spawn room with no player owner");
					SpawnSmoke();
					bDoneMsg = True;
					Destroy();
				}
			}

			foreach RadiusActors (class 'SpawnExtension', SpawnExt, SpawnPointCheckRadius)
			{
				if (FastTrace(SpawnExt.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
				{
					if (Owner.IsA('DeusExPlayer'))
					{
						DeusExPlayer(Owner).ClientMessage("Prox discs are not allowed in spawn rooms");
						log("ProxDisc placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
					}
					else log ("ProxDisc was found in spawn room with no player owner");
					SpawnSmoke();
					bDoneMsg = True;
					Destroy();
				}
			}

			// prevent hashing failure with movers
/*			if (Wall.IsA('Mover'))
			{
				SetPhysics(PHYS_None);
				SetCollision(,False);
				bStuck = True;
				return;
			}				//that doesnt seem to prevent the error

			// do this instead
			SetCollision(,False);
			SetPhysics(PHYS_None);
			// nope, still causes an error:
			//   DeusExMover moved without proper hashing
			// which crashes the server completely
			// so im ignoring movers ENTIRELY (see above)
			
			// the error was caused when a mover encroaches a disc
			// thats already stuck to a non-mover brush
			// still not sure exactly why it causesit to crash
			*/			

			Super.HitWall(HitNormal, Wall);
	}
}

function Frob(Actor Frobber, Inventory frobWith)
{
}

simulated function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	if (!(DamageType == 'EMP' || DamageType == 'Stunned' || DamageType == 'Poison'))	
	{
		if (Dam > Health)
		{
			Detonate();
			bDestroyedDamage = True;
		}
		
		Health -= Dam/5;
	}
	
	if(DamageType == 'EMP')
	{
		if (Level.NetMode != NM_Standalone)
			LifeSpan = 60;
		if (!bDisabled)
			Health = Default.Health / 2;
		bDisabled = True;
		SetDeadTex();
	}
}


function PostBeginPlay()
{  
   SetTexture();
}

simulated function SetTexture()
{
		if (Owner.IsA('DeusExPlayer')) 
			if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)	
				if (Team == TEAM_UNATCO)
					MultiSkins[1] = UNATCOTEX;
				else if (Team == TEAM_NSF)
					MultiSkins[1] = NSFTEX;
		if(bDisabled)
			MultiSkins[1] = DEADTEX;			
}	

function Timer()
{
 //  if (bStuck)
 //     Destroy();
}

simulated function SetDeadTex()
{
	MultiSkins[1] = DEADTEX;		
}

simulated function tick (float deltatime)
{

	local float dist;

	Super.tick(deltatime);


	dist = Abs(VSize(initLoc - Location));

	if (dist > AccurateRange)		// start descent due to "gravity"
		Acceleration = GravMult*Region.Zone.ZoneGravity;

	if (bWaiting)
		if(Owner == None)
			Destroy();
			
		else if(Owner.IsA('Pawn'));
			if(Pawn(Owner).HealthHead == 0 || Pawn(Owner).HealthTorso == 0)
				Destroy();
		
	if (bStuck && !bWaiting)
	{
		bWaiting = True;
		SetCollisionSize(ProxRadius, ProxRadius);
	}
	
	if (bDisabled)
	{
		SmokeTimer ++;
		DieTimer ++;
	}
	
	if (SmokeTimer == SmokeTime)
	{
		SpawnSmoke();
		SmokeTimer = 0;
	}
	
	if (DieTimer == DieTime)
		Destroy();
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

function Detonate()
{
	if (bDisabled && !bDestroyedDamage)
	{
		SpawnSparks();
		if (Level.NetMode != NM_Standalone && !bTriedDetonate)
			LifeSpan = 5;
		bTriedDetonate = True;
		return;
	}

	bExplodes = True;
	ImpactSound = ExplodeSound;

	Explode(Location, vect(0,0,0));
//	if (Role == ROLE_Authority)
//		BlowUpActor.TakeDamage(Damage, Pawn(Owner), BlowUpActor.Location, vect(0,0,0), DamageType);
	DrawEffects(Location);
}


simulated function DrawEffects(vector HitLocation)
{
	local ExplosionLight light;	
	local AnimatedSprite expeffect;
	local ShockRing ring;	
	

		expeffect = Spawn(class'ExplosionMedium',,, HitLocation);
		
		if (bStuck)
		{
			light = Spawn(class'ExplosionLight',,, HitLocation);
   			if (light != None)
      		{
				light.size = 4;
			}
		
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(16384,0,0));
      		if (ring != None)
      		{
      	   		ring.size = blastRadius / 32.0;
      		}
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(0,0,0));
      		if (ring != None)
      		{
        		ring.size = blastRadius / 32.0;
      		}
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(0,16384,0));
      		if (ring != None)
      		{
         		ring.size = blastRadius / 32.0;
      		}
      	}
}

//---END-CLASS---

defaultproperties
{
     ExplodeSound=Sound'DeusExSounds.Generic.SmallExplosion1'
     proxRadius=20.000000
     SpawnPointCheckRadius=400.000000
     mpBlastRadius=200.000000
     GravMult=0.125000
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
     blastRadius=150.000000
     DamageType=exploded
     AccurateRange=0
     maxRange=1000
     bIgnoresNanoDefense=True
     ItemName="proximity disc"
     ItemArticle="a"
     speed=1750.000000
     MaxSpeed=3000.000000
     Damage=600.000000
     ImpactSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
     LifeSpan=0.000000
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
