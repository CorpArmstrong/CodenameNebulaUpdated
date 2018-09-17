//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoKarkianEgg extends Object abstract;

//-----------------------------------------------------------------------------
// Biological & Organic Stuff
//-----------------------------------------------------------------------------

// Incubated Karkian Egg
#exec MESH IMPORT MESH=KarkianEgg ANIVFILE=Models\KarkianEgg_a.3d DATAFILE=Models\KarkianEgg_d.3d
#exec MESH ORIGIN MESH=KarkianEgg X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=KarkianEgg X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=KarkianEgg   SEQ=All	STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=KarkianEgg   SEQ=Still	STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=KarkianEgg MESH=KarkianEgg

#exec TEXTURE IMPORT NAME=KarkianEggTex1  FILE=Models\Incubator_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=KarkianEggTex2  FILE=Models\Egg_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=KarkianEgg NUM=0  TEXTURE=KarkianEggTex1
#exec MESHMAP SETTEXTURE MESHMAP=KarkianEgg NUM=1  TEXTURE=KarkianEggTex2
