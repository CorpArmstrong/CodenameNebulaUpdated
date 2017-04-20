//=============================================================================
// AmmoFlare.
//=============================================================================
class AmmoFlare extends DeusExAmmo;

defaultproperties
{
     bShowInfo=True
     AmmoAmount=2
     MaxAmmo=20
     ItemName="Bowen Flare"
     ItemArticle="a"
     PickupViewMesh=LodMesh'DeusExItems.Flare'
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconFlare'
     largeIcon=Texture'DeusExUI.Icons.LargeIconFlare'
     largeIconWidth=42
     largeIconHeight=43
     Description="A flare for use with the BowenCo flare gun."
     Mesh=LodMesh'DeusExItems.Flare'
     CollisionRadius=6.200000
     CollisionHeight=1.200000
     bCollideActors=True
}
