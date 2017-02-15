//=============================================================================
// scart4598.
//=============================================================================
class scart4598 expands Object
	abstract;

#exec MESH IMPORT MESH=scart4598 ANIVFILE=MODELS\scart4598_a.3d DATAFILE=MODELS\scart4598_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=scart4598 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=scart4598 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH LODPARAMS MESH=scart4598 STRENGTH=0.0

#exec MESH SEQUENCE MESH=scart4598 SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=scart4598 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=scart4598 SEQ=Fire STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=scart4598 SEQ=Reload STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=scart4598Tex FILE=Models\scart4598.pcx GROUP=Skins FLAGS=2 PALETTE=scart4598Tex
#exec MESHMAP SETTEXTURE MESHMAP=scart4598 NUM=0 TEXTURE=scart4598Tex

#exec MESHMAP NEW MESHMAP=scart4598 MESH=scart4598

defaultproperties
{
}
