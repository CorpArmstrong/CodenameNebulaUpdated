//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoGlassBottle expands Object
	abstract;

// GlassBottle

#exec MESH IMPORT MESH=GlassBottle ANIVFILE=Models\GlassBottle_a.3d DATAFILE=Models\GlassBottle_d.3d ZEROTEX=1
#exec MESH SEQUENCE MESH=GlassBottle SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=GlassBottle SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=GlassBottle X=0.00390625 Y=0.00390625 Z=0.00390625
#exec TEXTURE IMPORT NAME=GlassBottleTex1 FILE=Models\GlassBottle_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=GlassBottle NUM=0 TEXTURE=GlassBottleTex1

defaultproperties
{
}
