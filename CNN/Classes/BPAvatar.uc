//=============================================================================
// BPAvatar.
//=============================================================================
class BPAvatar extends Avatar;

defaultproperties
{
	CarcassType=Class'CNN.AvatarCarcass'
	InitialInventory(0)=Class'DeusEx.WeaponSword'
	Orders=Standing
    bShowPain=false
    bHateShot=false
    bHateInjury=false
    bReactPresence=false
    bReactAlarm=false
    bReactProjectiles=false
    Tag=BPAvatar
	BindName=BPAvatar
	bInvincible=false
	Mesh=LodMesh'DeusExCharacters.GM_Trench'
	DrawScale=1.10
	MultiSkins(0)=Texture'DeusExCharacters.Skins.BobPageTex0'
	MultiSkins(1)=Texture'DeusExCharacters.Skins.JCDentonTex2'
	MultiSkins(2)=Texture'DeusExCharacters.Skins.JCDentonTex3'
	MultiSkins(3)=Texture'DeusExCharacters.Skins.JCDentonTex0'
	MultiSkins(4)=Texture'DeusExCharacters.Skins.JCDentonTex1'
	MultiSkins(5)=Texture'DeusExCharacters.Skins.JCDentonTex2'
	MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
	MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
