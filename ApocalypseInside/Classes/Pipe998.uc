//=============================================================================
// Pipe998.
//=============================================================================
class Pipe998 extends AIDeco;

#exec MESH IMPORT MESH=Pipe998 ANIVFILE=MODELS\Pipe998_a.3d DATAFILE=MODELS\Pipe998_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pipe998 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Pipe998 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH LODPARAMS MESH=Pipe998 STRENGTH=0.0

#exec MESH SEQUENCE MESH=Pipe998 SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe998 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe998 SEQ=Fire STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe998 SEQ=Reload STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Pipe998Tex FILE=Models\pipe998tx.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=Pipe998Tex FILE=Models\pipe998tx.pcx GROUP=Skins PALETTE=Pipe998Tex
#exec MESHMAP SETTEXTURE MESHMAP=Pipe998 NUM=0 TEXTURE=Pipe998Tex

#exec MESHMAP NEW MESHMAP=Pipe998 MESH=Pipe998

defaultproperties
{
     DrawType=DT_Mesh
     bStatic=True
     Mesh=Mesh'ApocalypseInside.Pipe998'
     DrawScale=5.000000
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
