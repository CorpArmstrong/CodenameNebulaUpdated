//=============================================================================
// ChemicalCannister.
//=============================================================================
class ChemicalCannister extends Containers;

enum ESkinColor
{
    SC_Antinomy,
    SC_Arsenic,
    SC_Barium,
    SC_Californium,
    SC_Cesium,
    SC_Copper,
    SC_Fermium,
    SC_Gallium,
    SC_Hassium,
    SC_Iridium,
    SC_Magnesium,
    SC_Molybdenum,
    SC_Osmium,
    SC_Radium,
    SC_Selenium,
    SC_Sodium,
    SC_Technetium,
    SC_Tellurium,
    SC_Vanadium,
    SC_Yttrium
};

var() ESkinColor SkinColor;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_Antinomy:	MultiSkins[1] = Texture'ChemicalCannisterTex16';
					ItemName = "Antinomy (Sb)";
					break;
		case SC_Arsenic:	MultiSkins[1] = Texture'ChemicalCannisterTex2';
					ItemName = "Arsenic (As)";
					break;
		case SC_Barium:		MultiSkins[1] = Texture'ChemicalCannisterTex3';
					ItemName = "Barium (Ba)";
					break;
		case SC_Californium:	MultiSkins[1] = Texture'ChemicalCannisterTex4';
					ItemName = "Californium (Cf)";
					break;
		case SC_Cesium:		MultiSkins[1] = Texture'ChemicalCannisterTex5';
					ItemName = "Cesium (Cs)";
					break;
		case SC_Copper:		MultiSkins[1] = Texture'ChemicalCannisterTex6';
					ItemName = "Copper (Cu)";
					break;
		case SC_Fermium:	MultiSkins[1] = Texture'ChemicalCannisterTex7';
					ItemName = "Fermium (Fm)";
					break;
		case SC_Gallium:	MultiSkins[1] = Texture'ChemicalCannisterTex8';
					ItemName = "Gallium (Ga)";
					break;
		case SC_Hassium:	MultiSkins[1] = Texture'ChemicalCannisterTex9';
					ItemName = "Hassium (Hs)";
					break;
		case SC_Iridium:	MultiSkins[1] = Texture'ChemicalCannisterTex10';
					ItemName = "Iridium (Ir)";
					break;
		case SC_Magnesium:	MultiSkins[1] = Texture'ChemicalCannisterTex11';
					ItemName = "Magnesium (Mg)";
					break;
		case SC_Molybdenum:	MultiSkins[1] = Texture'ChemicalCannisterTex12';
					ItemName = "Molybdenum (Mo)";
					break;
		case SC_Osmium:		MultiSkins[1] = Texture'ChemicalCannisterTex14';
					ItemName = "Osmium (Os)";
					break;
		case SC_Radium:		MultiSkins[1] = Texture'ChemicalCannisterTex15';
					ItemName = "Radium (Ra)";
					break;
		case SC_Selenium:	MultiSkins[1] = Texture'ChemicalCannisterTex17';
					ItemName = "Selenium (Se)";
					break;
		case SC_Sodium:		MultiSkins[1] = Texture'ChemicalCannisterTex13';
					ItemName = "Sodium (Na)";
					break;
		case SC_Technetium:	MultiSkins[1] = Texture'ChemicalCannisterTex18';
					ItemName = "Technetium (Tc)";
					break;
		case SC_Tellurium:	MultiSkins[1] = Texture'ChemicalCannisterTex19';
					ItemName = "Tellurium (Te)";
					break;
		case SC_Vanadium:	MultiSkins[1] = Texture'ChemicalCannisterTex20';
					ItemName = "Vanadium (V)";
					break;
		case SC_Yttrium:	MultiSkins[1] = Texture'ChemicalCannisterTex21';
					ItemName = "Yttrium (Y)";
					break;
	}
}

defaultproperties
{
	HitPoints=10
	bInvincible=true
	bFlammable=false
	ItemName="Chemical Cannister"
	Mesh=LodMesh'CNN.ChemicalCannister'
	CollisionRadius=8.000000
	CollisionHeight=8.500000
	Mass=20.000000
	Buoyancy=40.000000
}
