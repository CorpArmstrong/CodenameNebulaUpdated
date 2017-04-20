//================================================================================
// AmmoSuperRifle.
//================================================================================
class AmmoSuperRifle extends BowenAmmo;

var int spAmmoAmount;

simulated function PreBeginPlay ()
{
	Super.PreBeginPlay();
	if ( Level.NetMode == 0 )
	{
		AmmoAmount=spAmmoAmount;
	}
	else
	{
		MaxAmmo=15;
	}
}

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
    CollisionRadius=18.00
    CollisionHeight=7.80
    bCollideActors=True
}