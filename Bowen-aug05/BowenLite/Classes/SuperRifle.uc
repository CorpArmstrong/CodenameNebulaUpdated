//=============================================================================
// SuperRifle. 	(c) 2003 JimBowen
//=============================================================================
class SuperRifle expands BowenWeapon;

var(Bowen) float blastradius, FindAngle;
var(Bowen) float TickInterval;
var(Bowen) string BowenPickupMessage, EngagedName, DisengagedName;
var pawn TrackTarget;
var(Bowen) int KillsThreshold; 
var bool bAutoTrack;
var float beeptimer;

replication
{
	reliable if (Role == ROLE_Authority)
		bAutoTrack;
}

simulated function tick (float deltatime)
{
	local pawn p;
	local float fangle;
	local vector TargetLocation, dvect, vvect, X, Y, Z;
	local rotator RequiredRotation;
	local int PitchDiff, YawDiff;

		if(Level.NetMode != NM_StandAlone)
		{
			Super.Tick(DeltaTime);
			Return;
		}
		
		if(bAutoTrack && bZoomed)
		{
			if(ItemName != EngagedName)
				ItemName = EngagedName;
		}
		else
		{
			if(ItemName != DisengagedName)
				ItemName = DisengagedName;
		}

		if (Pawn(Owner) == None || bTossedOut)
		{
			ItemName = Default.ItemName;
			return;
		}

		if ((BeepTimer > 0.1) && (Role == ROLE_Authority))
		{
			PlayLockSound();
			BeepTimer = 0;
		}
		
		Super.tick (deltatime);

		if (Level.NetMode != NM_Standalone)
			if (DeusExPlayer(Owner).PlayerReplicationInfo.score > KillsThreshold && bAutoTrack)
				bAutoTrack = False;
		
		if (!bZoomed)
		{
			TrackTarget = Pawn(Target);
			return;
		}
			
		TickInterval -= DeltaTime;
		
		if (TickInterval <= 0 && bAutoTrack)
		{
			TickInterval = Default.TickInterval;

			Target = AcquireTarget();			

			if (Pawn(Target) != None)
			{
				if (Target.IsA('DeusExPlayer'))
					if  (TeamDMGame(DeusExPlayer(Target).DXGame) != None)

						if (DeusExPlayer(Target).PlayerReplicationInfo.team == DeusExPlayer(Owner).PlayerReplicationInfo.team)
							return;
				TargetLocation = Target.Location;
				Targetlocation.Z += Target.Collisionheight / 2;
				pawn(Owner).viewrotation = rotator(normal(TargetLocation - (ComputeProjectileStart(X,Y,Z))));
				BeepTimer += TickInterval;
			}
		}
	
}

simulated function cycleammo()
{	

	if (AmmoType.AmmoAmount == 0 || Level.NetMode != NM_StandAlone)
		return;

	if (Level.NetMode != NM_Standalone)
		if (DeusExPlayer(Owner).PlayerReplicationInfo.score > KillsThreshold)
		{
			DeusExPlayer(Owner).ClientMessage("You cannot use auto-tracking with more than" @ KillsThreshold @ "kills.");
			return;
		}
	bAutoTrack = !bAutoTrack;
	if(bAutoTrack)
		DeusExPlayer(Owner).ClientMessage("Auto-Tracking engaged.");
	else
		DeusExPlayer(Owner).ClientMessage("Auto-Tracking disengaged.");
	
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		HitDamage = mpHitDamage;
		BaseAccuracy = mpBaseAccuracy;
		ReloadTime = mpReloadTime;
		AccurateRange = mpAccurateRange;
		MaxRange = mpMaxRange;
		ReloadCount = mpReloadCount;
      bHasMuzzleFlash = True;
      ReloadCount = 1;
      ReloadTime = ShotTime;
	}
}
/*
function fire (float accuracy)
{
	local vector TargetLocation, X, Y, Z;
	
		if (target != None && bAutoTrack)
		{
			TargetLocation = Target.Location;
			Targetlocation.Z += Target.Collisionheight / 2;
			pawn(Owner).viewrotation = rotator(normal(TargetLocation - (ComputeProjectileStart(X,Y,Z))));
		}
	Super.Fire(Accuracy);
}
*/
simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector loc;
	local ExplosionSmall S;
	local shockring ring;
	local ShieldGenerator SG;
	
	if (Role != ROLE_Authority || Level.NetMode == NM_StandAlone)
	{	
		if (VSize(Owner.Location - HitLocation) <= MaxRange)
		{	
			Spawn (class'DeusEx.ExplosionSmall',,,HitLocation);
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
	else
		DoDamage(HitLocation, HitNormal);

	if(rocketPod(Other) != None && bZoomed)
		Other.TakeDamage(5*HitDamage, Pawn(Owner), Other.Location, vect(0,0,0), 'Exploded');

	if (Pawn(Other) != None && bZoomed)
		SG=ShieldGenerator(Pawn(Other).FindInventoryType(class'ShieldGenerator'));
			if (SG != None)
				SG.TakeDamage(5*HitDamage, Pawn(Owner), Other.Location, vect(0,0,0), 'Exploded');
		
	Super.ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);		
}
/*
function GiveTo( pawn Other )
{	
	if (Other.IsA('DeusExPlayer'))
		DeusExPlayer(Other).ClientMessage(BowenPickupMessage);
	Super.GiveTo(Other);
}*/

simulated function DoDamage(vector HitLocation, vector HitNormal)
{
	if(Role == ROLE_Authority)
		if(bZoomed)
			HurtRadius (HitDamage*6, BlastRadius, 'Exploded', 0, HitLocation, True);
		else
			HurtRadius (HitDamage, BlastRadius / 2, 'Exploded', 0, HitLocation, True);
}

function PostBeginPlay()
{
   Super.PostBeginPlay();
   bWeaponStay=False;
   PickupAmmoCount=5;
}

//---END-CLASS---

defaultproperties
{
     blastRadius=100.000000
     FindAngle=0.047270
     TickInterval=0.010000
     BowenPickupMessage="|p2To toggle auto-tracking, press the ammo change key (|p1#|p2)."
     EngagedName="Super rifle using auto-tracking"
     DisengagedName="Super rifle without using  auto-tracking"
     KillsThreshold=2
     bAutoTrack=True
     LowAmmoWaterMark=6
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=1.500000
     reloadTime=2.000000
     HitDamage=25
     maxRange=48000
     AccurateRange=28800
     bCanHaveScope=True
     bHasScope=True
     bCanHaveLaser=True
     bCanHaveSilencer=True
     bCanTrack=True
     LockedSound=Sound'DeusExSounds.Weapons.GEPGunLock'
     bHasMuzzleFlash=False
     recoilStrength=0.400000
     bUseWhileCrouched=False
     mpReloadTime=2.000000
     mpHitDamage=30
     mpAccurateRange=28800
     mpMaxRange=28800
     mpReloadCount=6
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'BowenLite.AmmoSuperRifle'
     ReloadCount=6
     PickupAmmoCount=1
     bInstantHit=True
     FireOffset=(X=-20.000000,Y=2.000000,Z=30.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.RifleFire'
     AltFireSound=Sound'DeusExSounds.Weapons.RifleReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.RifleReload'
     SelectSound=Sound'DeusExSounds.Weapons.RifleSelect'
     InventoryGroup=102
     ItemName="Super Rifle"
     RespawnTime=45.000000
     PlayerViewOffset=(X=20.000000,Y=-2.000000,Z=-30.000000)
     PlayerViewMesh=LodMesh'DeusExItems.SniperRifle'
     PickupViewMesh=LodMesh'DeusExItems.SniperRiflePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.SniperRifle3rd'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconRifle'
     largeIcon=Texture'DeusExUI.Icons.LargeIconRifle'
     largeIconWidth=159
     largeIconHeight=47
     invSlotsX=4
     Description="The BowenCo Super 3006 rifle contains exploding 3006 bullets for greater damage capacity. The Super Rifle also includes an automatic target tracking system for ease of aiming."
     beltDescription="SUPER"
     Mesh=LodMesh'DeusExItems.SniperRiflePickup'
     CollisionRadius=26.000000
     CollisionHeight=2.000000
     Mass=30.000000
}
