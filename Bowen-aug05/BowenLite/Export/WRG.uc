//================================================================================
// WRG.
//================================================================================
class WRG extends BowenGrenade;

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
	return BeltSpot == 5;
}

defaultproperties
{
    LowAmmoWaterMark=2
    GoverningSkill=Class'DeusEx.SkillDemolition'
    EnemyEffective=1
    EnviroEffective=1
    Concealability=3
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
    AITimeLimit=4.00
    AIFireDelay=20.00
    bNeedToSetMPPickupAmmo=False
    mpReloadTime=0.10
    mpHitDamage=2
    mpBaseAccuracy=1.00
    mpAccurateRange=2400
    mpMaxRange=2400
    AmmoName=Class'AmmoWRG'
    ReloadCount=1
    PickupAmmoCount=1
    FireOffset=(X=0.00, Y=10.00, Z=20.00)
    ProjectileClass=Class'DisarmGrenade'
    shakemag=50.00
    SelectSound=Sound'DeusExSounds.Weapons.GasGrenadeSelect'
    InventoryGroup=21
    ItemName="Disarming Grenade"
    PlayerViewOffset=(X=30.00, Y=-13.00, Z=-19.00)
    PlayerViewMesh=LodMesh'DeusExItems.GasGrenade'
    PickupViewMesh=LodMesh'DeusExItems.GasGrenadePickup'
    ThirdPersonMesh=LodMesh'DeusExItems.GasGrenade3rd'
    Icon=Texture'DeusExUI.Icons.BeltIconGasGrenade'
    largeIcon=Texture'DeusExUI.Icons.LargeIconGasGrenade'
    largeIconWidth=23
    largeIconHeight=46
    Description="The disarming grenade from BowenCo is capable of creating a force field temporarily inside the pockets of people in the area, causing their entire inventory to be spewed out around them."
    beltDescription="DISARM"
    Mesh=LodMesh'DeusExItems.GasGrenadePickup'
    CollisionRadius=2.30
    CollisionHeight=3.30
    Mass=5.00
    Buoyancy=2.00
}