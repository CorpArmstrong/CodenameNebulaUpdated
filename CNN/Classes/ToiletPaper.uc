//=============================================================================
// ToiletPaper.
//=============================================================================
class ToiletPaper extends DeusExDecoration;

enum ESkinColor
{
	SC_Clean,
	SC_Filthy
};

var() ESkinColor SkinColor;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_Clean:	Skin = Texture'ToiletPaperTex1'; break;
		case SC_Filthy:	Skin = Texture'ToiletPaperTex2'; break;
	}
}

defaultproperties
{
	HitPoints=50
	minDamageThreshold=50
	bInvincible=false
	FragType=class'CNN.AIMetalFragment'
	ItemName="Toilet Paper"
	bPushable=false
	Physics=PHYS_None
	Mesh=LodMesh'CNN.ToiletPaper'
	CollisionRadius=7.500000
	CollisionHeight=7.500000
	Mass=10.000000
	Buoyancy=5.000000
}
