//=============================================================================
// MephistophelesCarcass.
//
// Dr. Mephistopheles's body on L2: the map dresses a stock Doctor (Doctor7)
// in his own skins and scale, and DoctorCarcass would leave a plain doctor.
// Set as his CarcassType by Chapter06L2.SetSocialBossCarcasses().
//=============================================================================
class MephistophelesCarcass extends DeusExCarcass;

defaultproperties
{
    Mesh2=LodMesh'DeusExCharacters.GM_Trench_CarcassB'
    Mesh3=LodMesh'DeusExCharacters.GM_Trench_CarcassC'
    Mesh=LodMesh'DeusExCharacters.GM_Trench_Carcass'
    DrawScale=1.100000
    MultiSkins(0)=Texture'DeusExCharacters.Skins.MIBTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.Female4Tex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.GordonQuickTex3'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.ThugMaleTex1'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.ThugMaleTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.Female4Tex2'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex3'
    MultiSkins(7)=Texture'DeusExCharacters.Skins.LensesTex4'
}
