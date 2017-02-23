//=============================================================================
// UberAlles.
//=============================================================================
class UberAlles extends MIB;

// ----------------------------------------------------------------------
// SpawnCarcass()
//
// Blow up instead of spawning a carcass
// ----------------------------------------------------------------------

function Carcass SpawnCarcass()
{

	Explode();

	return None;
}
 /*
function Explode(optional vector HitLocation)
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;
	local float explosionDamage;
	local float explosionRadius;

	explosionDamage = 300;
	explosionRadius = 256;

	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
		light.size = 4;

	Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);

	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;

	// spawn a mark
	s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}

	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,Location);
		else
			spawn(class'FleshFragment',,,Location);
	}

	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
}                              */

function SetSkin (DeusExPlayer Player)
{
		switch (Player.PlayerSkin)
		{
			case 0:
			MultiSkins[3] = Texture'ApocalypseInside.Skins.TantalusFace';
			break;
			case 1:
			MultiSkins[3] = Texture'ApocalypseInside.Skins.TantalusAsian';
			break;
			case 2:
			MultiSkins[3] = Texture'ApocalypseInside.Skins.TantalusBlack';
			break;
			case 3:
			MultiSkins[3] = Texture'ApocalypseInside.Skins.TantalusGinger';
			break;
			case 4:
			MultiSkins[3] = Texture'ApocalypseInside.Skins.TantalusGoatee';
			break;
			default:
		}
}

defaultproperties
{

    WalkingSpeed=0.12

    bImportant=True

    bInvincible=False

    BaseAssHeight=-23.00

    InitialInventory(0)=(Inventory=Class'DeusEx.WeaponNanoSword',Count=1),

    InitialInventory(1)=(Inventory=Class'DeusEx.WeaponEMPGrenade',Count=3),

    InitialInventory(2)=(Inventory=Class'DeusEx.AmmoNapalm',Count=999),

    InitialInventory(3)=(Inventory=Class'WeaponSword',Count=1),

    BurnPeriod=0.00

    bHasCloak=True

    CloakThreshold=500

    Health=3000

    HealthHead=1000

    HealthTorso=1000

    HealthLegLeft=200

    HealthLegRight=200

    HealthArmLeft=200

    HealthArmRight=200

    Mesh=LodMesh'DeusExCharacters.GM_DressShirt_B'

    MultiSkins(0)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'

    MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'

    MultiSkins(2)=Texture'DeusExCharacters.Skins.GuntherHermannTex1'

    MultiSkins(3)=Texture'DeusExCharacters.Skins.MIBTex0'

    MultiSkins(4)=Texture'DeusExDeco.Skins.BoneFemurTex1'

    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'

    MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'

    MultiSkins(7)=Texture'DeusExItems.Skins.GrayMaskTex'

    CollisionRadius=20.00

    CollisionHeight=47.50

	BindName="UberAlles"

    FamiliarName="Uber Alles"

    UnfamiliarName="Uber Alles"
}
