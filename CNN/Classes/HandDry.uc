//=============================================================================
// HandDry.
//=============================================================================
class HandDry extends DeusExDecoration;

enum ESkinColor
{
    SC_Clean,
    SC_Filthy
};

var() ESkinColor SkinColor;
var bool bUsing;

function BeginPlay()
{
    super.BeginPlay();

    switch (SkinColor)
    {
        case SC_Clean:  Skin = Texture'HandDryTex1'; break;
        case SC_Filthy: Skin = Texture'HandDryTex2'; break;
    }
}

function Timer()
{
    bUsing = false;
}

function Frob(actor Frobber, Inventory frobWith)
{
    super.Frob(Frobber, frobWith);

    if (bUsing)
    {
        return;
    }

    SetTimer(4.0, false);
    bUsing = true;
}

defaultproperties
{
    HitPoints=50
    minDamageThreshold=50
    bInvincible=false
    FragType=Class'CNN.AiMetalFragment'
    ItemName="Automatic HandDry"
    bPushable=false
    Physics=PHYS_None
    Mesh=LodMesh'CNN.HandDry'
    CollisionRadius=11.200000
    CollisionHeight=8.000000
    Mass=25.000000
    Buoyancy=50.000000
}
