//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoCoffeeMachine expands Object
	abstract;

// CoffeeMachine

#exec MESH IMPORT MESH=CoffeeMachine ANIVFILE=Models\CoffeeMachine_a.3d DATAFILE=Models\CoffeeMachine_d.3d
#exec MESH ORIGIN MESH=CoffeeMachine X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=CoffeeMachine X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=CoffeeMachine SEQ=All		STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=CoffeeMachine SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=CoffeeMachine MESH=CoffeeMachine

#exec TEXTURE IMPORT NAME=CoffeeMachineTex1 FILE=Models\CoffeeMachine_a.pcx GROUP="Skins" FLAGS=2
#exec TEXTURE IMPORT NAME=CoffeeMachineTex2 FILE=Models\CoffeeMachine_b.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=CoffeeMachine NUM=0 TEXTURE=CoffeeMachineTex1
#exec MESHMAP SETTEXTURE MESHMAP=CoffeeMachine NUM=1 TEXTURE=CoffeeMachineTex2

// UI Textures for the CoffeeCup

#exec TEXTURE IMPORT NAME=LargeIconCoffeeCup FILE=Textures\Icons\LargeIconCoffeeCup.pcx GROUP="Icons" MIPS=Off 
#exec TEXTURE IMPORT NAME=BeltIconCoffeeCup FILE=Textures\Icons\SmallIconCoffeeCup.pcx GROUP="Icons" MIPS=Off

// CoffeeCup

#exec MESH IMPORT MESH=CoffeeCup ANIVFILE=Models\CoffeeCup_a.3d DATAFILE=Models\CoffeeCup_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=CoffeeCup X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=CoffeeCup X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=CoffeeCup    SEQ=All	STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CoffeeCup    SEQ=Still	STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=CoffeeCup MESH=CoffeeCup

#exec TEXTURE IMPORT NAME=CoffeeCupTex1  FILE=Models\CoffeeCup_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=CoffeeCup NUM=0  TEXTURE=CoffeeCupTex1

defaultproperties
{
}