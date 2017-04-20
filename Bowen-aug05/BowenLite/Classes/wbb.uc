//=============================================================================
// WBB.	(c) 2003 JimBowen
//=============================================================================
class WBB expands BowenGrenade;

var localized String shortName;
var bool bSPBeacon;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bWeaponStay=False;
	if (Level.NetMode == NM_StandAlone)
		ProjectileClass = class'BounceBomb';
}

function cycleammo()
{
	if(bSPBeacon)
	{
		Pawn(Owner).ClientMessage("BounceBomb fitted with homing beacon.");
		ProjectileClass = class'BounceBombBeacon';
		bSPBeacon = False;
	}
	else
	{
		Pawn(Owner).ClientMessage("BounceBomb filled with attack nanites.");
		ProjectileClass = class'BounceBomb';
		bSPBeacon = True;
	}
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
     ShortName="BounceBomb"
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
     AmmoName=Class'AmmoBounceBomb'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'BounceBombBeacon'
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.NanoVirusGrenadeSelect'
     InventoryGroup=241
     ItemName="BounceBomb hunter-seeker drone"
     PlayerViewOffset=(X=24.000000,Y=-15.000000,Z=-19.000000)
     PlayerViewMesh=LodMesh'DeusExItems.NanoVirusGrenade'
     PickupViewMesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.NanoVirusGrenade3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponNanoVirus'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponNanoVirus'
     largeIconWidth=24
     largeIconHeight=49
     Description="The BowenCo BounceBomb™ Hunter-Seeker drone flies around the area and will lock on to enemies infront of it. Upon contact with soft matter it releases a deadly load of nanomachines designed to rip apart living tissue."
     beltDescription="BOUNCE"
     Mesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
     CollisionRadius=3.000000
     CollisionHeight=2.430000
     Mass=5.000000
     Buoyancy=2.000000
}
