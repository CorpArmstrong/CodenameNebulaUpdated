//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoCandle1 expands Object
	abstract;

//-----------------------------------------------------------------------------
// Lamps & Lights
//-----------------------------------------------------------------------------
// Candle1

#exec MESH IMPORT MESH=Candle1 ANIVFILE=Models\Candle1_a.3d DATAFILE=Models\Candle1_d.3d
#exec MESH SEQUENCE MESH=Candle1 SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Candle1 SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=Candle1 X=0.00390625 Y=0.00390625 Z=0.00390625
#exec TEXTURE IMPORT NAME=Candle1Tex1 FILE=Models\Candle1_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=Candle1 NUM=0 TEXTURE=Candle1Tex1
#exec MESHMAP SETTEXTURE MESHMAP=Candle1 NUM=1 TEXTURE=Effects.Fire.OneFlame_J

defaultproperties
{
}