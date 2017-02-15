//=============================================================================
// Pipe994.
//=============================================================================
class Pipe994 extends AIDeco;

#exec MESH IMPORT MESH=Pipe994 ANIVFILE=MODELS\Pipe994_a.3d DATAFILE=MODELS\Pipe994_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pipe994 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Pipe994 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH LODPARAMS MESH=Pipe994 STRENGTH=0.0

#exec MESH SEQUENCE MESH=Pipe994 SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe994 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe994 SEQ=Fire STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe994 SEQ=Reload STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Pipe994Tex FILE=Models\pipe994tx.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=Pipe994Tex FILE=Models\pipe994tx.pcx GROUP=Skins PALETTE=Pipe994Tex
#exec MESHMAP SETTEXTURE MESHMAP=Pipe994 NUM=0 TEXTURE=Pipe994Tex

#exec MESHMAP NEW MESHMAP=Pipe994 MESH=Pipe994

defaultproperties
{
     DrawType=DT_Mesh
     bStatic=True
     Mesh=Mesh'ApocalypseInside.Pipe994'
     DrawScale=12.550000
     CollisionRadius=50.639999
     CollisionHeight=50.639999
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bFixedRotationDir=True
     Mass=5000.000000
     Buoyancy=500.000000
     RotationRate=(Yaw=8192)
}
