//=============================================================================
// AmmoSuperRifle.
//=============================================================================
class AmmoSuperRifle expands BowenAmmo;

var int spAmmoAmount;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is not a netgame, then override defaults
	if ( Level.NetMode == NM_StandAlone )
	{
		AmmoAmount = spAmmoAmount;
	}
	else MaxAmmo = 15;
}

//---END-CLASS---

defaultproperties
{
     spAmmoAmount=12
     AmmoAmount=5
     MaxAmmo=100
     ItemName="Explosive Sniper Rounds"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo3006'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmo3006'
     largeIconWidth=43
     largeIconHeight=31
     Description="Explosive bullets for use with the BowenCo Super Rifle."
     beltDescription="EXPLOSIVE"
     Mesh=LodMesh'DeusExItems.Ammo3006'
     CollisionRadius=18.000000
     CollisionHeight=7.800000
     bCollideActors=True
}
