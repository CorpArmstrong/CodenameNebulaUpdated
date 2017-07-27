//=============================================================================
// AiMetalFragment.
//=============================================================================
class AiGlassFragment expands ApocalypseInsideFragment;

defaultproperties
{
    Fragments(0)=LodMesh'DeusExItems.GlassFragment1'
    Fragments(1)=LodMesh'DeusExItems.GlassFragment2'
    Fragments(2)=LodMesh'DeusExItems.GlassFragment3'
    numFragmentTypes=3
    elasticity=0.40
    ImpactSound=Sound'DeusExSounds.Generic.GlassHit1'
    MiscSound=Sound'DeusExSounds.Generic.GlassHit2'
    Mesh=LodMesh'DeusExItems.GlassFragment1'
    CollisionRadius=6.00
    CollisionHeight=0.00
    Mass=5.00
    Buoyancy=3.00
}
