//=============================================================================
// CaptainValiante.
//=============================================================================
class CaptainValiante extends Sailor;

defaultproperties
{
    Orders=Standing
    bInvincible=true
    bHighlight=false
    InitialInventory(0)=(Inventory=Class'DeusEx.WeaponPistol')
    InitialInventory(1)=(Inventory=Class'DeusEx.Ammo10mm',Count=999)
    Alliance=mj12
    Tag=TrapSoldiers
    Style=STY_Masked
    ScaleGlow=0.000000
    bUnlit=true
    MultiSkins(0)=Texture'DeusExCharacters.Skins.StantonDowdTex0'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    bCollideActors=false
    bBlockActors=false
    bBlockPlayers=false
    BindName="CaptainValiente"
    FamiliarName="Captain Valiante"
    UnfamiliarName="Captain Valiante"
    CarcassType=Class'CNN.CaptainValianteCarcass'
}
