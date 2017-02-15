//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoTowelRack expands Object
	abstract;

// TowelRack

#exec MESH IMPORT MESH=TowelRack ANIVFILE=Models\TowelRack_a.3d DATAFILE=Models\TowelRack_d.3d
#exec MESH SEQUENCE MESH=TowelRack SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TowelRack SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=TowelRack X=0.00390625 Y=0.00390625 Z=0.00390625
#exec TEXTURE IMPORT NAME=TowelRackTex1 FILE=Models\TowelRack_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=TowelRackTex2 FILE=Models\TowelRack_b.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=TowelTex1 FILE=Models\Towel_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=TowelTex2 FILE=Models\Towel_b.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=TowelTex3 FILE=Models\Towel_c.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=TowelRack NUM=0 TEXTURE=TowelRackTex1
#exec MESHMAP SETTEXTURE MESHMAP=TowelRack NUM=1 TEXTURE=TowelTex1

defaultproperties
{
}