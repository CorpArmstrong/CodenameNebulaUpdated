//=============================================================================
// Pipe996.
//=============================================================================
class Pipe996 extends AIDeco;

#exec MESH IMPORT MESH=Pipe996 ANIVFILE=MODELS\Pipe996_a.3d DATAFILE=MODELS\Pipe996_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pipe996 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Pipe996 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH LODPARAMS MESH=Pipe996 STRENGTH=0.0

#exec MESH SEQUENCE MESH=Pipe996 SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe996 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe996 SEQ=Fire STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pipe996 SEQ=Reload STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Pipe996Tex FILE=Models\pipe996tx.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=Pipe996Tex FILE=Models\pipe996tx.pcx GROUP=Skins PALETTE=Pipe996Tex
#exec MESHMAP SETTEXTURE MESHMAP=Pipe996 NUM=0 TEXTURE=Pipe996Tex

#exec MESHMAP NEW MESHMAP=Pipe996 MESH=Pipe996

defaultproperties
{
     DrawType=DT_Mesh
     bStatic=True
     Mesh=Mesh'ApocalypseInside.Pipe996'
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
