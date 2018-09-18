//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoCannister extends Object abstract;

#exec OBJ LOAD FILE=Effects // Needed for the Armor_Adaptative_SFX FireTexture

// Bio-Cannister

#exec MESH IMPORT MESH=Cannister ANIVFILE=Models\Cannister_a.3d DATAFILE=Models\Cannister_d.3d
#exec MESH ORIGIN MESH=Cannister X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Cannister X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Cannister SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Cannister SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Cannister MESH=Cannister

#exec TEXTURE IMPORT NAME=CannisterTex1 FILE=Models\Cannister_a.pcx GROUP="Skins" FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=Cannister NUM=0 TEXTURE=CannisterTex1
#exec MESHMAP SETTEXTURE MESHMAP=Cannister NUM=1 TEXTURE=Effects.Electricity.Armor_Adaptive_SFX
