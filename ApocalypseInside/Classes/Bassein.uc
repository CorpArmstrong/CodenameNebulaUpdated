//=============================================================================
// bassein.
//=============================================================================
class bassein extends AIDeco;

#exec MESH IMPORT MESH=bassein ANIVFILE=MODELS\bassein_a.3d DATAFILE=MODELS\bassein_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bassein X=0 Y=0 Z=0 YAW=64
#exec MESHMAP SCALE MESHMAP=bassein X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH LODPARAMS MESH=bassein STRENGTH=0.0

#exec MESH SEQUENCE MESH=bassein SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=bassein SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=bassein SEQ=Fire STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=bassein SEQ=Reload STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=basseinTex1 FILE=Models\bassein.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=basseinTex1 FILE=Models\bassein.pcx GROUP=Skins PALETTE=basseinTex1
#exec MESHMAP SETTEXTURE MESHMAP=bassein NUM=0 TEXTURE=basseinTex1

#exec MESHMAP NEW MESHMAP=bassein MESH=bassein
#exec MESHMAP SCALE MESHMAP=bassein X=1.0 Y=1.0 Z=1.0

defaultproperties
{
     DrawType=DT_Mesh
     bStatic=False
     Texture=Texture'ApocalypseInside.Skins.bassein'
     Mesh=Mesh'ApocalypseInside.bassein'
     DrawScale=0.5
     CollisionRadius=25.639999
     CollisionHeight=25.699997
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bFixedRotationDir=True
     Mass=5000.000000
     Buoyancy=500.000000
     RotationRate=(Yaw=8192)
}
