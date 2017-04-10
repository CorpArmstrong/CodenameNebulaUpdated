//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AiWeapon extends DeusExWeapon;

function name WeaponDamageType()
{
    local name                    damageType;
    local Class<DeusExProjectile> projClass;

    projClass = Class<DeusExProjectile>(ProjectileClass);

	// CorpArmstrong:
    //if (projClass.IsA('AiDartZyme'))
    if (AmmoName == Class'ApocalypseInside.AiAmmoDartPoisonZyme')
    {
	    Log("Damage type = Zymed!");
    	damageType = 'Zymed';
    	return damageType;
	}
/*
	if (bInstantHit)
    {
		if (StunDuration > 0)
            damageType = 'Stunned';
        else
            damageType = 'Shot';

        if (AmmoType != None)
            if (AmmoType.IsA('AmmoSabot'))
                damageType = 'Sabot';
    }
    else if (projClass != None)
        damageType = projClass.Default.damageType;
    else
        damageType = 'None';
*/
    return (damageType);
}

DefaultProperties
{

}