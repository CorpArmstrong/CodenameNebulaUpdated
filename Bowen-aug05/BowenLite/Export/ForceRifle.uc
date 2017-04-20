//================================================================================
// ForceRifle.
//================================================================================
class ForceRifle extends BowenWeapon;

var float mpRecoilStrength;

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
		ReloadCount=mpReloadCount;
		recoilStrength=0.75;
	}
}

simulated function Tick (float DeltaTime)
{
	if ( Pawn(Owner) == None )
	{
		ProjectileClass=Default.ProjectileClass;
	}
	Super.Tick(DeltaTime);
}

function bool LoadAmmo (int ammoNum)
{
	local Class<Ammo> newAmmoClass;
	local Ammo newAmmo;
	local Pawn P;

	if ( (ammoNum < 0) || (ammoNum > 2) )
	{
		return False;
	}
	P=Pawn(Owner);
	if ( P == None )
	{
		return False;
	}
	newAmmoClass=AmmoNames[ammoNum];
	if ( newAmmoClass != None )
	{
		if ( newAmmoClass != AmmoName )
		{
			newAmmo=Ammo(P.FindInventoryType(newAmmoClass));
			if ( newAmmo == None )
			{
				P.ClientMessage(Sprintf(msgOutOf,newAmmoClass.Default.ItemName));
				return False;
			}
			if ( ProjectileNames[ammoNum] == None )
			{
				bInstantHit=True;
				bAutomatic=Default.bAutomatic;
				ShotTime=Default.ShotTime;
				if ( Level.NetMode != 0 )
				{
					if ( HasReloadMod() )
					{
						reloadTime=mpReloadTime * (1.00 + ModReloadTime);
					}
					else
					{
						reloadTime=mpReloadTime;
					}
				}
				else
				{
					if ( HasReloadMod() )
					{
						reloadTime=Default.reloadTime * (1.00 + ModReloadTime);
					}
					else
					{
						reloadTime=Default.reloadTime;
					}
				}
				FireSound=Default.FireSound;
				ProjectileClass=None;
			}
			else
			{
				bInstantHit=False;
				if ( newAmmo.IsA('AmmoForceGrenade') )
				{
					bAutomatic=False;
					FireSound=None;
					ShotTime=1.00;
				}
				else
				{
					bAutomatic=Default.bAutomatic;
					ShotTime=Default.ShotTime;
					FireSound=Default.FireSound;
				}
				if ( HasReloadMod() )
				{
					reloadTime=2.00 * (1.00 + ModReloadTime);
				}
				else
				{
					reloadTime=2.00;
				}
				ProjectileClass=ProjectileNames[ammoNum];
				ProjectileSpeed=ProjectileClass.Default.speed;
			}
			AmmoName=newAmmoClass;
			AmmoType=newAmmo;
			if ( Ammo20mm(newAmmo) != None )
			{
				FireSound=Sound'AssaultGunFire20mm';
			}
			else
			{
				if ( AmmoRocketWP(newAmmo) != None )
				{
					FireSound=Sound'GEPGunFireWP';
				}
				else
				{
					if ( AmmoRocket(newAmmo) != None )
					{
						FireSound=Sound'GEPGunFire';
					}
				}
			}
			if ( Level.NetMode != 0 )
			{
				SetClientAmmoParams(bInstantHit,bAutomatic,ShotTime,FireSound,ProjectileClass,ProjectileSpeed);
			}
			if ( DeusExPlayer(P) != None )
			{
				DeusExPlayer(P).UpdateBeltText(self);
			}
			ReloadAmmo();
			P.ClientMessage(Sprintf(msgNowHas,ItemName,newAmmoClass.Default.ItemName));
			return True;
		}
		else
		{
			P.ClientMessage(Sprintf(msgAlreadyHas,ItemName,newAmmoClass.Default.ItemName));
		}
	}
	return False;
}

defaultproperties
{
    LowAmmoWaterMark=30
    GoverningSkill=Class'DeusEx.SkillWeaponRifle'
    EnviroEffective=1
    Concealability=1
    bAutomatic=True
    ShotTime=0.10
    reloadTime=3.00
    HitDamage=3
    BaseAccuracy=0.70
    bCanHaveLaser=True
    bCanHaveSilencer=True
    AmmoNames(0)=Class'AmmoForceRifle'
    AmmoNames(1)=Class'AmmoForceGrenade'
    ProjectileNames(0)=Class'ForceSlug'
    ProjectileNames(1)=Class'ForceGrenade'
    recoilStrength=0.50
    MinWeaponAcc=0.20
    mpReloadTime=0.50
    mpHitDamage=9
    mpBaseAccuracy=1.00
    mpAccurateRange=2400
    mpMaxRange=2400
    mpReloadCount=30
    bCanHaveModBaseAccuracy=True
    bCanHaveModReloadCount=True
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    bCanHaveModRecoilStrength=True
    AmmoName=Class'AmmoForceRifle'
    ReloadCount=30
    PickupAmmoCount=30
    FireOffset=(X=-16.00, Y=5.00, Z=11.50)
    ProjectileClass=Class'ForceSlug'
    shakemag=200.00
    FireSound=Sound'DeusExSounds.Weapons.AssaultGunFire'
    AltFireSound=Sound'DeusExSounds.Weapons.AssaultGunReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
    SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
    InventoryGroup=165
    ItemName="Force Rifle"
    ItemArticle="an"
    PlayerViewOffset=(X=16.00, Y=-5.00, Z=-11.50)
    PlayerViewMesh=LodMesh'DeusExItems.AssaultGun'
    PickupViewMesh=LodMesh'DeusExItems.AssaultGunPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.AssaultGun3rd'
    LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
    Icon=Texture'DeusExUI.Icons.BeltIconAssaultGun'
    largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultGun'
    largeIconWidth=94
    largeIconHeight=65
    invSlotsX=2
    invSlotsY=2
    Description="The BowenCo Force rifle is able to launch enemies away from the user. It is dedigned for use in lofted environments"
    beltDescription="FORCE"
    Mesh=LodMesh'DeusExItems.AssaultGunPickup'
    CollisionRadius=15.00
    CollisionHeight=1.10
    Mass=30.00
}