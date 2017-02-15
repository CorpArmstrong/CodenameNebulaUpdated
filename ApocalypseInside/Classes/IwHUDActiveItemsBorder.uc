//=============================================================================
// IwHUDActiveItemsBorder
//=============================================================================

class IwHUDActiveItemsBorder extends IwHUDActiveItemsBorderBase;

//#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_e_top.pcx"	NAME="UBHUD_Aug_e_top" GROUP="UserInterface" MIPS=Off 
#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_e2.pcx"	NAME="UBHUD_Aug_e" GROUP="UserInterface" MIPS=Off 
//#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_e_bottom.pcx"	NAME="UBHUD_Aug_e_bottom" GROUP="UserInterface" MIPS=Off 

//#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_o_top.pcx"	NAME="UBHUD_Aug_o_top" GROUP="UserInterface" MIPS=Off 
//#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_o_middle.pcx"	NAME="UBHUD_Aug_o_middle" GROUP="UserInterface" MIPS=Off 
//#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_o_bottom.pcx"	NAME="UBHUD_Aug_o_bottom" GROUP="UserInterface" MIPS=Off 

#exec TEXTURE IMPORT FILE="Textures\UBHUD_Aug_1.pcx"	NAME="UBHUD_Aug_1" GROUP="UserInterface" MIPS=Off 

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	SetSize(128,400);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
	 texBorder1=Texture'fgrhk.UserInterface.UBHUD_Aug_1'
//     texBorderTop=Texture'fgrhk.UserInterface.UBHUD_Aug_e_top'
     texBorderCenter=Texture'fgrhk.UserInterface.UBHUD_Aug_e'
//     texBorderBottom=Texture'fgrhk.UserInterface.UBHUD_Aug_e_bottom'
//     texBorderTopO=Texture'fgrhk.UserInterface.UBHUD_Aug_o_top'
//     texBorderCenterO=Texture'fgrhk.UserInterface.UBHUD_Aug_o_middle'
//     texBorderBottomO=Texture'fgrhk.UserInterface.UBHUD_Aug_o_bottom'
     centerheight=47     
     borderTopMargin=7
     borderBottomMargin=6
     borderWidth=128 //48
     topHeight=64
     topOffset=64
     bottomHeight=64
     bottomOffset=64
     tilePosX=0
     tilePosY=0
}
