//================================================================================
// flash.
//================================================================================
class flash extends BowenGrenade;

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
	}
}

function PostBeginPlay ()
{
	Super.PostBeginPlay();
	bWeaponStay=False;
}

function Fire (float Value)
{
	if ( Pawn(Owner) != None )
	{
		if ( bNearWall )
		{
			bReadyToFire=False;
			GotoState('NormalFire');
			bPointing=True;
			PlayAnim('Place',,0.10);
			return;
		}
	}
	Super.Fire(Value);
}

function BecomePickup ()
{
	Super.BecomePickup();
	if ( Level.NetMode != 0 )
	{
		if ( bTossedOut )
		{
			LifeSpan=0.00;
		}
	}
}

simulated function bool TestMPBeltSpot (int BeltSpot)
{
	return BeltSpot == 4;
}

defaultproperties
{
    LowAmmoWaterMark=2
    GoverningSkill=Class'DeusEx.SkillDemolition'
    EnemyEffective=2
    Concealability=1
    ShotTime=0.30
    reloadTime=0.10
    HitDamage=0
    maxRange=4800
    AccurateRange=2400
    BaseAccuracy=1.00
    bPenetrating=False
    StunDuration=60.00
    bHasMuzzleFlash=False
    bHandToHand=True
    bUseAsDrawnWeapon=False
    AITimeLimit=3.50
    AIFireDelay=5.00
    bNeedToSetMPPickupAmmo=False
    mpReloadTime=0.10
    mpBaseAccuracy=1.00
    mpAccurateRange=2400
    mpMaxRange=2400
    AmmoName=Class'AmmoFlashBang'
    ReloadCount=1
    PickupAmmoCount=1
    FireOffset=(X=0.00, Y=10.00, Z=20.00)
    ProjectileClass=Class'FlashBang'
    shakemag=50.00
    SelectSound=Sound'DeusExSounds.Weapons.EMPGrenadeSelect'
    InventoryGroup=114
    ItemName="FlashBang Grenade"
    PlayerViewOffset=(X=24.00, Y=-15.00, Z=-19.00)
    PlayerViewMesh=LodMesh'DeusExItems.EMPGrenade'
    PickupViewMesh=LodMesh'DeusExItems.EMPGrenadePickup'
    ThirdPersonMesh=LodMesh'DeusExItems.EMPGrenade3rd'
    Icon=Texture'DeusExUI.Icons.BeltIconEMPGrenade'
    largeIcon=Texture'DeusExUI.Icons.LargeIconEMPGrenade'
    largeIconWidth=31
    largeIconHeight=49
    Description="The BowenCo Flashbang grenade will blind your opponents for a limited amount of time"
    beltDescription="FLASH"
    Mesh=LodMesh'DeusExItems.EMPGrenadePickup'
    CollisionRadius=3.00
    CollisionHeight=2.43
    Mass=5.00
    Buoyancy=2.00
}