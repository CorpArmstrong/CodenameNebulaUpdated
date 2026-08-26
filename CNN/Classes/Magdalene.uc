//=============================================================================
// Magdalene.
//=============================================================================
class Magdalene extends Female1;

// ----------------------------------------------------------------------
// HasTwoHandedWeapon()
//
// Human.HasTwoHandedWeapon() returns true whenever Weapon.Mass >= 30, and
// the CoilGun the map hands Magdalene is over that. The engine then asks
// for the 2H animation set -- Shoot2H, Walk2H, RunShoot2H, Strafe2H,
// BreatheLight2H -- and Female1's mesh, GFM_TShirtPants, has none of them.
// A single L2 session logged ~150 "Sequence not found" warnings from her
// alone, and she does not animate while armed.
//
// Vanilla hits exactly this combination and solves it the same way:
// AnnaNavarre is also on GFM_TShirtPants, also carries heavy weapons, and
// overrides this to False (AnnaNavarre.uc:72). She then uses the one-handed
// animations the mesh does have.
//
// Trade-off: Magdalene holds the CoilGun one-handed, which is slightly odd
// for its size, but she moves and fires correctly instead of freezing.
// Re-rigging the female mesh for 2H is the only way to do better, and that
// is UnrealEd/modelling work.
// ----------------------------------------------------------------------

function bool HasTwoHandedWeapon()
{
    return false;
}

function float ShieldDamage(name damageType)
{
    // handle special damage types
    if ((damageType == 'Flamed') || (damageType == 'Burned') || (damageType == 'Stunned') ||
        (damageType == 'KnockedOut'))
    {
        return 0.0;
    }
    else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas') ||
    		(damageType == 'Radiation') || (damageType == 'Shocked') || (damageType == 'Poison') ||
            (damageType == 'PoisonEffect'))
    {
        return 0.0;
    }
    else
    {
        return 0.0;
    }
}

defaultproperties
{
    bInvincible=true
    bImportant=true
    bCanBleed=false
    bShowPain=false
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=1.000000,bPermanent=true)
    Alliance=Player
    BurnPeriod=0.000000
    MultiSkins(0)=Texture'CNN.MagdaleneFace1'
    MultiSkins(1)=Texture'CNN.MagdaleneFace1'
    MultiSkins(2)=Texture'CNN.MagdaleneFace1'
    MultiSkins(3)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(4)=FireTexture'Effects.Laser.LaserSpot2'
    MultiSkins(5)=Texture'CNN.MagdaleneFace1'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.JCDentonTex3'
    MultiSkins(7)=Texture'DeusExCharacters.Skins.TiffanySavageTex1'
    BindName="Magdalene"
    FamiliarName="Magdalene"
    UnfamiliarName="Magdalene"
}
