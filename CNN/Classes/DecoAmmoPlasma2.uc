//=============================================================================
// Custom Items.
//=============================================================================
Class DecoAmmoPlasma2 expands Object
	abstract;

// For the PlasmaRifle

#exec TEXTURE IMPORT NAME=LargeIconAmmoPlasma2Rifle FILE=Textures\Icons\LargeIconAmmoPlasma2Rifle.pcx GROUP="Icons" MIPS=Off 
#exec TEXTURE IMPORT NAME=BeltIconAmmoPlasma2 FILE=Textures\Icons\SmallIconAmmoPlasma2.pcx GROUP="Icons" MIPS=Off
#exec TEXTURE IMPORT NAME=FlatFXTex49 FILE=Textures\Effects\FlatFXTex49.pcx GROUP="Skins" MIPS=Off

//-----------------------------------------------------------------------------
// Ammunitions
//-----------------------------------------------------------------------------

// AmmoPlasma2

#exec MESH IMPORT MESH=AmmoPlasma2 ANIVFILE=Models\AmmoPlasma2_a.3d DATAFILE=Models\AmmoPlasma2_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=AmmoPlasma2 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=AmmoPlasma2 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=AmmoPlasma2    SEQ=All		STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=AmmoPlasma2    SEQ=Still	STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=AmmoPlasma2MESH=AmmoPlasma2

#exec TEXTURE IMPORT NAME=AmmoPlasma2Tex1  FILE=Models\AmmoPlasma2_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=AmmoPlasma2 NUM=0  TEXTURE=AmmoPlasma2Tex1

defaultproperties
{
}