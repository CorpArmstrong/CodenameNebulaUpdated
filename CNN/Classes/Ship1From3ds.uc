//=============================================================================
// Ship1From3ds.
//=============================================================================
class Ship1From3ds extends Actor;

#exec MESH IMPORT MESH=Ship1From3ds ANIVFILE=MODELS\Ship1From3ds_a.3d DATAFILE=MODELS\Ship1From3ds_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Ship1From3ds X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Ship1From3ds SEQ=All              STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Ship1From3ds SEQ=ship1-fomblender STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=Ship1From3ds MESH=Ship1From3ds
#exec MESHMAP SCALE MESHMAP=Ship1From3ds X=0.00390625 Y=0.00390625 Z=0.00390625

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=Ship1From3ds
}
