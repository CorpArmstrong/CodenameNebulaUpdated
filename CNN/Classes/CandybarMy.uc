class CandybarMy expands Actor;

//#exec MESH IMPORT MESH=CandybarMy ANIVFILE=MODELS\CandybarMy_a.3d DATAFILE=MODELS\CandybarMy_d.3d X=0 Y=0 Z=0
//#exec MESH ORIGIN MESH=CandybarMy X=0 Y=0 Z=0

//#exec MESH SEQUENCE MESH=CandybarMy SEQ=All STARTFRAME=0 NUMFRAMES=1
////#exec MESH SEQUENCE MESH=CandybarMy SEQ=??? STARTFRAME=0 NUMFRAMES=1

//#exec MESHMAP NEW MESHMAP=CandybarMy MESH=CandybarMy
//#exec MESHMAP SCALE MESHMAP=CandybarMy X=0.1 Y=0.1 Z=0.2

//#exec TEXTURE IMPORT NAME=Jtex1 FILE=MODELS\CandybarMy.pcx GROUP=Skins FLAGS=2
//#exec TEXTURE IMPORT NAME=Jtex1 FILE=MODELS\CandybarMy.pcx GROUP=Skins PALETTE=Jtex1
//#exec MESHMAP SETTEXTURE MESHMAP=CandybarMy NUM=1 TEXTURE=Jtex1

defaultproperties
{
     DrawType=DT_Mesh
}
