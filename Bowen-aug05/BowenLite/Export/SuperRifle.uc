//================================================================================
// SuperRifle.
//================================================================================
class SuperRifle extends BowenWeapon;

var(bowen) float blastRadius;
var(bowen) float FindAngle;
var(bowen) float TickInterval;
var(bowen) string BowenPickupMessage;
var(bowen) string EngagedName;
var(bowen) string DisengagedName;
var Pawn TrackTarget;
var(bowen) int KillsThreshold;
var bool bAutoTrack;
var float beeptimer;

replication
{
	un?reliable if ( Role == 4 )
		bAutoTrack;
}

simulated function Tick (float DeltaTime)
{
	local Pawn P;
	local float fangle;
	local Vector TargetLocation;
	local Vector dvect;
	local Vector vvect;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local Rotator RequiredRotation;
	local int PitchDiff;
	local int YawDiff;

	if ( bAutoTrack && bZoomed )
	{
		if ( ItemName != EngagedName )
		{
			ItemName=EngagedName;
		}
	}
	else
	{
		if ( ItemName != DisengagedName )
		{
			ItemName=DisengagedName;
		}
	}
	if ( (Pawn(Owner) == None) || bTossedOut )
	{
		ItemName=Default.ItemName;
		return;
	}
	if ( (beeptimer > 0.10) && (Role == 4) )
	{
		PlayLockSound();
		beeptimer=0.00;
	}
	Super.Tick(DeltaTime);
	if ( Level.NetMode != 0 )
	{
		if ( (DeusExPlayer(Owner).PlayerReplicationInfo.Score > KillsThreshold) && bAutoTrack )
		{
			bAutoTrack=False;
		}
	}
	if (  !bZoomed )
	{
		TrackTarget=Pawn(Target);
		return;
	}
	TickInterval -= DeltaTime;
	if ( (TickInterval <= 0) && bAutoTrack )
	{
		TickInterval=Default.TickInterval;
		Target=AcquireTarget();
		if ( Pawn(Target) != None )
		{
			if ( Target.IsA('DeusExPlayer') )
			{
				if ( TeamDMGame(DeusExPlayer(Target).DXGame) != None )
				{
					if ( DeusExPlayer(Target).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team )
					{
						return;
					}
				}
			}
			TargetLocation=Target.Location;
			TargetLocation.Z += Target.CollisionHeight / 2;
			Pawn(Owner).ViewRotation=rotator(Normal(TargetLocation - ComputeProjectileStart(X,Y,Z)));
			beeptimer += TickInterval;
		}
	}
}

simulated function CycleAmmo ()
{
	if ( AmmoType.AmmoAmount == 0 )
	{
		return;
	}
	if ( Level.NetMode != 0 )
	{
		if ( DeusExPlayer(Owner).PlayerReplicationInfo.Score > KillsThreshold )
		{
			DeusExPlayer(Owner).ClientMessage("You cannot use auto-tracking with more than" @ string(KillsThreshold) @ "kills.");
			return;
		}
	}
	bAutoTrack= !bAutoTrack;
	if ( bAutoTrack )
	{
		DeusExPlayer(Owner).ClientMessage("Auto-Tracking engaged.");
	}
	else
	{
		DeusExPlayer(Owner).ClientMessage("Auto-Tracking disengaged.");
	}
}

simulated function PreBeginPlay ()
{
	Super.PreBeginPlay();
	if ( Level.NetMode != 0 )
	{
		HitDamage=mpHitDamage;
		BaseAccuracy=mpBaseAccuracy;
		reloadTime=mpReloadTime;
		AccurateRange=mpAccurateRange;
		maxRange=mpMaxRange;
		ReloadCount=mpReloadCount;
		bHasMuzzleFlash=True;
		ReloadCount=1;
		reloadTime=ShotTime;
	}
}

function Fire (float Accuracy)
{
	local Vector TargetLocation;
	local Vector X;
	local Vector Y;
	local Vector Z;

	if ( (Target != None) && bAutoTrack )
	{
		TargetLocation=Target.Location;
		TargetLocation.Z += Target.CollisionHeight / 2;
		Pawn(Owner).ViewRotation=rotator(Normal(TargetLocation - ComputeProjectileStart(X,Y,Z)));
	}
	Super.Fire(Accuracy);
}

simulated function ProcessTraceHit (Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Vector Loc;
	local ExplosionSmall S;
	local ShockRing ring;
	local ShieldGenerator SG;

	if ( Role != 4 )
	{
		if ( VSize(Owner.Location - HitLocation) <= maxRange )
		{
			Spawn(Class'ExplosionSmall',,,HitLocation);
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
	else
	{
		DoDamage(HitLocation,HitNormal);
	}
	if ( Pawn(Other) != None )
	{
		foreach AllActors(Class'ShieldGenerator',SG)
		{
			if ( S != None )
			{
				if ( S.Owner == Other )
				{
					S.TakeDamage(3 * HitDamage,Pawn(Owner),Other.Location,vect(0.00,0.00,0.00),'shot');
				}
			}
			continue;
		}
	}
	Super.ProcessTraceHit(Other,HitLocation,HitNormal,X,Y,Z);
}

function GiveTo (Pawn Other)
{
	if ( Other.IsA('DeusExPlayer') )
	{
		DeusExPlayer(Other).ClientMessage(BowenPickupMessage);
	}
	Super.GiveTo(Other);
}

simulated function DoDamage (Vector HitLocation, Vector HitNormal)
{
	if ( Role == 4 )
	{
		if ( bZoomed )
		{
			HurtRadius(HitDamage * 6,blastRadius,'exploded',0.00,HitLocation,True);
		}
		else
		{
			HurtRadius(HitDamage,blastRadius / 2,'exploded',0.00,HitLocation,True);
		}
	}
}

function PostBeginPlay ()
{
	Super.PostBeginPlay();
	bWeaponStay=False;
	PickupAmmoCount=5;
}

defaultproperties
{
    blastRadius=100.00
    FindAngle=0.05
    TickInterval=0.01
    BowenPickupMessage="|p2To toggle auto-tracking, press the ammo change key (|p1#|p2)."
    EngagedName="Super rifle using auto-tracking"
    DisengagedName="Super rifle without using  auto-tracking"
    KillsThreshold=2
    bAutoTrack=True
    LowAmmoWaterMark=6
    GoverningSkill=Class'DeusEx.SkillWeaponRifle'
    NoiseLevel=2.00
    EnviroEffective=1
    ShotTime=1.50
    reloadTime=2.00
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
    recoilStrength=0.40
    bUseWhileCrouched=False
    mpReloadTime=2.00
    mpHitDamage=30
    mpAccurateRange=28800
    mpMaxRange=28800
    mpReloadCount=6
    bCanHaveModBaseAccuracy=True
    bCanHaveModReloadCount=True
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    bCanHaveModRecoilStrength=True
    AmmoName=Class'AmmoSuperRifle'
    ReloadCount=6
    PickupAmmoCount=1
    bInstantHit=True
    FireOffset=(X=-20.00, Y=2.00, Z=30.00)
    shakemag=50.00
    FireSound=Sound'DeusExSounds.Weapons.RifleFire'
    AltFireSound=Sound'DeusExSounds.Weapons.RifleReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.RifleReload'
    SelectSound=Sound'DeusExSounds.Weapons.RifleSelect'
    InventoryGroup=102
    ItemName="Super Rifle"
    RespawnTime=45.00
    PlayerViewOffset=(X=20.00, Y=-2.00, Z=-30.00)
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
    CollisionRadius=26.00
    CollisionHeight=2.00
    Mass=30.00
}