//=============================================================================
// Magazine.
//=============================================================================
class Magazine extends InformationDevices;

enum ESkinColor
{
	SC_1,
	SC_2,
	SC_3,
	SC_4,
	SC_5,
	SC_6,
	SC_7
};

var() ESkinColor SkinColor;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_1:	Skin = Texture'MagazineTex1'; break;
		case SC_2:	Skin = Texture'MagazineTex2'; break;
		case SC_3:	Skin = Texture'MagazineTex3'; break;
		case SC_4:	Skin = Texture'MagazineTex3'; break;
		case SC_5:	Skin = Texture'MagazineTex3'; break;
		case SC_6:	Skin = Texture'MagazineTex3'; break;
		case SC_7:	Skin = Texture'MagazineTex3'; break;
	}
}

defaultproperties
{
     bCanBeBase=True
     ItemName="Magazine"
     Mesh=LodMesh'CNN.Magazine'
     CollisionRadius=13.600000
     CollisionHeight=5.000000
     Mass=2.000000
     Buoyancy=4.000000
}