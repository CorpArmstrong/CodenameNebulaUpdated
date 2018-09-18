//=============================================================================
// Folder.
//=============================================================================
class Folder extends InformationDevices;

enum ESkinColor
{
    SC_1,
    SC_2
};

var() ESkinColor SkinColor;

function BeginPlay()
{
    super.BeginPlay();

    switch (SkinColor)
    {
        case SC_1:  Skin = Texture'FolderTex1'; break;
        case SC_2:  Skin = Texture'FolderTex2'; break;
    }
}

defaultproperties
{
    bCanBeBase=true
    ItemName="Documents Folder"
    Mesh=LodMesh'CNN.Folder'
    CollisionRadius=9.000000
    CollisionHeight=0.200000
    Mass=1.000000
    Buoyancy=4.000000
}
