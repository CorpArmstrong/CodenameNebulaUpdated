//=============================================================================
// Magdalene.
//=============================================================================
class Magdalene extends Female1;

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
