//=============================================================================
// AmmoMissile. 	(c) 2003 JimBowen
//=============================================================================
class AmmoMissile expands BowenAmmo;

//---END-CLASS---

defaultproperties
{
     AmmoAmount=1
     MaxAmmo=20
     ItemName="Homing Missiles"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.GEPAmmo'
     LandSound=Sound'DeusExSounds.Generic.WoodHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoRockets'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoRockets'
     largeIconWidth=46
     largeIconHeight=36
     Description="Fire-and-forget independently locking missiles from BowenCo. These missiles also have a built in IFF system that lets them distinguish friend from foe."
     beltDescription="HEAT-SEEK"
     Mesh=LodMesh'DeusExItems.GEPAmmo'
     CollisionRadius=18.000000
     CollisionHeight=7.800000
     bCollideActors=True
}
