//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoGasCan extends Object abstract;

// GasCan
#exec MESH IMPORT MESH=GasCan ANIVFILE=Models\GasCan_a.3d DATAFILE=Models\GasCan_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=GasCan X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=GasCan X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=GasCan SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasCan SEQ=Still   STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=GasCan MESH=GasCan

#exec TEXTURE IMPORT NAME=GasCanTex1 FILE=Models\GasCan_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=GasCan NUM=0 TEXTURE=GasCanTex1
