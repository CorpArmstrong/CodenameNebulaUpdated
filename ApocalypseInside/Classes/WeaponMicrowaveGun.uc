//=============================================================================
// WeaponMicrowaveGun.
//=============================================================================

//Modified -- Y|yukichigai

class WeaponMicrowaveGun extends DeusExWeapon;

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

//Reload time is down considerably

defaultproperties
{
	EAreaType=AOE_Cone
	AreaOfEffect=2
	bPenetrating=True
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     NoiseLevel=0.010000
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_All
     ShotTime=0.200000
     HitDamage=50
     maxRange=48000
     AccurateRange=28800
     BaseAccuracy=0.800000
     bCanHaveScope=True
     bCanHaveLaser=True
     AmmoNames(0)=Class'DeusEx.AmmoBattery'
	 StunDuration=80.000000
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
     AmmoName=Class'AmmoBattery'
     PickupAmmoCount=6
	 bInstantHit=True
     FireOffset=(X=-24.000000,Y=10.000000,Z=14.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.NanoSwordSelect'
     AltFireSound=Sound'DeusExSounds.Weapons.NanoSwordSelect'
     CockingSound=Sound'DeusExSounds.Weapons.NanoSwordSelect'
     SelectSound=Sound'DeusExSounds.Weapons.HideAGunSelect'
     InventoryGroup=52
     ItemName="Microwave Gun"
     PlayerViewOffset=(X=24.000000,Y=-18.000000,Z=-10.000000)
     PlayerViewMesh=LodMesh'DeusExItems.PlasmaRifle'
     PickupViewMesh=LodMesh'DeusExItems.PlasmaRiflePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.PlasmaRifle3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconPlasmaRifle'
     largeIcon=Texture'DeusExUI.Icons.BeltIconPlasmaRifle'
     largeIconWidth=47
     largeIconHeight=37
     Description="A microwave cannon emits a burning hot wave of radiation that causes pain in humans."
     beltDescription="MICRO"
     Mesh=LodMesh'DeusExItems.PlasmaRiflePickup'
     CollisionRadius=8.000000
     CollisionHeight=0.800000
	 bHasMuzzleFlash=False
    bEmitWeaponDrawn=False
    bUseAsDrawnWeapon=False
}
