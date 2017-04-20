//=============================================================================
// ExplosiveDisc. 	(c) 2003 JimBowen
//=============================================================================
class ExplosiveDisc extends DeusExProjectile;

var(Bowen) Sound ExplodeSound;
var(Bowen) int Health, mpHealth, mpDamage;
var(Bowen) texture UNATCOTEX, NSFTEX, DEADTEX;
var(Bowen) int MaxAreaDiscs, MaxTotalDiscs, mpMaxAreaDiscs, mpMaxTotalDiscs;
var(Bowen) float mpBlastRadius, GravMult;
var actor BlowUpActor;
var bool bWaiting, bDisabled, bDestroyedDamage, bTriedDetonate, bDead;
var int SmokeTimer, DieTimer;
var(Bowen) int SmokeTime, DieTime;
var ParticleGenerator SparkGen;
var bool bDetonated;
var int Team;
var float AliveTime, Timerlimit;

const TEAM_UNATCO 	= 0;
const TEAM_NSF		= 1;


replication
{
	reliable if (Role == ROLE_Authority)
		BlowUpActor, bWaiting, SpawnSparks, SpawnSmoke, SetDeadTex, bDead;
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
		Team = DeusExPlayer(Owner).PlayerReplicationInfo.Team;
	}
	Super.PreBeginPlay();
}

function bool SameTeam(DeusExPlayer P)
{
	if (P == None || P == Owner)
		Return False;

	if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
		if (P.PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team)
			Return True;

	Return False;
}


auto simulated state flying
{
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if(Other == Owner || bWaiting)
			return;
		DrawType = DT_None;
		bBlockActors = false;
		bBlockPlayers = false;
		BlowUpActor = Other;
		bWaiting = True;
		if(Other.IsA('Pawn'))
			if(Pawn(Other).ReducedDamageType == 'All')
			{
				Detonate();
				return;
			}
		if (Role == ROLE_Authority)
			Other.TakeDamage(2, Pawn(Owner), Other.Location, vect(0,0,0), 'Shot');
		if (Other.IsA('DeusExPlayer') && Role == ROLE_Authority)
			if (!SameTeam(DeusExPlayer(Other)))
				DeusExPlayer(Other).ClientMessage("You have a remote detonated disc stuck to you!");
		LifeSpan=0;
	}
	
	simulated function HitWall(vector HitNormal, actor Wall)
	{

		local ExplosiveDisc Disc;
		local ExplosiveDisc FirstDisc;
		local int i;
		
		if (Wall.IsA('Mover') && bStuck)  	// screw movers
			return;							// they cause servers to crash


			
			foreach radiusactors (class 'ExplosiveDisc', disc, blastradius * 3 )
			{
				if (FirstDisc == None && Disc != None)
					FirstDisc = Disc;
				i++;	
				if (i > MaxAreaDiscs)
					FirstDisc.Destroy();
			}

			foreach allactors (class 'ExplosiveDisc', disc)
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

function PostBeginPlay()
{  
   SetTexture();
	if(DeusExPlayer(Owner) != None)
	   if(DiscLauncher(DeusExPlayer(Owner).InHand) != None)
		if (DiscLauncher(DeusExPlayer(Owner).InHand).DiscTimer > 0)
			TimerLimit = DiscLauncher(DeusExPlayer(Owner).InHand).DiscTimer;
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

simulated function SetTexture()
{
		if (Owner.IsA('DeusExPlayer')) 
		{
			if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)	
			{
				if (DeusExPlayer(Owner).PlayerReplicationInfo.Team == TEAM_UNATCO)
				{
					MultiSkins[1] = UNATCOTEX;
					Team = TEAM_UNATCO;
				}
				else if (DeusExPlayer(Owner).PlayerReplicationInfo.Team == TEAM_NSF)
				{
					MultiSkins[1] = NSFTEX;	
					Team = TEAM_NSF;
				}
			}
		}
}	


function Timer()
{
}

simulated function SetDeadTex()
{
	MultiSkins[1] = DEADTEX;		
}

simulated function tick (float deltatime)
{
	local float dist;

	Super.tick(deltatime);

	AliveTime += DeltaTime;

	if (AliveTime > TimerLimit && TimerLimit != 0 && !bDetonated)
	{
		AliveTime = 0;
		if (!bStuck)
			BlastRadius *= 0.75;
		Detonate();
	}
	
	if (bDead && Level.NetMode == NM_Client)
		Destroy();

	dist = Abs(VSize(initLoc - Location));

	if (dist > AccurateRange)		// start descent due to "gravity"
		Acceleration = GravMult*Region.Zone.ZoneGravity;

	If(DeusExPlayer(Owner) == None)
		Return;

	if (bWaiting)
		if(Owner == None)
			Destroy();
			
		else if(Owner.IsA('Pawn'));
			if(Pawn(Owner).HealthHead == 0 || Pawn(Owner).HealthTorso == 0)
				Destroy();
		
	if (bStuck)
		bWaiting = True;
	
	if (bDisabled)
	{
		SmokeTimer ++;
		DieTimer ++;
	}
	
	if (SmokeTimer == SmokeTime)// && BlowUpActor == None)
	{
		SpawnSmoke();
		SmokeTimer = 0;
	}
	
	if (DieTimer == DieTime)
		Destroy();
		
	if (BlowUpActor != None)
		SetLocation(BlowUpActor.Location);

	if (DeusExPlayer(Owner).PlayerReplicationInfo.Team != Team && Level.NetMode != NM_StandAlone && AliveTime > 2)
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
	
	bDetonated = True;
	bExplodes = True;
	ImpactSound = ExplodeSound;
	if (BlowUpActor == None)
	{
		Explode(Location, vect(0,0,0));
		DrawEffects(Location);
	}
	else
	{
		Explode(BlowUpActor.Location, vect(0,0,0));
		if (Role == RoLE_Authority)
			BlowUpActor.TakeDamage(Damage, Pawn(Owner), BlowUpActor.Location, vect(0,0,0), DamageType);
		DrawEffects(BlowUpActor.Location);
	}
	
}

function Destroyed()
{
	bDead=True;
	Super.Destroyed();
}

simulated function DrawEffects(vector HitLocation)
{
	local ExplosionLight light;	
	local AnimatedSprite expeffect;
	local ShockRing ring;	
	

		expeffect = Spawn(class'ExplosionMedium',,, HitLocation);
		
		if (bStuck && BlowUpActor == None)
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
     mpBlastRadius=200.000000
     GravMult=0.125000
     smokeTime=30
     DieTime=10000
     bStickToWall=True
     blastRadius=150.000000
     DamageType=exploded
     AccurateRange=0
     maxRange=1000
     bIgnoresNanoDefense=True
     ItemName="Remote detonated disc"
     ItemArticle="a"
     TimerLimit=0
     speed=1750.000000
     MaxSpeed=3000.000000
     Damage=1000.000000
     ImpactSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
     LifeSpan=0.000000
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
