//=============================================================================
// Ship1.
//=============================================================================
class Ship1 extends Actor;

#exec MESH IMPORT MESH=Ship1 ANIVFILE=MODELS\Ship1_a.3d DATAFILE=MODELS\Ship1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Ship1 X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Ship1 SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Ship1 SEQ=ship1 STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JShip10 FILE=MODELS\Ship10.PCX GROUP=Skins // Ship1.pcx

#exec MESHMAP NEW   MESHMAP=Ship1 MESH=Ship1
#exec MESHMAP SCALE MESHMAP=Ship1 X=0.00390625 Y=0.00390625 Z=0.00390625

#exec MESHMAP SETTEXTURE MESHMAP=Ship1 NUM=0 TEXTURE=JShip10

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=Ship1
}
