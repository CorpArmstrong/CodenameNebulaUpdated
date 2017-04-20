//=============================================================================
// WVG.
//=============================================================================
class WVG extends BowenGrenade;

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
     ShortName="Vortex"
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
     AmmoName=Class'BowenCC.AmmoVortex'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'BowenCC.VortexGrenade'
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.LAMSelect'
     InventoryGroup=20
     ItemName="Vortex Grenade"
     RespawnTime=120.000000
     PlayerViewOffset=(X=24.000000,Y=-15.000000,Z=-17.000000)
     PlayerViewMesh=LodMesh'BowenCust.JBWeaponGrenade'
     PlayerViewScale=0.700000
     PickupViewMesh=LodMesh'BowenCust.VnadePickup'
     PickupViewScale=0.100000
     ThirdPersonMesh=LodMesh'BowenCust.VGnadeThird'
     ThirdPersonScale=0.050000
     Icon=Texture'BowenCust.BeltIconVGrenade'
     largeIcon=Texture'BowenCust.BeltIconVGrenade'
     largeIconWidth=35
     largeIconHeight=45
     Description="The BowenCo Vortex grenade is by far the most deadly of the BowenCo grenade range, but also the most expensive to produce. It releases a small singularity that can survive for about thirty seconds before collapsing. The singularity will create a vortex of plummetting matter around it and will eat anything that comes too close. You must run or hide after throwing this grenade, as it has a fairly large area of effect. (Textures by jazzkid, sounds modded by XIKRON, mesh by Phasmatis)"
     beltDescription="VORTEX"
     Texture=FireTexture'Effects.Electricity.Nano_SFX_A'
     Mesh=LodMesh'DeusExItems.LAMPickup'
     CollisionRadius=3.800000
     CollisionHeight=3.500000
     Mass=5.000000
     Buoyancy=2.000000
}
