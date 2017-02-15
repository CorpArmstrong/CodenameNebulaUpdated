//=============================================================================
// WeaponCoilGun.
//=============================================================================

//Modified -- Y|yukichigai

class WeaponCoilGun extends WeaponSawedOffShotgun;

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
	}
}

function name WeaponDamageType()
	{
		return 'KnockedOut';
	}
//Reload time is down considerably

defaultproperties
{
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     NoiseLevel=0.010000
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_All
     ShotTime=4.000000
     HitDamage=50
     maxRange=48000
     AccurateRange=28800
     BaseAccuracy=0.800000
     bCanHaveScope=True
     bCanHaveLaser=True
	 AmmoNames(0)=Class'DeusEx.AmmoDart'
     AmmoNames(1)=Class'DeusEx.AmmoBattery'
	 //StunDuration=70.000000
     recoilStrength=0.300000
     mpReloadTime=1.500000
     mpHitDamage=12
     mpBaseAccuracy=0.200000
     mpAccurateRange=1200
     mpMaxRange=1200
     mpReloadCount=12
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     AmmoName=Class'DeusEx.AmmoDart'
     PickupAmmoCount=6
	 bInstantHit=True
     FireOffset=(X=-24.000000,Y=10.000000,Z=14.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.ProdFire'
     AltFireSound=Sound'DeusExSounds.Weapons.ProdReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.ProdSelect'
     SelectSound=Sound'DeusExSounds.Weapons.PlasmaRifleReload'
     InventoryGroup=53
     ItemName="Coil Gun"
     PlayerViewOffset=(X=11.00,Y=-4.00,Z=-13.00)
   //PlayerViewMesh=LodMesh'gauss1st'
    //PickupViewMesh=LodMesh'gausspickup'
    //ThirdPersonMesh=LodMesh'gauss3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconShotgun'
     largeIcon=Texture'DeusExUI.Icons.BeltIconShotgun'
     largeIconWidth=47
     largeIconHeight=37
     Description="A Coil Gin utilizes electromagnetic coils to propel a metallic projectile. The principle is the same as you eject a dvd from an optical drive, but the coil gun uses much more powerful capacitors. Due to long recharge time of the capacitors this weapon can't fire very fast, however it is silent, long-distance and easy to use to injure your opponents in a non-lethal manner."
     beltDescription="COIL"
     //Mesh=LodMesh'gausspickup'
     CollisionRadius=8.000000
     CollisionHeight=0.800000
	 bHasMuzzleFlash=False
}
