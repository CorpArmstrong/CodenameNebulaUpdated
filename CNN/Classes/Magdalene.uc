class Magdalene extends Female1;

function float ShieldDamage(name damageType)
{
	// handle special damage types
	if ((damageType == 'Flamed') || (damageType == 'Burned') || (damageType == 'Stunned') ||
	    (damageType == 'KnockedOut'))
		return 0.0;
	else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas') ||
			(damageType == 'Radiation') || (damageType == 'Shocked') || (damageType == 'Poison') ||
	        (damageType == 'PoisonEffect'))
		return 0.0;
	else
		return 0.0;
}

defaultproperties
{
	bInvincible=True
	bImportant=True
     bCanBleed=False
     bShowPain=False
     InitialAlliances(0)=(AllianceName=Player,AllianceLevel=1.000000,bPermanent=True)
     Alliance=Player
	 BurnPeriod=0.000000
    MultiSkins(0)=Texture'ApocalypseInside.MagdaleneFace1'
    MultiSkins(1)=Texture'ApocalypseInside.MagdaleneFace1'
    MultiSkins(2)=Texture'ApocalypseInside.MagdaleneFace1'
    MultiSkins(3)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(4)=FireTexture'Effects.Laser.LaserSpot2'
    MultiSkins(5)=Texture'ApocalypseInside.MagdaleneFace1'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.TiffanySavageTex2'
    MultiSkins(7)=Texture'DeusExCharacters.Skins.TiffanySavageTex1'
     BindName="Magdalene"
     FamiliarName="Magdalene"
     UnfamiliarName="Magdalene"
}
