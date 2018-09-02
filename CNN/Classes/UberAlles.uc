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
	return none;
}

function SetSkin (DeusExPlayer Player)
{
	switch (Player.PlayerSkin)
	{
		case 0:
			MultiSkins[3] = Texture'CNN.Skins.TantalusFace';
			break;
		case 1:
			MultiSkins[3] = Texture'CNN.Skins.TantalusAsian';
			break;
		case 2:
			MultiSkins[3] = Texture'CNN.Skins.TantalusBlack';
			break;
		case 3:
			MultiSkins[3] = Texture'CNN.Skins.TantalusGinger';
			break;
		case 4:
			MultiSkins[3] = Texture'CNN.Skins.TantalusGoatee';
			break;
		default:
	}
}

defaultproperties
{
    WalkingSpeed=0.12
    bImportant=true
    bInvincible=false
    BaseAssHeight=-23.00
    InitialInventory(0)=(Inventory=Class'DeusEx.WeaponNanoSword',Count=1),
    InitialInventory(1)=(Inventory=Class'DeusEx.WeaponEMPGrenade',Count=3),
    InitialInventory(2)=(Inventory=Class'DeusEx.AmmoNapalm',Count=999),
    InitialInventory(3)=(Inventory=Class'WeaponSword',Count=1),
    BurnPeriod=0.00
    bHasCloak=true
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
    MultiSkins(4)=Texture'CNN.UberAllesHelmet'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.GrayMaskTex'
	Texture=none
    CollisionRadius=20.00
    CollisionHeight=47.50
	BindName="UberAlles"
    FamiliarName="Uber Alles"
    UnfamiliarName="Uber Alles"
}
