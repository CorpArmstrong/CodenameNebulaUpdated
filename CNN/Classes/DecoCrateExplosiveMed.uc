//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoCrateExplosiveMed expands Object
	abstract;

//CrateExplosiveMed

#exec MESH IMPORT MESH=CrateExplosiveMed ANIVFILE=Models\CrateExplosiveMed_a.3d DATAFILE=Models\CrateExplosiveMed_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=CrateExplosiveMed X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=CrateExplosiveMed X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=CrateExplosiveMed SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=CrateExplosiveMed SEQ=Still   STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=CrateExplosiveMed MESH=CrateExplosiveMed

#exec TEXTURE IMPORT NAME=CrateExplosiveMedTex1 FILE=Models\CrateExplosiveMed_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=CrateExplosiveMed NUM=0 TEXTURE=CrateExplosiveMedTex1

defaultproperties
{
}