//=============================================================================
// SamanthaReedCarcass.
//
// Samantha Reed's body on L2: the map dresses a stock Female2 in her own
// skins, and Female2Carcass would leave a stock secretary. Set as her
// CarcassType by Chapter06L2.SetSocialBossCarcasses().
//=============================================================================
class SamanthaReedCarcass extends DeusExCarcass;

defaultproperties
{
    Mesh2=LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassB'
    Mesh3=LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassC'
    Mesh=LodMesh'DeusExCharacters.GFM_SuitSkirt_Carcass'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SecretaryTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.SecretaryTex0'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.SecretaryTex0'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.ScientistFemaleTex3'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.ChefTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.ChefTex1'
    MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
