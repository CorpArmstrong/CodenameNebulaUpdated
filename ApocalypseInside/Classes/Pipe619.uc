//=============================================================================
// Pipe619.
//=============================================================================
class Pipe619 extends AIDeco;

#exec MESH IMPORT MESH=Pipe619 ANIVFILE=MODELS\Pipe619_a.3d DATAFILE=MODELS\Pipe619_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pipe619 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Pipe619 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH LODPARAMS MESH=Pipe619 STRENGTH=0.0

#exec MESH SEQUENCE MESH=Pipe619 SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe619 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe619 SEQ=Fire STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe619 SEQ=Reload STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Pipe619Tex FILE=Models\pipe619tx.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=Pipe619Tex FILE=Models\pipe619tx.pcx GROUP=Skins PALETTE=Pipe619Tex
#exec MESHMAP SETTEXTURE MESHMAP=Pipe619 NUM=0 TEXTURE=Pipe619Tex

#exec MESHMAP NEW MESHMAP=Pipe619 MESH=Pipe619

defaultproperties
{
     DrawType=DT_Mesh
     bStatic=True
     Mesh=Mesh'ApocalypseInside.Pipe619'
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
