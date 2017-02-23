//=============================================================================
// FolderOpen.
//=============================================================================
class FolderOpen extends InformationDevices;

enum ESkinColor
{
	SC_1,
	SC_2
};

var() ESkinColor SkinColor;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_1:	Skin = Texture'FolderTex1'; break;
		case SC_2:	Skin = Texture'FolderTex2'; break;
	}
}

defaultproperties
{
     bAddToVault=True
     bCanBeBase=True
     ItemName="Documents Folder"
     Mesh=LodMesh'ApocalypseInside.FolderOpen'
     CollisionRadius=12.000000
     CollisionHeight=0.200000
     Mass=1.000000
     Buoyancy=4.000000
}
