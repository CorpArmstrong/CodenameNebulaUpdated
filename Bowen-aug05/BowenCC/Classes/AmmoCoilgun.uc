//=============================================================================
// AmmoCoilgun.
//=============================================================================
class AmmoCoilgun expands BowenAmmo;

var int spAmmoAmount;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is not a netgame, then override defaults
	if ( Level.NetMode == NM_StandAlone )
	{
		AmmoAmount = spAmmoAmount;
	}
}

//---END-CLASS---

defaultproperties
{
     spAmmoAmount=10
     AmmoAmount=2
     MaxAmmo=100
     ItemName="5mm Coilgun Bolts"
     ItemArticle="A box of"
     PickupViewMesh=LodMesh'DeusExItems.Ammo3006'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmo3006'
     largeIconWidth=43
     largeIconHeight=31
     Description="5mm iron bolts for use with the BowenCo Coilgun weapon, plus fuel cell power for firing."
     beltDescription="Bolt"
     Mesh=LodMesh'DeusExItems.Ammo3006'
     CollisionRadius=18.000000
     CollisionHeight=7.800000
     bCollideActors=True
}
