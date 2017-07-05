//=============================================================================
// AiMetalFragment.
//=============================================================================
class AiMetalFragment expands ApocalypseInsideFragment;

defaultproperties
{
    Fragments(0)=LodMesh'DeusExItems.MetalFragment1'
    Fragments(1)=LodMesh'DeusExItems.MetalFragment2'
    Fragments(2)=LodMesh'DeusExItems.MetalFragment3'
    numFragmentTypes=3
    elasticity=0.40
    ImpactSound=Sound'DeusExSounds.Generic.MetalHit1'
    MiscSound=Sound'DeusExSounds.Generic.MetalHit2'
    Mesh=LodMesh'DeusExItems.GlassFragment1'
    CollisionRadius=6.00
    CollisionHeight=0.00
    Mass=5.00
    Buoyancy=3.00
}
