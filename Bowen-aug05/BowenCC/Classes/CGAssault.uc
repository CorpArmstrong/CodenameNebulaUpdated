//=============================================================================
// CGAssault.
//=============================================================================
class CGAssault expands Coilgun;

simulated function SpawnParticles(vector HitLocation)
{
	local PlasmaSpark Spark;
	local int i, n;
	
		n = Rand(2);
		
		for (i=0; i<n; i++)
		{
			Spark = spawn(class'PlasmaSpark',,,HitLocation);
			if (Spark != None)
			{
				Spark.CalcVelocity(vect(0,0,0), 300);
				Spark.LifeSpan = 2 + 3*FRand();
				Spark.DrawScale *= FRand();
				Spark.Texture = Texture'BowenCust.Effects.HotGlow';
			}
		}
}

simulated function DrawSprites(vector A, vector B)
{
local int i, NumSprites;
local vector line, increment, loc;	
local float f, Dist;
local BowenSpriteBeam BeamSprite;

	
	line = A - B;
	
	Dist = VSize(line);
	f = Dist * 0.010000;
	NumSprites = int(f);

	
	increment = line / NumSprites;
	
	for( i=0; i<NumSprites; i++ )
	{	
		loc = A - (increment * i);
		BeamSprite = Spawn(class'BowenSpriteBeam',,, loc);
		BeamSprite.RemoteRole = Role_None;
		BeamSprite.LifeSpan = 1.0 + FRand();
		BeamSprite.Texture = Texture'DeusExItems.Skins.AlarmLightTex2';
		BeamSprite.DrawScale /= (1.5 + FRand());
		BeamSprite.bFade = True;
	}
}


//---END-CLASS---

defaultproperties
{
     blastRadius=10.000000
     MaxTotalRange=4000.000000
     NumReflections=4
     mpNumReflections=2
     LowAmmoWaterMark=30
     Concealability=CONC_Visual
     bAutomatic=True
     ShotTime=0.150000
     reloadTime=3.000000
     HitDamage=7
     maxRange=3000
     bHasSilencer=False
     recoilStrength=0.300000
     MinWeaponAcc=0.200000
     mpReloadTime=0.500000
     mpHitDamage=10
     mpBaseAccuracy=0.200000
     mpAccurateRange=2400
     mpMaxRange=2400
     mpReloadCount=30
     AmmoName=Class'BowenCC.AmmoCGAssault'
     ReloadCount=30
     PickupAmmoCount=30
     FireOffset=(X=-16.000000,Y=5.000000,Z=11.500000)
     shakemag=0.000000
     FireSound=Sound'DeusExSounds.Weapons.AssaultGunFire'
     AltFireSound=Sound'DeusExSounds.Weapons.AssaultGunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
     InventoryGroup=164
     ItemName="Coilgun Assault Rifle"
     PlayerViewOffset=(X=16.000000,Y=-5.000000,Z=-11.500000)
     PlayerViewMesh=LodMesh'DeusExItems.AssaultGun'
     PickupViewMesh=LodMesh'DeusExItems.AssaultGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.AssaultGun3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconAssaultGun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultGun'
     largeIconWidth=94
     largeIconHeight=65
     invSlotsX=2
     invSlotsY=2
     Description="The second generation of coilguns from BowenCo. The mark II is an assault rifle version that fires smaller, lower energy projectiles in quick sucession"
     beltDescription="CG-ASSAULT"
     Mesh=LodMesh'DeusExItems.AssaultGunPickup'
     CollisionRadius=15.000000
     CollisionHeight=1.100000
     NetPriority=1.400000
}
