///////////////////////////////////////////////////
// SciFiFighter.
///////////////////////////////////////////////////

class SciFiFighter extends Vehicles;

#exec MESH IMPORT MESH=SciFiFighter ANIVFILE=MODELS\SciFiFighter_a.3d DATAFILE=MODELS\SciFiFighter_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SciFiFighter X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=SciFiFighter SEQ=All STARTFRAME=0 NUMFRAMES=30
// add further '#exec MESH SEQUENCE' lines here to define additional animation sections

#exec MESHMAP NEW MESHMAP=SciFiFighter MESH=SciFiFighter


//Edit X, Y, and Z values in line below to change size of mesh in game
#exec MESHMAP SCALE MESHMAP=SciFiFighter X=7.743437 Y=7.743437 Z=7.743437

#exec TEXTURE IMPORT NAME=SciFiFighterTex0 FILE=textures\SFShipHigh.PCX GROUP=Skins FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=SciFiFighter NUM=0 TEXTURE=SciFiFighterTex0


defaultproperties
{
    DrawType=DT_Mesh
    Mesh=SciFiFighter
}
