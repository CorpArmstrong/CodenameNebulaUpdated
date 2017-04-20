//=============================================
// HunterDrone
//=============================================

class HunterDrone extends Bird;

var (Bowen) float BlastRadius, SightRadius;
var (Bowen) float Damage, MomentumTransfer;
var (Bowen) sound ImpactSound;
Var (Bowen) name DamageType;
Var (Bowen) bool bAggressiveExploded, bExplodes, bDebug;
Var (Bowen) String ItemName, ItemArticle;
Var Actor Target, damagee;
Var int GradualHurtCounter, GradualHurtSteps;
Var bool bHitTarget, ExplodeNow, bDoneDebugTick;
Var vector RealLocation;
Var ParticleGenerator SmokeGen;
var (Bowen) Texture ParTex;

replication
{
	reliable if (Role == ROLE_Authority)
		Target;
	unreliable if (Role == ROLE_Authority)
		RealLocation;
}

function bool DronePickTarget()
{
	local Pawn MostKills, P;
	local int NumKills;
	local DeusExPlayer Player;
	local PlayerReplicationInfo PRI;

	foreach visibleActors (class'Pawn', p, SightRadius)
	{	
		if (P == None || P == Owner || P.IsA('Animal') || P.SmellClass == class'LocatorSmell')
			continue;
		if (Level.NetMode != NM_StandAlone && P.IsA('ScriptedPawn'))
			continue;

		Player = DeusExPlayer(P);
		if (Player != None)
		{
			PRI = Player.PlayerReplicationInfo;
			if (Player.Level.Game.isA('TeamDMGame') && PRI.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team)
				continue;

			if(PRI.Score > NumKills)
			{
				MostKills = P;
				NumKills = PRI.Score;
			}
			else if (MostKills == None)
				MostKills = P;
		}
		if (MostKills == None)
			MostKills = P;
	}
	if (MostKills == None)
		return false;
	Target = MostKills;

	return true;
}

simulated function PreBeginPlay()
{
	local deusexplayer p;
	SpawnRocketEffects();
	Instigator = Pawn(Owner);
	if (Level.NetMode == NM_StandAlone)
		foreach allactors(class'DeusExPlayer', p)
			SetOwner(P);
			
	if (DeusExPlayer(Owner) != None && !DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay.IsA('LocatorWindow'))
	{
		Pawn(Owner).ClientMessage("Spawning new locatorwindow");
		DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay = ActorDisplayWindow(DeusExRootWindow(DeusExPlayer(Owner).rootWindow).NewChild(Class'LocatorWindow'));
		DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
	}
}

simulated State Wandering
{
	Simulated function tick (float deltatime)
	{
		if (Physics == PHYS_Falling)
		{
			SetPhysics(PHYS_Flying);
			if(bDebug) Pawn(Owner).ClientMessage("Resetting physics.");
		}
	}
	
	Begin:
		if(bDebug) Pawn(Owner).ClientMessage("Falling. Going to flying.");
		GoToState('Flying');
}

singular function Touch (Actor Other)
{
	local LocatorBeacon loc;
	if (Other == Target && !bHitTarget)
	{
		if (Role == ROLE_Authority)
			Pawn(Owner).ClientMessage("Drone attached to" @ GetDisplayName(Other));
		if (Role == ROLE_Authority)
		{
			loc = Spawn(class'LocatorBeacon',Owner,,Other.Location);
			loc.setBase(Other);
			Other.SmellClass = class'LocatorSmell';
		}
		SmokeGen.Destroy();
		Destroy();
	}
}

function String GetDisplayName(Actor actor)
{
	if (DeusExPlayer(actor) != None)
		return DeusExPlayer(actor).PlayerReplicationInfo.PlayerName;
	
	if (ScriptedPawn(actor) != None)
		return ScriptedPawn(actor).UnfamiliarName;

	return "a target";
}

simulated function tick (float deltatime)
{
	if (!bDoneDebugTick)
	{
		if(bDebug) Pawn(Owner).ClientMessage("Drone ticked.");
		bDoneDebugTick = True;
	}

	if (Owner == None || ExplodeNow)
	{
		if (Role == ROLE_Authority)
			Pawn(Owner).ClientMessage("Drone found target. (1)");
		SetTimer(0.1, False); //HACK
		bHitTarget=True;
	}	

	if (Role == ROLE_Authority)
		RealLocation = Location;
	if (Level.NetMode == NM_Client)
		SetLocation(RealLocation);

	Super.tick(DeltaTime);
}

simulated function SpawnRocketEffects()
{
	smokeGen = Spawn(class'ParticleGenerator', Self);
	if (smokeGen != None)
	{
      smokeGen.RemoteRole = ROLE_None;
		smokeGen.particleTexture = ParTex;
		smokeGen.particleDrawScale = 0.3;
		smokeGen.checkTime = 0.02;
		smokeGen.riseRate = 8.0;
		smokeGen.ejectSpeed = 0.0;
		smokeGen.particleLifeSpan = 0.3;
		smokeGen.bRandomEject = True;
		smokeGen.SetBase(Self);
		smokeGen.LifeSpan = LifeSpan;
	}
}

auto simulated state Flying
{
	simulated function tick (float deltatime)
	{
		if (Owner == None || ExplodeNow)
		{
			Pawn(Owner).ClientMessage("Drone found target. (2)");
			SetTimer(0.1, False); //HACK
			bHitTarget=True;
		}	
	
		if (Role == ROLE_Authority)
			RealLocation = Location;

		Super.tick(DeltaTime);
	}

	function CheckStuck()
	{
		//do nothing
	}
	
	function PickInitialDestination()
	{
		destloc = Location + vector(Rotation);
	}
	
	function PickDestination()
	{
		local vector CollisionLocation;
		
		if (!DronePickTarget())
		{
			Target = None;
			if (VSize(Velocity) > 0)
			{
				CollisionLocation = Extrapolate();
				if (VSize(Location - CollisionLocation) < 300)
				{
					Super.PickDestination();
					return;
				}
				else
					destLoc = CollisionLocation;
			}
			else
				Super.PickDestination();
			return;
		}
		if (Target != None)
		{
			destLoc = Target.Location+vect(0,0,1)*Target.CollisionHeight/2.1;
		}
	}
	
	function vector Extrapolate()
	{
		local vector HitLocation, HitNormal, TraceStart, TraceEnd;
		
		TraceStart = Location;
		TraceEnd = Location + 8192*normal(Velocity);
		
		Trace(HitLocation, HitNormal, TraceEnd, TraceStart, True);
		
		return HitLocation;
	}

	function EndState()
	{
		if(bDebug) Pawn(Owner).ClientMessage("Ended flying...");
		GoToState('Flying');
	}

	
	/*simulated function HitWall( vector HitNormal, actor HitWall )
	{
		SetLocation(Location + 10*HitNormal);
	}*/
}

defaultproperties
{
     ParTex=FireTexture'Effects.Smoke.SmokePuff1'
     CarcassType=None
     WalkingSpeed=0.666667
     GroundSpeed=24.000000
     WaterSpeed=8.000000
     AccelRate=800.000000
     JumpZ=0.000000
     BaseEyeHeight=3.000000
     Health=20
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Fear
     HealthHead=20
     HealthTorso=20
     HealthLegLeft=20
     HealthLegRight=20
     HealthArmLeft=20
     HealthArmRight=20
     Alliance=FOOBAR
     DrawType=DT_Mesh
     Mesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
     CollisionRadius=10.000000
     CollisionHeight=3.000000
     Mass=2.000000
     Buoyancy=2.500000
     RotationRate=(Pitch=6000)
     blastRadius=200.000000
     SightRadius=65535.000000
     Damage=200.000000
     MomentumTransfer=5000.000000
     DamageType='
     bExplodes=True
     ItemName="BounceBomb II"
     ItemArticle="a"
     LikesFlying=1.000000
     AirSpeed=2000.000000
     BindName="BounceBomb II"
     FamiliarName="BounceBomb II"
     UnfamiliarName="BounceBomb II"
	 AmbientSound=Sound'DeusExSounds.Special.RocketLoop'
}
