//================================================================================
// TeleportGun.
//================================================================================
class TeleportGun extends BowenWeapon;

var(bowen) float BeamDetail;
var(bowen) Sound LockSound;
var(bowen) Sound InvalidSound;
var(bowen) Sound TelSound;
var Actor Target;
var bool bSecondaryMode;

replication
{
	un?reliable if ( Role == 4 )
		Target,bSecondaryMode;
}

simulated function CycleAmmo ()
{
	if ( DeusExPlayer(Owner).bAdmin || (Level.NetMode == 0) )
	{
		bSecondaryMode= !bSecondaryMode;
	}
	else
	{
		if ( Role == 4 )
		{
			DeusExPlayer(Owner).ClientMessage("You do not have permission to do that.");
		}
	}
	if ( bSecondaryMode && (Role == 4) )
	{
		DeusExPlayer(Owner).ClientMessage("Secondary mode activated.");
	}
	else
	{
		if ( Role == 4 )
		{
			DeusExPlayer(Owner).ClientMessage("Primary mode activated.");
		}
	}
}

simulated function ProcessTraceHit (Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Vector Loc;
	local Vector startLocation;
	local SphereEffect S;
	local TeleportInhibitor Inhibitor;


function DrawLineEffect (Vector A, Vector B, float Detail)
{
	local int i;
	local int NumSprites;
	local Vector Line;
	local Vector increment;
	local Vector Loc;
	local float F;
	local float dist;

	Line=A - B;
	dist=VSize(Line);
	F=dist * Detail;
	NumSprites=F;
	increment=Line / NumSprites;
	i=0;
JL0057:
	if ( i < NumSprites )
	{
		Loc=A - increment * i;
		Spawn(Class'BowenSpriteBeam',,,Loc);
		i++;
		goto JL0057;
	}
}

state NormalFire extends NormalFire
{
Begin:
	if ( (ClipCount >= ReloadCount) && (ReloadCount != 0) )
	{
		if (  !bAutomatic )
		{
			bFiring=False;
			FinishAnim();
		}
		if ( Owner != None )
		{
			if ( Owner.IsA('DeusExPlayer') )
			{
				bFiring=False;
				if ( DeusExPlayer(Owner).bAutoReload )
				{
					if ( (AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]) )
					{
						CycleAmmo();
					}
					ReloadAmmo();
				}
				else
				{
					if ( bHasMuzzleFlash )
					{
						EraseMuzzleFlashTexture();
					}
					GotoState('Idle');
				}
			}
			else
			{
				if ( Owner.IsA('ScriptedPawn') )
				{
					bFiring=False;
					ReloadAmmo();
				}
			}
		}
		else
		{
			if ( bHasMuzzleFlash )
			{
				EraseMuzzleFlashTexture();
			}
			GotoState('Idle');
		}
	}
	if ( bAutomatic && ((Level.NetMode == 1) || (Level.NetMode == 2) && Owner.IsA('DeusExPlayer') &&  !DeusExPlayer(Owner).PlayerIsListenClient()) )
	{
		GotoState('Idle');
	}
	Sleep(GetShotTime());
	if ( bAutomatic )
	{
		GenerateBullet();
		goto ('Begin');
	}
	bFiring=False;
	FinishAnim();
	ReadyToFire();
Done:
	bFiring=False;
	Finish();
}

defaultproperties
{
    BeamDetail=0.02
    LockSound=Sound'DeusExSounds.Generic.Beep1'
    InvalidSound=Sound'DeusExSounds.Generic.Buzz1'
    TelSound=Sound'DeusExSounds.Generic.Beep5'
    LowAmmoWaterMark=0
    GoverningSkill=Class'DeusEx.SkillWeaponRifle'
    NoiseLevel=2.00
    ShotTime=0.30
    reloadTime=0.50
    HitDamage=2000
    maxRange=24000
    AccurateRange=14400
    BaseAccuracy=0.00
    bHasScope=True
    AmmoNames=Class'AmmoTeleport'
    bHasMuzzleFlash=False
    mpHitDamage=100
    mpBaseAccuracy=0.60
    mpAccurateRange=14400
    mpMaxRange=14400
    AmmoName=Class'AmmoTeleport'
    ReloadCount=0
    PickupAmmoCount=10
    bInstantHit=True
    bWeaponStay=True
    FireOffset=(X=28.00, Y=12.00, Z=4.00)
    ProjectileClass=Class'DeusEx.RocketLAW'
    shakemag=0.00
    SelectSound=Sound'DeusExSounds.Weapons.LAWSelect'
    InventoryGroup=56
    ItemName="Bowen Teleporter Gun"
    PlayerViewOffset=(X=18.00, Y=-18.00, Z=-7.00)
    PlayerViewMesh=LodMesh'DeusExItems.LAW'
    PickupViewMesh=LodMesh'DeusExItems.LAWPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.LAW3rd'
    LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
    Icon=Texture'DeusExUI.Icons.BeltIconLAW'
    largeIcon=Texture'DeusExUI.Icons.LargeIconLAW'
    largeIconWidth=166
    largeIconHeight=47
    invSlotsX=4
    Description="The BowenCo teleporter gun allows the user to instantly teleport to anywhere within his line of sight"
    beltDescription="TELE"
    Mesh=LodMesh'DeusExItems.LAWPickup'
    CollisionRadius=25.00
    CollisionHeight=6.80
    Mass=50.00
}