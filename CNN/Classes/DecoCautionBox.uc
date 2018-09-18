//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoCautionBox extends Object abstract;

// CautionBox

#exec MESH IMPORT MESH=CautionBox ANIVFILE=Models\CautionBox_a.3d DATAFILE=Models\CautionBox_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=CautionBox X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=CautionBox X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=CautionBox SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=CautionBox SEQ=Still   STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=CautionBox MESH=CautionBox

#exec TEXTURE IMPORT NAME=CautionBoxTex1 FILE=Models\CautionBox_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=CautionBox NUM=0 TEXTURE=CautionBoxTex1
