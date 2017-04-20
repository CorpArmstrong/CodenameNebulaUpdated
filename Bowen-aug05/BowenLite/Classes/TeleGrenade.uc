//=============================================================================
// Teleport Grenade. 	(c) 2003 JimBowen
//=============================================================================
class TeleGrenade expands ThrownProjectile;

var(Bowen) float	mpBlastRadius;
var(Bowen) float	mpProxRadius;
var(Bowen) float	mpDamage;
var(Bowen) float	mpFuselength;
var(Bowen) float	MaxZ;
var(Bowen) float	SpawnPointCheckRadius;
var bool		bOverrideExplode;
var bool 		bDoneMsg;
var bool		bDebug;
var Pawn AreaPawns[32];  //should not be more than 32 pawns in one blastradius.. 

state exploding
{
	function Explode(vector HitLocation, vector HitNormal)
	{
		local Pawn p;
		local int i;
		local vector dir, loc;
	
			if (bOverrideExplode)
			{
				if (bDebug) log ("Overrode Explode() call.", 'Debug');
				return;
			}

			if (bDebug) log ("Explode()", 'Debug');
			bOverrideExplode = True;
			foreach VisibleActors(class'Pawn', p, BlastRadius)
			{
				if (Level.NetMode == NM_StandAlone || (!p.isA('MedicalBot') && !p.IsA('RepairBot')) || (P.IsA('DeusExPlayer') && !SameTeam(DeusExPlayer(P))))
				{
					if (!InList(P))
						AreaPawns[i] = p;
					else
						return;
					i++;
				}
				if (i >= 32)
					break; //skip the rest, if they exist, we'll need another grenade for those :-P
			}
			
			for (i=0;i<ArrayCount(AreaPawns);i++)
				if (bDebug) log (AreaPawns[i], 'Debug_AreaPawns');
			GroupTeleport(AreaPawns);
		Super.Explode(HitLocation, HitNormal);
	}
}

simulated function bool InList(Pawn P)
{
	local int i;

		for (i=0;i<ArrayCount(AreaPawns);i++)
			if (AreaPawns[i] == P)
				return True;
	return False;
}

simulated function timer()
{
		local PlayerStart Spawn;
		local SpawnExtension SpawnExt;
		
			if (Level.NetMode == NM_Standalone)
			{
				Super.Timer();
				return;
			}
			
			foreach RadiusActors (class 'PlayerStart', Spawn, SpawnPointCheckRadius)
			{
				if (FastTrace(Spawn.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
				{
					if (Owner.IsA('DeusExPlayer'))
					{
						DeusExPlayer(Owner).ClientMessage("Teleport grenades are not allowed in spawn rooms");
						log("TeleGrenade placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
					}
					else log ("TeleGreande was found in spawn room with no player owner");
					SpawnSmoke();
					bDoneMsg = True;
					Destroy();
					return;
				}
			}
			
			foreach RadiusActors (class 'SpawnExtension', SpawnExt, SpawnPointCheckRadius)



			{
				if (FastTrace(Spawn.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
				{
					if (Owner.IsA('DeusExPlayer'))
					{
						DeusExPlayer(Owner).ClientMessage("Teleport grenades are not allowed in spawn rooms");
						log("TeleGrenade placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
					}
					else log ("TeleGrenade was found in spawn room with no player owner");
					SpawnSmoke();
					bDoneMsg = True;
					Destroy();
					return;
				}
			}
		if(!bDoneMsg)
			Super.Timer();
					
}
function GroupTeleport(Pawn PawnGroup[32])
{
	local actor a;
	local int numactors, i, n;
	local actor LevelActors[128];
	
		foreach allactors (class'Actor', a)
			if ((A.IsA('Pawn') && (Level.NetMode == NM_Standalone || !A.IsA('RepairBot'))) ||
			A.IsA('AutoTurret') ||
			A.IsA('PathNode') ||
			A.IsA('AmmoCrate')) // only use these actors for a starting point
			{
				numactors++;
				if (NumActors < 128) // dont go outside our array
					LevelActors[NumActors] = A; // add the actor to the list
				else
					break;
			}	
		
		for (i=0;i<ArrayCount(PawnGroup);i++)
		{
			n = Rand(NumActors); // pick a random actor from the list we just made
			TeleportPawn(PawnGroup[i], LevelActors[n]); // teleport the next group member using that actor
		}
}

function TeleportPawn(Pawn Subject, Actor DestinationActor)
{
	local vector OrigLocation, Destination, DestNormal, EndTrace, Correction, RVect;
	local int i;	
	local actor hit;

	if (Subject == None || Level.Netmode == NM_Client)
		return;

	OrigLocation = Subject.Location;

	if (bDebug) log (Subject @ ">" @ DestinationActor, 'Debug_BeginTeleport');

	for (i=0;i<5;i++)
	{
		RVect = VRand();
		RVect.Z = 0;
		EndTrace = DestinationActor.Location + RVect*65536; // some vector very far away in a random direction ferom the DestinationActor
		hit = DestinationActor.Trace(Destination, DestNormal, EndTrace, DestinationActor.Location, True); // find where this line hits a wall
	/*	if (Destination.Z - OrigLocation.Z > MaxZ)
		{
			Correction = Destination;
			Correction.Z = OrigLocation.Z + MaxZ;
			hit = DestinationActor.Trace(Destination, DestNormal, EndTrace, OrigLocation, True);*/ // okay stuff 3D
		Destination += DestNormal*Subject.CollisionHeight; // we dont want them half in a wall/floor
		if (bDebug) log (OrigLocation @ ">" @ Destination, 'Debug_Teleporting');
		if(Subject.SetLocation(Destination)) // make sure they got there
		{
			DrawLineEffect(OrigLocation, Destination, 0.020000); // yay pretty effects
			if (bDebug) log ("Done actor -" @ Subject, 'Debug_DoneTeleport');
			return;
		}
	}
	Pawn(Owner).ClientMessage("|P2Failed to teleport a pawn.");		
}


function DrawLineEffect(vector A, vector B, float Detail)
{
local int i, NumSprites;
local vector line, increment, loc;	
local float f, Dist;
local BowenSpriteBeam BeamBit;
	
	line = A - B;
	
	Dist = VSize(line);
	f = Dist * Detail;
	NumSprites = int(f);
	
	increment = line / NumSprites;
	
	for( i=0; i<NumSprites; i++ )
	{	
		loc = A - (increment * i);
		BeamBit = Spawn(class'BowenLite.BowenSpriteBeam',,, loc);
	}
}

function bool SameTeam(DeusExPlayer P)
{
	if (P == None)
		Return False;
	if (P == Owner)
		Return False;

	if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
		if (P.PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team)
			Return True;
	
	Return False;
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local SphereEffect Sph;
		
		Sph = Spawn(class'SphereEffect',,,HitLocation);
		Sph.Skin=Texture'Effects.Laser.LaserBeam2';
		Sph.Size = BlastRadius / 20;
		Sph.LifeSpan = 1.5;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
	{
		blastRadius=mpBlastRadius;
		proxRadius=mpProxRadius;
		Damage=mpDamage;
		fuseLength=mpFuseLength;
		bIgnoresNanoDefense=True;
	}
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

//---END-CLASS---

defaultproperties
{
     mpBlastRadius=512.000000
     mpProxRadius=128.000000
     mpFuselength=1.000000
     fuseLength=1.500000
     proxRadius=128.000000
     AISoundLevel=0.000000
     bBlood=False
     bDebug=False
     bDebris=False
     blastRadius=1024.000000
     DamageType=None
     spawnWeaponClass=Class'WTG'
     ItemName="Teleport Grenade"
     speed=1000.000000
     MaxSpeed=1000.000000
     MomentumTransfer=50000
     ImpactSound=Sound'DeusExSounds.Augmentation.CloakDown'
     LifeSpan=0.000000
     Mesh=LodMesh'DeusExItems.GasGrenadePickup'
     CollisionRadius=4.300000
     CollisionHeight=1.400000
     Mass=5.000000
     Buoyancy=2.000000
     MaxZ=800
     SpawnPointCheckRadius=300.000000
}
