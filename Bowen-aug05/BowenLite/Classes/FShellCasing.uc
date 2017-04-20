//=============================================================================
// FShellCasing. 	(c) 2003 JimBowen
//=============================================================================
class FShellCasing extends DeusExFragment;

//---END-CLASS---

defaultproperties
{
     Fragments(0)=LodMesh'DeusExItems.ShellCasing'
     numFragmentTypes=1
     elasticity=0.400000
     ImpactSound=Sound'DeusExSounds.Generic.ShellHit'
     MiscSound=Sound'DeusExSounds.Generic.ShellHit'
     Skin=FireTexture'Effects.UserInterface.WhiteStatic'
     Mesh=LodMesh'DeusExItems.ShellCasing'
     CollisionRadius=0.600000
     CollisionHeight=0.300000
}
