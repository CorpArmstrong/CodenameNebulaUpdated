//================================================================================
// AmmoForceGrenade.
//================================================================================
class AmmoForceGrenade extends BowenAmmo;

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
    CollisionRadius=9.50
    CollisionHeight=4.75
    bCollideActors=True
}