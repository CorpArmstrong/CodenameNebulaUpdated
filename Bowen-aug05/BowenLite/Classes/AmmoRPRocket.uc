//=============================================================================
// AmmoRPRocket.
//=============================================================================
class AmmoRPRocket expands BowenAmmo;

//---END-CLASS---

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=100
     ItemName="ARP Rockets"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.GEPAmmo'
     LandSound=Sound'DeusExSounds.Generic.WoodHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoRockets'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoRockets'
     largeIconWidth=46
     largeIconHeight=36
     Description="A box of 10 mini homing rockets from BowenCo. For use with the BowenCo automated mini rocket pod."
     beltDescription="ARP"
     Mesh=LodMesh'DeusExItems.GEPAmmo'
     CollisionRadius=18.000000
     CollisionHeight=7.800000
     bCollideActors=True
}
