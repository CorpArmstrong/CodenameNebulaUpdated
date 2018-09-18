//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoBoardBoxSmall extends Object abstract;

//-----------------------------------------------------------------------------
// Crates
//-----------------------------------------------------------------------------
// BoardBoxSmall

#exec MESH IMPORT MESH=BoardBoxSmall ANIVFILE=Models\BoardBoxSmall_a.3d DATAFILE=Models\BoardBoxSmall_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=BoardBoxSmall X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=BoardBoxSmall X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=BoardBoxSmall SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=BoardBoxSmall SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=BoardBoxSmall MESH=BoardBoxSmall

#exec TEXTURE IMPORT NAME=BoardBoxSmallTex1 FILE=Models\BoardBoxSmall_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=BoardBoxSmall NUM=0 TEXTURE=BoardBoxSmallTex1
