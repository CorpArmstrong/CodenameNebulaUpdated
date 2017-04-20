//================================================================================
// FireLAM.
//================================================================================
class FireLAM extends BowenGrenade;

var localized string ShortName;

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
	return BeltSpot == 6;
}

defaultproperties
{
    ShortName="FIRELAM"
    LowAmmoWaterMark=2
    GoverningSkill=Class'DeusEx.SkillDemolition'
    EnviroEffective=4
    Concealability=3
    ShotTime=0.30
    reloadTime=0.10
    HitDamage=50
    maxRange=4800
    AccurateRange=2400
    BaseAccuracy=1.00
    bHasMuzzleFlash=False
    bHandToHand=True
    bUseAsDrawnWeapon=False
    AITimeLimit=3.50
    AIFireDelay=5.00
    bNeedToSetMPPickupAmmo=False
    mpReloadTime=0.10
    mpHitDamage=50
    mpBaseAccuracy=1.00
    mpAccurateRange=2400
    mpMaxRange=2400
    AmmoName=Class'AmmoFireBomb'
    ReloadCount=1
    PickupAmmoCount=1
    FireOffset=(X=0.00, Y=10.00, Z=20.00)
    ProjectileClass=Class'FireBomb'
    shakemag=50.00
    SelectSound=Sound'DeusExSounds.Weapons.LAMSelect'
    InventoryGroup=109
    ItemName="Incendiary Grenade"
    PlayerViewOffset=(X=24.00, Y=-15.00, Z=-17.00)
    PlayerViewMesh=LodMesh'DeusExItems.LAM'
    PickupViewMesh=LodMesh'DeusExItems.LAMPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.LAM3rd'
    Icon=Texture'DeusExUI.Icons.BeltIconLAM'
    largeIcon=Texture'DeusExUI.Icons.LargeIconLAM'
    largeIconWidth=35
    largeIconHeight=45
    Description="A handheld incendiary grenade from BowenCo."
    beltDescription="FIRE"
    Mesh=LodMesh'DeusExItems.LAMPickup'
    CollisionRadius=3.80
    CollisionHeight=3.50
    Mass=5.00
    Buoyancy=2.00
}