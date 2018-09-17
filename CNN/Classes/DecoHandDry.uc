//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoHandDry extends Object abstract;

// HandDry
#exec MESH IMPORT MESH=HandDry ANIVFILE=Models\HandDry_a.3d DATAFILE=Models\HandDry_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=HandDry X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=HandDry X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=HandDry SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=HandDry SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=HandDry MESH=HandDry

#exec TEXTURE IMPORT NAME=HandDryTex1 FILE=Models\HandDry_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=HandDryTex2 FILE=Models\HandDry_b.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=HandDry NUM=0 TEXTURE=HandDryTex1

// Sounds for the HandDry
#exec AUDIO IMPORT FILE="Sounds\AirBreath.wav" NAME="AirBreath" GROUP="SFX"
