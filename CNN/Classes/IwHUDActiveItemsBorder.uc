//=============================================================================
// IwHUDActiveItemsBorder
//=============================================================================
class IwHUDActiveItemsBorder extends IwHUDActiveItemsBorderBase;

#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_e2.pcx"   NAME="UBHUD_Aug_e" GROUP="UserInterface" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_1.pcx"    NAME="UBHUD_Aug_1" GROUP="UserInterface" MIPS=Off

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
    super.InitWindow();
    SetSize(128,400);
}

defaultproperties
{
    texBorder1=Texture'CNN.UserInterface.UBHUD_Aug_1'
    texBorderCenter=Texture'CNN.UserInterface.UBHUD_Aug_e'
    centerheight=47
    borderTopMargin=7
    borderBottomMargin=6
    borderWidth=128
    topHeight=64
    topOffset=64
    bottomHeight=64
    bottomOffset=64
    tilePosX=0
    tilePosY=0
}
