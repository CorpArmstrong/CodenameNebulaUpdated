//=============================================================================
// MissileLauncher. 	(c) 2003 JimBowen
//=============================================================================
class MissileLauncher expands BowenWeapon;

var localized String shortName;

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
      bHasScope = True;
	}
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X, Y, Z;
	local DeusExProjectile proj;
	
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = ComputeProjectileStart(X, Y, Z);

        currentAccuracy = MinProjSpreadAcc;
        
		AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);

		proj = DeusExProjectile(Owner.Spawn(ProjClass, Owner,, Start, AdjustedAim));
		
	return proj;
}

function PostBeginPlay()
{
   Super.PostBeginPlay();
   bWeaponStay=False;
   PickupAmmoCount=2;
   if (Level.NetMode == NM_StandAlone)
	AmmoNames[2] = class'AmmoMissile';
}

//---END-CLASS---

defaultproperties
{
     ShortName="Missile Launcher"
     LowAmmoWaterMark=4
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=2.000000
     reloadTime=2.000000
     HitDamage=300
     maxRange=24000
     AccurateRange=14400
     bCanHaveScope=True
     LockTime=2.000000
     LockedSound=Sound'DeusExSounds.Weapons.GEPGunLock'
     TrackingSound=Sound'DeusExSounds.Weapons.GEPGunTrack'
     AmmoNames(0)=Class'AmmoNIKITARocket'
     AmmoNames(1)=Class'AmmoGuidedMissile'
     ProjectileNames(0)=Class'BowenNIKITARocket'
     ProjectileNames(1)=Class'GuidedMissile'
     ProjectileNames(2)=class'HomingMissile'
     bHasMuzzleFlash=False
     recoilStrength=1.000000
     bUseWhileCrouched=False
     mpHitDamage=40
     mpAccurateRange=14400
     mpMaxRange=14400
     mpReloadCount=1
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     AmmoName=Class'BowenCC.AmmoNIKITARocket'
     ReloadCount=1
     PickupAmmoCount=4
     FireOffset=(X=-46.000000,Y=22.000000,Z=10.000000)
     ProjectileClass=Class'BowenCC.BowenNIKITARocket'
     shakemag=500.000000
     FireSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     CockingSound=Sound'DeusExSounds.Weapons.GEPGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.GEPGunSelect'
     InventoryGroup=186
     ItemName="Bowen guided missile Launcher"
     PlayerViewOffset=(X=46.000000,Y=-22.000000,Z=-10.000000)
     PlayerViewMesh=LodMesh'DeusExItems.GEPGun'
     PickupViewMesh=LodMesh'DeusExItems.GEPGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.GEPGun3rd'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconGEPGun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconGEPGun'
     largeIconWidth=203
     largeIconHeight=77
     invSlotsX=4
     invSlotsY=2
     Description="The BowenCo homing missile launcher fires two different kinds of missile, The NIKITA, and the LGM For more info on each type see the respective ammo description."
     beltDescription="MISSILE"
     Mesh=LodMesh'DeusExItems.GEPGunPickup'
     CollisionRadius=27.000000
     CollisionHeight=6.600000
     Mass=50.000000
}
