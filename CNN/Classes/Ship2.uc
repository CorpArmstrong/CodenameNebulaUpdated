//=============================================================================
// Ship2.
//=============================================================================
class Ship2 extends Actor;

#exec MESH IMPORT MESH=Ship2 ANIVFILE=MODELS\Ship2_a.3d DATAFILE=MODELS\Ship2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Ship2 X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Ship2 SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Ship2 SEQ=ship2 STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=Ship2 MESH=Ship2
#exec MESHMAP SCALE MESHMAP=Ship2 X=0.00390625 Y=0.00390625 Z=0.00390625

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=Ship2
}
