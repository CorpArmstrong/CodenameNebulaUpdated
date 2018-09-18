//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoMagazine extends Object abstract;

//-----------------------------------------------------------------------------
// Books & Magazines
//-----------------------------------------------------------------------------
// Magazine
#exec MESH IMPORT MESH=Magazine ANIVFILE=Models\Magazine_a.3d DATAFILE=Models\Magazine_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=Magazine X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Magazine X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Magazine SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Magazine SEQ=Still     STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Magazine MESH=Magazine

#exec TEXTURE IMPORT NAME=MagazineTex1 FILE=Models\Magazine_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=MagazineTex2 FILE=Models\Magazine_b.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=MagazineTex3 FILE=Models\Magazine_c.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=MagazineTex4 FILE=Models\Magazine_d.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=MagazineTex5 FILE=Models\Magazine_e.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=MagazineTex6 FILE=Models\Magazine_f.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=MagazineTex7 FILE=Models\Magazine_g.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=Magazine NUM=0 TEXTURE=MagazineTex1
