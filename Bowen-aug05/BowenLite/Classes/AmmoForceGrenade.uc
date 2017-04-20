//=============================================================================
// AmmoForceGrenade. 	(c) 2003 JimBowen
//=============================================================================
class AmmoForceGrenade extends BowenAmmo;

//---END-CLASS---

defaultproperties
{
     AmmoAmount=2
     MaxAmmo=32
     ItemName="Force Grenades"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.Ammo20mm'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmo20mm'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmo20mm'
     largeIconWidth=47
     largeIconHeight=37
     Description="A grenade using the same technology as the BowenCo force rifle's primary fire, but much more powerful. Force grenades are capable of launching adversaries hundreds of feet away"
     beltDescription="F-GREN"
     Mesh=LodMesh'DeusExItems.Ammo20mm'
     CollisionRadius=9.500000
     CollisionHeight=4.750000
     bCollideActors=True
}
