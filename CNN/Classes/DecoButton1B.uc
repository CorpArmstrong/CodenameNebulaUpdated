//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoButton1A expands Object
	abstract;

//-----------------------------------------------------------------------------
// Switches and Buttons
//-----------------------------------------------------------------------------
// Button1B

#exec MESH IMPORT MESH=Button1B ANIVFILE=Models\Button1B_a.3d DATAFILE=Models\Button1B_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=Button1B X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Button1B X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Button1B SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=Button1B SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Button1B MESH=Button1B

#exec TEXTURE IMPORT NAME=Button1BTex1 FILE=Models\Button1BTex1.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex2 FILE=Models\Button1BTex2.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex3 FILE=Models\Button1BTex3.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex4 FILE=Models\Button1BTex4.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex5 FILE=Models\Button1BTex5.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex6 FILE=Models\Button1BTex6.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex7 FILE=Models\Button1BTex7.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex8 FILE=Models\Button1BTex8.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex9 FILE=Models\Button1BTex9.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex10 FILE=Models\Button1BTex10.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex11 FILE=Models\Button1BTex11.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex12 FILE=Models\Button1BTex12.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex13 FILE=Models\Button1BTex13.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex14 FILE=Models\Button1BTex14.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex15 FILE=Models\Button1BTex15.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex16 FILE=Models\Button1BTex16.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex17 FILE=Models\Button1BTex17.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex18 FILE=Models\Button1BTex18.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex19 FILE=Models\Button1BTex19.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex20 FILE=Models\Button1BTex20.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex21 FILE=Models\Button1BTex21.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=Button1BTex22 FILE=Models\Button1BTex22.pcx GROUP="Skins
#exec TEXTURE IMPORT NAME=Button1BTex23 FILE=Models\Button1BTex23.pcx GROUP="Skins
#exec TEXTURE IMPORT NAME=Button1BTex24 FILE=Models\Button1BTex24.pcx GROUP="Skins
#exec MESHMAP SETTEXTURE MESHMAP=Button1B NUM=0 TEXTURE=Button1BTex23

defaultproperties
{
}