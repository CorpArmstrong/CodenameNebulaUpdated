//=============================================================================
// WeaponSnowblind.
//=============================================================================

//Modified -- Y|yukichigai

class WeaponSnowblind extends DeusExWeapon;

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

function name WeaponDamageType ()
{
	return 'EMP';
}


defaultproperties
{
	EAreaType=AOE_Cone
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
     AmmoNames(0)=Class'DeusEx.AmmoBattery'
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
     FireSound=Sound'DeusExSounds.Weapons.NanoVirusGrenadeSelect'
     AltFireSound=Sound'DeusExSounds.Weapons.NanoVirusGrenadeSelect'
     CockingSound=Sound'DeusExSounds.Weapons.NanoVirusGrenadeSelect'
     SelectSound=Sound'DeusExSounds.Weapons.HideAGunSelect'
     InventoryGroup=51
     ItemName="Snowblind EMP Disruptor"
    PlayerViewOffset=(X=21.00,Y=-12.00,Z=-19.00)
    PlayerViewMesh=LodMesh'DeusExItems.MultitoolPOV'
    PickupViewMesh=LodMesh'DeusExItems.Multitool'
    ThirdPersonMesh=LodMesh'DeusExItems.Multitool3rd'
    LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
    Icon=Texture'DeusExUI.Icons.BeltIconMultitool'
    largeIcon=Texture'DeusExUI.Icons.LargeIconMultitool'
     largeIconWidth=47
     largeIconHeight=37
     Description="A Snowblind microwave cannon emits a burning hot wave of radiation that causes pain in humans."
     beltDescription="SNOWBLIND"
     Mesh=LodMesh'DeusExItems.Multitool'
     CollisionRadius=8.000000
     CollisionHeight=0.800000
}
