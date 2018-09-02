//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoSinks expands Object
	abstract;

// Sink1

#exec MESH IMPORT MESH=Sink1 ANIVFILE=Models\Sink1_a.3d DATAFILE=Models\Sink1_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=Sink1 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Sink1 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Sink1 	SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Sink1 	SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Sink1 MESH=Sink1

#exec TEXTURE IMPORT NAME=Sink1Tex1 FILE=Models\Sink1_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Sink1Tex2 FILE=Models\Sink1_b.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=Sink1 NUM=0 TEXTURE=Sink1Tex1

// Sink2

#exec MESH IMPORT MESH=Sink2 ANIVFILE=Models\Sink2_a.3d DATAFILE=Models\Sink2_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=Sink2 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Sink2 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Sink2 	SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Sink2 	SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Sink2 MESH=Sink2

#exec TEXTURE IMPORT NAME=Sink2Tex1 FILE=Models\Sink2_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=Sink2 NUM=0 TEXTURE=Sink2Tex1

defaultproperties
{
}
