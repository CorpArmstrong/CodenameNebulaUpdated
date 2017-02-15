//=============================================================================
// ObserX.
//=============================================================================
class ObserX extends AIDeco;

#exec MESH IMPORT MESH=ObserX ANIVFILE=MODELS\ObserX_a.3d DATAFILE=MODELS\ObserX_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ObserX X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=ObserX X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH LODPARAMS MESH=ObserX STRENGTH=0.0

#exec MESH SEQUENCE MESH=ObserX SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ObserX SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ObserX SEQ=Fire STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ObserX SEQ=Reload STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=ObserXTex FILE=Models\ObserX.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=ObserXTex FILE=Models\ObserX.pcx GROUP=Skins PALETTE=ObserXTex
#exec MESHMAP SETTEXTURE MESHMAP=ObserX NUM=0 TEXTURE=ObserXTex

#exec MESHMAP NEW MESHMAP=ObserX MESH=ObserX

defaultproperties
{
     DrawType=DT_Mesh
     bStatic=True
     Mesh=Mesh'ApocalypseInside.ObserX'
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
