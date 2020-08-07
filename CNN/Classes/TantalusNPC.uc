class TantalusNPC extends JCDouble;

function bool Facelift(bool bOn) 
{
}

function SetSkin(DeusExPlayer player)
{
}

defaultproperties
{
    bInvincible=True
	bImportant=True
    bCanBleed=False
    bShowPain=False
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=1.000000,bPermanent=True)
    Alliance=Player
    Mesh=LodMesh'DeusExCharacters.GM_Trench'
    MultiSkins(0)=Texture'CNN.Skins.TantalusFace'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.StantonDowdTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(3)=Texture'CNN.Skins.TantalusFace'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.JockTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.SmugglerTex2'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex4'
    MultiSkins(7)=FireTexture'Effects.Laser.LaserSpot2'
}