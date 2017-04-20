//=============================================================================
// WLD.	(c) 2003 JimBowen
//=============================================================================
class WLD expands BowenGrenade;

var localized String shortName;

function PostBeginPlay()
{
   Super.PostBeginPlay();
   bWeaponStay=False;
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
     ShortName="Locator"
     LowAmmoWaterMark=2
     GoverningSkill=Class'DeusEx.SkillDemolition'
     EnviroEffective=ENVEFF_AirWater
     Concealability=CONC_All
     ShotTime=0.300000
     reloadTime=0.100000
     HitDamage=50
     maxRange=4800
     AccurateRange=2400
     BaseAccuracy=0.000000
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
     AmmoName=Class'AmmoLD'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'HunterDroneProj'
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.NanoVirusGrenadeSelect'
     InventoryGroup=241
     ItemName="Locator Drone"
     PlayerViewOffset=(X=24.000000,Y=-15.000000,Z=-19.000000)
     PlayerViewMesh=LodMesh'DeusExItems.NanoVirusGrenade'
     PickupViewMesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.NanoVirusGrenade3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponNanoVirus'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponNanoVirus'
     largeIconWidth=24
     largeIconHeight=49
     Description="The BowenCo Locator roams an area looking for hostiles, before attaching itself to the first one it finds. Once attached it boroadcasts the target\'s location back to the user."
     beltDescription="BOUNCE"
     Mesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
     CollisionRadius=3.000000
     CollisionHeight=2.430000
     Mass=5.000000
     Buoyancy=2.000000
}
