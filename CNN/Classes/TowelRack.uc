//=============================================================================
// TowelRack.
//=============================================================================
class TowelRack extends DeusExDecoration;

enum ESkinColor
{
    SC_Clean,
    SC_Filthy
};

enum TSkinColor
{
    SC_Blue,
    SC_White,
    SC_Brown
};

var() ESkinColor RackColor;
var() TSkinColor TowelColor;

function BeginPlay()
{
    super.BeginPlay();

    switch (RackColor)
    {
        case SC_Clean:  MultiSkins[0] = Texture'TowelRackTex1'; break;
        case SC_Filthy: MultiSkins[0] = Texture'TowelRackTex2'; break;
    }

    switch (TowelColor)
    {
        case SC_Blue:   MultiSkins[1] = Texture'TowelTex1'; break;
        case SC_White:  MultiSkins[1] = Texture'TowelTex2'; break;
        case SC_Brown:  MultiSkins[1] = Texture'TowelTex3'; break;
    }
}

defaultproperties
{
    HitPoints=20
    minDamageThreshold=50
    bInvincible=false
    FragType=Class'CNN.AIMetalFragment'
    bHighlight=false
    ItemName="Towel Rack"
    bPushable=false
    Physics=PHYS_None
    Mesh=LodMesh'CNN.TowelRack'
    CollisionRadius=20.000000
    CollisionHeight=15.000000
    Mass=20.000000
    Buoyancy=40.000000
}
