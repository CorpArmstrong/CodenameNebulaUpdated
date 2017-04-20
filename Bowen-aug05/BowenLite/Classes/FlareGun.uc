//=============================================================================
// FlareGun.
//=============================================================================
class FlareGun extends BowenWeapon;

defaultproperties
{
     LowAmmoWaterMark=2
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual
     ShotTime=1.000000
     reloadTime=2.000000
     HitDamage=30
     maxRange=4800
     AccurateRange=2400
     BaseAccuracy=1.700000
     bCanHaveScope=False
     ScopeFOV=25
     bCanHaveLaser=False
     recoilStrength=0.500000
     mpReloadTime=2.000000
     mpHitDamage=30
     mpBaseAccuracy=0.200000
     mpAccurateRange=2400
     mpMaxRange=4800
     mpReloadCount=1
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=False
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'AmmoFlare'
     ReloadCount=1
     PickupAmmoCount=2
     bInstantHit=False
     FireOffset=(X=-22.000000,Y=10.000000,Z=14.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.GepGunFireWP'
     CockingSound=Sound'DeusExSounds.Weapons.PistolReload'
     SelectSound=Sound'DeusExSounds.Weapons.PistolSelect'
     InventoryGroup=94
     ItemName="Flare Gun"
     PlayerViewOffset=(X=22.000000,Y=-10.000000,Z=-14.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Glock'
     PickupViewMesh=LodMesh'DeusExItems.GlockPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Glock3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconPistol'
     largeIcon=Texture'DeusExUI.Icons.LargeIconPistol'
     largeIconWidth=46
     largeIconHeight=28
     Description="The BowenCo flaregun. The flares from this gun are packed with an oxidising compound which, although slow burning, contains an enormous amount of energy per unit mass. It will burn a brilliant white, and last much longer than standard flares. The flares are, however, extremely hazardous to those nearby and should be used with caution."
     beltDescription="FLAREGUN"
     Mesh=LodMesh'DeusExItems.GlockPickup'
     CollisionRadius=7.000000
     CollisionHeight=1.000000
     ProjectileClass=class'BowenFlare'
