//=============================================================================
// AmmoCGAssault.
//=============================================================================
class AmmoCGAssault expands BowenAmmo;

//---END-CLASS---

defaultproperties
{
     AmmoAmount=30
     MaxAmmo=200
     ItemName="1mm coilgun bolts"
     ItemArticle="A roll of"
     PickupViewMesh=LodMesh'DeusExItems.Ammo762mm'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmo762'
     largeIconWidth=46
     largeIconHeight=34
     Description="This package contains 30 1mm coilgun bolts, and fuel cell power to fire theem. For use with the BowenCo Coilgun mark II assault rifle."
     beltDescription="1mm"
     Mesh=LodMesh'DeusExItems.Ammo762mm'
     CollisionRadius=6.000000
     CollisionHeight=0.750000
     bCollideActors=True
}
