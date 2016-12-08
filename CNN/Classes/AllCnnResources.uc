//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AllCnnResources expands Object;

//
// GrateWindow.uc
//
#forceexec MESH IMPORT MESH=gratewindow ANIVFILE=Models\gratewindow_a.3d DATAFILE=Models\gratewindow_d.3d ZEROTEX=1

#forceexec MESH SEQUENCE MESH=gratewindow      SEQ=All              STARTFRAME=0   NUMFRAMES=1
#forceexec MESH SEQUENCE MESH=gratewindow      SEQ=Still            STARTFRAME=0   NUMFRAMES=1

#forceexec MESHMAP SCALE MESHMAP=gratewindow X=0.00390625 Y=0.00390625 Z=0.00390625
#forceexec TEXTURE IMPORT NAME=gratewindowTex0  FILE=Models\gratewindowTex0.pcx GROUP=Skins
#forceexec MESHMAP SETTEXTURE MESHMAP=gratewindow NUM=0  TEXTURE=gratewindowTex0

//
// CageLight
//
#exec MESH IMPORT MESH=CLight ANIVFILE=Models\CLight_a.3d DATAFILE=Models\CLight_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=CLight X=0 Y=0 Z=0 YAW=64
//#exec MESHMAP SCALE MESHMAP=CLight X=0.00390625 Y=0.00390625 Z=0.00390625 // original
#exec MESHMAP SCALE MESHMAP=CLight X=1.0 Y=1.0 Z=1.0 // after WOTGreal exporter and unr2de.exe
#exec MESH SEQUENCE MESH=CLight SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=CLight SEQ=Still	STARTFRAME=0	NUMFRAMES=1

#exec Texture Import Name=NCL_White File=Textures\NotCageLightW.pcx GROUP="Skins" Flags=2
#exec Texture Import Name=NCL_Red   File=Textures\NotCageLightR.pcx GROUP="Skins" Flags=2
#exec Texture Import Name=NCL_Green File=Textures\NotCageLightG.pcx GROUP="Skins" Flags=2

#exec MESHMAP SETTEXTURE MESHMAP=CLight NUM=0 TEXTURE=NCL_White

//
// CNN Triggers
//
#exec Texture Import File=Textures\S_CNNTrig.pcx Name=S_CNNTrig Mips=Off Flags=2

DefaultProperties
{

}
