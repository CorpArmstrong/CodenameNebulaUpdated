//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoBarrel2 extends Object abstract;

//-----------------------------------------------------------------------------
// Crates
//-----------------------------------------------------------------------------
// Barrel2

#exec MESH IMPORT MESH=Barrel2 ANIVFILE=Models\Barrel2_a.3d DATAFILE=Models\Barrel2_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=Barrel2 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Barrel2 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Barrel2 SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Barrel2 SEQ=Still      STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Barrel2 MESH=Barrel2

#exec TEXTURE IMPORT NAME=Barrel2Tex1 FILE=Models\Barrel2_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=Barrel2 NUM=0 TEXTURE=Barrel2Tex1
