//=============================================================================
// AmmoPlasma2.
//=============================================================================
class AmmoPlasma2 extends DeusExAmmo;

defaultproperties
{
    bShowInfo=true
    AmmoAmount=12
    MaxAmmo=84
    ItemName="Plasma MkII Clip"
    ItemArticle="a"
    PickupViewMesh=LodMesh'CNN.AmmoPlasma2'
    LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
    Icon=Texture'CNN.Icons.BeltIconAmmoPlasma2'
    largeIconWidth=25
    largeIconHeight=47
    Description="A clip of extruded, magnetically-doped plastic slugs that can be heated and delivered with devastating effect using the plasma gun."
    beltDescription="PKII CLIP"
    Mesh=LodMesh'CNN.AmmoPlasma2'
    CollisionRadius=5.200000
    CollisionHeight=8.000000
    bCollideActors=true
}
