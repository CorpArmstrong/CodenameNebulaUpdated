//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoButton1A expands Object
	abstract;

//-----------------------------------------------------------------------------
// Switches and Buttons
//-----------------------------------------------------------------------------
// Button1A

#exec MESH IMPORT MESH=Button1A ANIVFILE=Models\Button1A_a.3d DATAFILE=Models\Button1A_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=Button1A X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Button1A X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Button1A SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Button1A SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Button1A MESH=Button1A

#exec TEXTURE IMPORT NAME=Button1ATex1 FILE=Models\Button1ATex1.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex2 FILE=Models\Button1ATex2.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex3 FILE=Models\Button1ATex3.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex4 FILE=Models\Button1ATex4.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex5 FILE=Models\Button1ATex5.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex6 FILE=Models\Button1ATex6.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex7 FILE=Models\Button1ATex7.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex8 FILE=Models\Button1ATex8.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex9 FILE=Models\Button1ATex9.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex10 FILE=Models\Button1ATex10.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex11 FILE=Models\Button1ATex11.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex12 FILE=Models\Button1ATex12.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex13 FILE=Models\Button1ATex13.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex14 FILE=Models\Button1ATex14.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex15 FILE=Models\Button1ATex15.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex16 FILE=Models\Button1ATex16.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex17 FILE=Models\Button1ATex17.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex18 FILE=Models\Button1ATex18.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex19 FILE=Models\Button1ATex19.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex20 FILE=Models\Button1ATex20.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex21 FILE=Models\Button1ATex21.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex22 FILE=Models\Button1ATex22.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex23 FILE=Models\Button1ATex23.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex24 FILE=Models\Button1ATex24.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex25 FILE=Models\Button1ATex25.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1ATex26 FILE=Models\Button1ATex26.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=Button1A NUM=0 TEXTURE=Button1ATex23

defaultproperties
{
}