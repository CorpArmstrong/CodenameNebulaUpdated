//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoBarrelToxic extends Object abstract;

// For BarrelToxic

#exec TEXTURE IMPORT NAME=Gen_Green FILE=Textures\Effects\Gen_Green.pcx GROUP="Effects"

// BarrelToxic

#exec MESH IMPORT MESH=BarrelToxic ANIVFILE=Models\BarrelToxic_a.3d DATAFILE=Models\BarrelToxic_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=BarrelToxic X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=BarrelToxic X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=BarrelToxic	SEQ=All		STARTFRAME=0	NUMFRAMES=14
#exec MESH SEQUENCE MESH=BarrelToxic	SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=BarrelToxic MESH=BarrelToxic

#exec TEXTURE IMPORT NAME=BarrelToxicTex1 FILE=Models\BarrelToxic_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=BarrelToxic NUM=0 TEXTURE=BarrelToxicTex1
