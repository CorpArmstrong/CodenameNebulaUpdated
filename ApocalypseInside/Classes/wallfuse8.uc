//=============================================================================
// wallfuse8.
//=============================================================================
class wallfuse8 extends AIDeco;

#exec MESH IMPORT MESH=wallfuse8 ANIVFILE=MODELS\wallfuse8_a.3d DATAFILE=MODELS\wallfuse8_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=wallfuse8 X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=wallfuse8 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH LODPARAMS MESH=wallfuse8 STRENGTH=0.0

#exec MESH SEQUENCE MESH=wallfuse8 SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=wallfuse8 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=wallfuse8 SEQ=Fire STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=wallfuse8 SEQ=Reload STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=wallfuse8Tex FILE=Models\wallfuse8.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=wallfuse8Tex FILE=Models\wallfuse8.pcx GROUP=Skins PALETTE=wallfuse8Tex
#exec MESHMAP SETTEXTURE MESHMAP=wallfuse8 NUM=0 TEXTURE=wallfuse8Tex

#exec MESHMAP NEW MESHMAP=wallfuse8 MESH=wallfuse8

defaultproperties
{
     DrawType=DT_Mesh
     bStatic=True
     Mesh=Mesh'ApocalypseInside.wallfuse8'
     DrawScale=15.85555
     CollisionRadius=13.639999
     CollisionHeight=13.639999
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bMovable=False
     bFixedRotationDir=True
     Mass=5000.000000
     Buoyancy=500.000000
     RotationRate=(Yaw=8192)
}
