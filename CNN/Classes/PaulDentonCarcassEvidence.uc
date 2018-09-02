//=============================================================================
// PaulDentonCarcassEvidence.
//=============================================================================
class PaulDentonCarcassEvidence extends BoxMedium;

// ----------------------------------------------------------------------
// PostPostBeginPlay()
// ----------------------------------------------------------------------

function PostPostBeginPlay()
{
	local DeusExPlayer player;

	Super.PostPostBeginPlay();

	foreach AllActors(class'DeusExPlayer', player)
		break;

	SetSkin(player);
}

// ----------------------------------------------------------------------
// SetSkin()
// ----------------------------------------------------------------------

function SetSkin(DeusExPlayer player)
{
	if (player != none)
	{
		switch(player.PlayerSkin)
		{
			case 0:	MultiSkins[0] = Texture'PaulDentonTex0';
					MultiSkins[3] = Texture'PaulDentonTex0';
					break;
			case 1:	MultiSkins[0] = Texture'PaulDentonTex4';
					MultiSkins[3] = Texture'PaulDentonTex4';
					break;
			case 2:	MultiSkins[0] = Texture'PaulDentonTex5';
					MultiSkins[3] = Texture'PaulDentonTex5';
					break;
			case 3:	MultiSkins[0] = Texture'PaulDentonTex6';
					MultiSkins[3] = Texture'PaulDentonTex6';
					break;
			case 4:	MultiSkins[0] = Texture'PaulDentonTex7';
					MultiSkins[3] = Texture'PaulDentonTex7';
					break;
		}
	}
}

defaultproperties
{
	HitPoints=10
	FragType=Class'DeusEx.PaperFragment'
	ItemName="Paul Denton carcass"
	bBlockSight=true
	CollisionRadius=42.000000
	CollisionHeight=5.000000
	Mass=50.000000
	Buoyancy=60.000000
	Mesh=LodMesh'DeusExCharacters.GM_Trench_CarcassC'
	MultiSkins(0)=Texture'DeusExCharacters.Skins.PaulDentonTex0'
	MultiSkins(1)=Texture'DeusExCharacters.Skins.PaulDentonTex2'
	MultiSkins(2)=Texture'DeusExCharacters.Skins.PantsTex8'
	MultiSkins(3)=Texture'DeusExCharacters.Skins.PaulDentonTex0'
	MultiSkins(4)=Texture'CNN.Skins.paulsshirt'
	MultiSkins(5)=Texture'DeusExCharacters.Skins.PaulDentonTex2'
	MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
	MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
}
