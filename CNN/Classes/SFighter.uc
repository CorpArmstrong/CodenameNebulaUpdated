//=============================================================================
// SFighter.
//=============================================================================
class SFighter extends Actor;

#exec MESH IMPORT MESH=SFighter ANIVFILE=MODELS\SFighter_a.3d DATAFILE=MODELS\SFighter_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SFighter X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=SFighter SEQ=All STARTFRAME=0 NUMFRAMES=30

// add further '#exec MESH SEQUENCE' lines here to define additional animation sections

#exec MESHMAP NEW MESHMAP=SFighter MESH=SFighter

//Edit X, Y, and Z values in line below to change size of mesh in game
#exec MESHMAP SCALE MESHMAP=SFighter X=7.743437 Y=7.743437 Z=7.743437

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=SFighter
}
