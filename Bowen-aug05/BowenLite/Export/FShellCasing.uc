//================================================================================
// FShellCasing.
//================================================================================
class FShellCasing extends DeusExFragment;

defaultproperties
{
    Fragments=LodMesh'DeusExItems.ShellCasing'
    numFragmentTypes=1
    elasticity=0.40
    ImpactSound=Sound'DeusExSounds.Generic.ShellHit'
    MiscSound=Sound'DeusExSounds.Generic.ShellHit'
    Skin=FireTexture'Effects.UserInterface.WhiteStatic'
    Mesh=LodMesh'DeusExItems.ShellCasing'
    CollisionRadius=0.60
    CollisionHeight=0.30
}