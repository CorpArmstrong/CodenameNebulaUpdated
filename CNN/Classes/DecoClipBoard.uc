//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoClipBOard extends Object abstract;

// ClipBoard

#exec MESH IMPORT MESH=ClipBoard ANIVFILE=Models\ClipBoard_a.3d DATAFILE=Models\ClipBoard_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=ClipBoard X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=ClipBoard X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=ClipBoard   SEQ=All	STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=ClipBoard   SEQ=Still	STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=ClipBoard MESH=ClipBoard

#exec TEXTURE IMPORT NAME=ClipBoardTex1  FILE=Models\ClipBoard_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=ClipBoard NUM=0  TEXTURE=ClipBoardTex1
