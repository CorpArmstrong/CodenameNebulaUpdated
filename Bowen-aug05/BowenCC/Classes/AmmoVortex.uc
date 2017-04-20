//=============================================================================
// AmmoVortex.
//=============================================================================
class AmmoVortex extends DeusExAmmo;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Level.NetMode != NM_standalone)
		MaxAmmo=1;
}

//---END-CLASS---

defaultproperties
{
     AmmoAmount=1
     MaxAmmo=10
     PickupViewMesh=LodMesh'DeusExItems.TestBox'
     Icon=Texture'DeusExUI.Icons.BeltIconLAM'
     beltDescription="VORTEX"
     Mesh=LodMesh'DeusExItems.TestBox'
     CollisionRadius=22.500000
     CollisionHeight=16.000000
     bCollideActors=True
}
