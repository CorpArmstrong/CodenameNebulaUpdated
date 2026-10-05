//=============================================================================
// MikeWongCarcass.
//
// Michael Wong's body on L2: the map dresses a stock Male2 in a jumpsuit
// with his own skins and scale, and Male2Carcass would leave a man in a
// dress shirt. Set as his CarcassType by Chapter06L2.SetSocialBossCarcasses().
//=============================================================================
class MikeWongCarcass extends DeusExCarcass;

defaultproperties
{
    Mesh2=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB'
    Mesh3=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    DrawScale=0.900000
    MultiSkins(0)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.PantsTex3'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.ChildMale2Tex1'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.TracerTongTex0'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.MiscTex1'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MechanicTex3'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
