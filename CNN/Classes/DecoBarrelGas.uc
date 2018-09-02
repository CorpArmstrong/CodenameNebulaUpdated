//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoBarrelGas expands Object
	abstract;

// BarrelGas

#exec MESH IMPORT MESH=BarrelGas ANIVFILE=Models\BarrelGas_a.3d DATAFILE=Models\BarrelGas_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=BarrelGas X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=BarrelGas X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=BarrelGas SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=BarrelGas SEQ=Still    STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=BarrelGas MESH=BarrelGas

#exec TEXTURE IMPORT NAME=BarrelGasTex1 FILE=Models\BarrelGas_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=BarrelGas NUM=0 TEXTURE=BarrelGasTex1

defaultproperties
{
}
