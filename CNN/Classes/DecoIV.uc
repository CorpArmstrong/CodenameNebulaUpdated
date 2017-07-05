//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoIV expands Object
	abstract;

//-----------------------------------------------------------------------------
// Crates
//-----------------------------------------------------------------------------
// IVUnit

#exec MESH IMPORT MESH=IVUnit ANIVFILE=Models\IVunit_a.3d DATAFILE=Models\IVunit_d.3d
#exec MESH SEQUENCE MESH=IVUnit SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=IVUnit SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=IVUnit X=0.00390625 Y=0.00390625 Z=0.00390625
#exec TEXTURE IMPORT NAME=IVUnitTex0 FILE=Models\IVUnitTex0.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=IVUnit NUM=0 TEXTURE=IVUnitTex0

defaultproperties
{
}