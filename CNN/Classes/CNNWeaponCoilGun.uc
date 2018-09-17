//=============================================================================
// CNNWeaponCoilGun.
// Modified -- Y|yukichigai
//=============================================================================
class CNNWeaponCoilGun extends GaussGun.WeaponGaussGun;

simulated function PreBeginPlay()
{
    super.PreBeginPlay();

    // If this is a netgame, then override defaults
    if (Level.NetMode != NM_StandAlone)
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

// Reload time is down considerably
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
    bCanHaveScope=true
    bCanHaveLaser=true
    AmmoNames(0)=Class'DeusEx.AmmoDart'
    AmmoNames(1)=Class'DeusEx.AmmoBattery'
    recoilStrength=0.300000
    mpReloadTime=1.500000
    mpHitDamage=12
    mpBaseAccuracy=0.200000
    mpAccurateRange=1200
    mpMaxRange=1200
    mpReloadCount=12
    bCanHaveModBaseAccuracy=true
    bCanHaveModReloadCount=true
    bCanHaveModAccurateRange=true
    bCanHaveModReloadTime=true
    AmmoName=Class'DeusEx.AmmoDart'
    PickupAmmoCount=6
    bInstantHit=true
    FireOffset=(X=-16.00,Y=-5.00,Z=-11.50)
    shakemag=50.000000
    FireSound=Sound'DeusExSounds.Weapons.ProdFire'
    AltFireSound=Sound'DeusExSounds.Weapons.ProdReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.ProdSelect'
    SelectSound=Sound'DeusExSounds.Weapons.PlasmaRifleReload'
    InventoryGroup=53
    ItemName="Coil Gun"
    PlayerViewOffset=(X=16.00,Y=-5.00,Z=-11.50)
    Description="A Coil Gin utilizes electromagnetic coils to propel a metallic projectile. The principle is the same as you eject a dvd from an optical drive, but the coil gun uses much more powerful capacitors. Due to long recharge time of the capacitors this weapon can't fire very fast, however it is silent, long-distance and easy to use to injure your opponents in a non-lethal manner."
    beltDescription="COIL"
    CollisionRadius=8.000000
    CollisionHeight=0.800000
    bHasMuzzleFlash=false
}
