//=============================================================================
// Custom Decorations.
//=============================================================================
class DecoChemicalCannister expands Object
	abstract;

// ChemicalCannister

#exec MESH IMPORT MESH=ChemicalCannister ANIVFILE=Models\ChemicalCannister_a.3d DATAFILE=Models\ChemicalCannister_d.3d
#exec MESH ORIGIN MESH=ChemicalCannister X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=ChemicalCannister X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=ChemicalCannister SEQ=All	STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=ChemicalCannister SEQ=Still	STARTFRAME=0	NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=ChemicalCannister MESH=ChemicalCannister

#exec TEXTURE IMPORT NAME=ChemicalCannisterTex1 FILE=Models\ChemicalCannister_a.pcx GROUP="Skins" FLAGS=2
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex2 FILE=Models\ChemicalCannister_As.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex3 FILE=Models\ChemicalCannister_Ba.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex4 FILE=Models\ChemicalCannister_Cf.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex5 FILE=Models\ChemicalCannister_Cs.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex6 FILE=Models\ChemicalCannister_Cu.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex7 FILE=Models\ChemicalCannister_Fm.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex8 FILE=Models\ChemicalCannister_Ga.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex9 FILE=Models\ChemicalCannister_Hs.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex10 FILE=Models\ChemicalCannister_Ir.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex11 FILE=Models\ChemicalCannister_Mg.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex12 FILE=Models\ChemicalCannister_Mo.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex13 FILE=Models\ChemicalCannister_Na.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex14 FILE=Models\ChemicalCannister_Os.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex15 FILE=Models\ChemicalCannister_Ra.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex16 FILE=Models\ChemicalCannister_Sb.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex17 FILE=Models\ChemicalCannister_Se.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex18 FILE=Models\ChemicalCannister_Tc.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex19 FILE=Models\ChemicalCannister_Te.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex20 FILE=Models\ChemicalCannister_V.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=ChemicalCannisterTex21 FILE=Models\ChemicalCannister_Y.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=ChemicalCannister NUM=0 TEXTURE=ChemicalCannisterTex1
#exec MESHMAP SETTEXTURE MESHMAP=ChemicalCannister NUM=1 TEXTURE=ChemicalCannisterTex2

defaultproperties
{
}
