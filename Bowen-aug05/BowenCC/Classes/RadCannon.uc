//=============================================================================
// RadCannon. 	(c) 2003 JimBowen
//=============================================================================
class RadCannon extends BowenWeapon;

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

//---END-CLASS---

defaultproperties
{
     LowAmmoWaterMark=12
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     EnviroEffective=ENVEFF_AirVacuum
     bAutomatic=True
     ShotTime=0.125000
     reloadTime=2.000000
     HitDamage=35
     maxRange=24000
     AccurateRange=14400
     BaseAccuracy=0.600000
     bCanHaveScope=True
     ScopeFOV=20
     bCanHaveLaser=True
     bPenetrating=False
     mpReloadTime=0.500000
     mpHitDamage=20
     mpAccurateRange=8000
     mpMaxRange=8000
     mpReloadCount=32
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'BowenCC.AmmoRad'
     ReloadCount=32
     PickupAmmoCount=32
     ProjectileClass=Class'BowenCC.RadBlob'
     shakemag=0.000000
     FireSound=Sound'DeusExSounds.Weapons.PlasmaRifleFire'
     AltFireSound=Sound'DeusExSounds.Weapons.PlasmaRifleReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.PlasmaRifleReload'
     SelectSound=Sound'DeusExSounds.Weapons.PlasmaRifleSelect'
     InventoryGroup=123
     ItemName="Bowen Radiation Cannon"
     PlayerViewOffset=(X=18.000000,Z=-7.000000)
     PlayerViewMesh=LodMesh'DeusExItems.PlasmaRifle'
     PickupViewMesh=LodMesh'DeusExItems.PlasmaRiflePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.PlasmaRifle3rd'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconPlasmaRifle'
     largeIcon=Texture'DeusExUI.Icons.LargeIconPlasmaRifle'
     largeIconWidth=203
     largeIconHeight=66
     invSlotsX=4
     invSlotsY=2
     Description="The BowenCo RadCannon fires radioactive explosive projectiles that do extreme amounts of damage to organic targets (Textures by jazzkid, sounds by XIKRON)"
     beltDescription="RAD"
     Mesh=LodMesh'DeusExItems.PlasmaRiflePickup'
     CollisionRadius=15.600000
     CollisionHeight=5.200000
     Mass=50.000000
}
