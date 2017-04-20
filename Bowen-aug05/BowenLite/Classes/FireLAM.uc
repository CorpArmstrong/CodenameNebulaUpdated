//=============================================================================
// FireLAM. 	(c) 2003 JimBowen
//=============================================================================
class FireLAM expands BowenGrenade;

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
	}
}

function PostBeginPlay()
{
   Super.PostBeginPlay();
   bWeaponStay=False;
}

function Fire(float Value)
{
	// if facing a wall, affix the LAM to the wall
	if (Pawn(Owner) != None)
	{
		if (bNearWall)
		{
			bReadyToFire = False;
			GotoState('NormalFire');
			bPointing = True;
			PlayAnim('Place',, 0.1);
			return;
		}
	}

	// otherwise, throw as usual
	Super.Fire(Value);
}

// Become a pickup
// Weapons that carry their ammo with them don't vanish when dropped
function BecomePickup()
{
	Super.BecomePickup();
   if (Level.NetMode != NM_Standalone)
      if (bTossedOut)
         Lifespan = 0.0;
}

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 6);
}
//---END-CLASS---

defaultproperties
{
     ShortName="FIRELAM"
     LowAmmoWaterMark=2
     GoverningSkill=Class'DeusEx.SkillDemolition'
     EnviroEffective=ENVEFF_AirWater
     Concealability=CONC_All
     ShotTime=0.300000
     reloadTime=0.100000
     HitDamage=50
     maxRange=4800
     AccurateRange=2400
     BaseAccuracy=1.000000
     bHasMuzzleFlash=False
     bHandToHand=True
     bUseAsDrawnWeapon=False
     AITimeLimit=3.500000
     AIFireDelay=5.000000
     bNeedToSetMPPickupAmmo=False
     mpReloadTime=0.100000
     mpHitDamage=50
     mpBaseAccuracy=1.000000
     mpAccurateRange=2400
     mpMaxRange=2400
     AmmoName=Class'BowenLite.AmmoFireBomb'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'BowenLite.FireBomb'
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.LAMSelect'
     InventoryGroup=109
     ItemName="Incendiary Grenade"
     PlayerViewOffset=(X=24.000000,Y=-15.000000,Z=-17.000000)
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
     CollisionRadius=3.800000
     CollisionHeight=3.500000
     Mass=5.000000
     Buoyancy=2.000000
}
