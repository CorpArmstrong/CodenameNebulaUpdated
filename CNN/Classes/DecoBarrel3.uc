//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoBarrel3 expands Object
	abstract;

//-----------------------------------------------------------------------------
// Crates
//-----------------------------------------------------------------------------
// Barrel3

#exec MESH IMPORT MESH=Barrel3 ANIVFILE=Models\Barrel3_a.3d DATAFILE=Models\Barrel3_d.3d
#exec MESH ORIGIN MESH=Barrel3 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Barrel3 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Barrel3 SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Barrel3 SEQ=Still      STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Barrel3 MESH=Barrel3

#exec TEXTURE IMPORT NAME=Barrel3Tex1 FILE=Models\Barrel3_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Barrel3Tex2 FILE=Models\Barrel3_b.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=Barrel3 NUM=0 TEXTURE=Barrel3Tex1
#exec MESHMAP SETTEXTURE MESHMAP=Barrel3 NUM=1 TEXTURE=Barrel3Tex2

defaultproperties
{
}