//=============================================================================
// SinkSmall.
//=============================================================================
class SinkSmall extends Sinks;

enum ESkinColor
{
    SC_Light,
    SC_Dark
};

var() ESkinColor SkinColor;

function BeginPlay()
{
    super.BeginPlay();

    switch (SkinColor)
    {
        case SC_Light:  Skin = Texture'Sink1Tex1'; break;
        case SC_Dark:   Skin = Texture'Sink1Tex2'; break;
    }
}

defaultproperties
{
    Mesh=LodMesh'CNN.Sink1'
    CollisionRadius=20.000000
    CollisionHeight=3.500000
    Mass=25.000000
    Buoyancy=50.000000
}
