//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoToiletPaper expands Object
	abstract;

//ToiletPaper

#exec MESH IMPORT MESH=ToiletPaper ANIVFILE=Models\ToiletPaper_a.3d DATAFILE=Models\ToiletPaper_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=ToiletPaper X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=ToiletPaper X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=ToiletPaper SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=ToiletPaper SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=ToiletPaper MESH=ToiletPaper

#exec TEXTURE IMPORT NAME=ToiletPaperTex1 FILE=Models\ToiletPaper_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ToiletPaperTex2 FILE=Models\ToiletPaper_b.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=ToiletPaper NUM=0 TEXTURE=ToiletPaperTex1

defaultproperties
{
}