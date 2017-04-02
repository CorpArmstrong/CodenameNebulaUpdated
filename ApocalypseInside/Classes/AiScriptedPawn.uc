//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AiScriptedPawn extends ScriptedPawn;

// ----------------------------------------------------------------------
// TakeDamageBase()
// ----------------------------------------------------------------------

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType,
                        bool bPlayAnim)
{
    local int          actualDamage;
    local Vector       offset;
    local float        origHealth;
    local EHitLocation hitPos;
    local float        shieldMult;

    // use the hitlocation to determine where the pawn is hit
    // transform the worldspace hitlocation into objectspace
    // in objectspace, remember X is front to back
    // Y is side to side, and Z is top to bottom
    offset = (hitLocation - Location) << Rotation;

    if (!CanShowPain())
        bPlayAnim = false;

    // Prevent injury if the NPC is intangible
    if (!bBlockActors && !bBlockPlayers && !bCollideActors)
        return;

    // No damage + no damage type = no reaction
    if ((Damage <= 0) && (damageType == 'None'))
        return;

    // Block certain damage types; perform special ops on others
    if (!FilterDamageType(instigatedBy, hitLocation, offset, damageType))
        return;

    // Impart momentum
    ImpartMomentum(momentum, instigatedBy);

    actualDamage = ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);

    if (actualDamage > 0)
    {
        shieldMult = ShieldDamage(damageType);
        if (shieldMult > 0)
            actualDamage = Max(int(actualDamage*shieldMult), 1);
        else
            actualDamage = 0;
        if (shieldMult < 1.0)
            DrawShield();
    }

    origHealth = Health;

    hitPos = HandleDamage(actualDamage, hitLocation, offset, damageType);
    if (!bPlayAnim || (actualDamage <= 0))
        hitPos = HITLOC_None;

	// CorpArmstrong:
	if (DamageType == 'Zymed')
	{
		Log("Fucking Zymed!");
		//DeusExPlayer(GetPlayerPawn()).ClientMessage("Fucking Zymed!");
		PlayAnim('Panic', , 0.9);
		//PlayPanicRunning();
	}

    if (bCanBleed)
        if ((damageType != 'Stunned') && (damageType != 'TearGas') && (damageType != 'HalonGas') &&
            (damageType != 'PoisonGas') && (damageType != 'Radiation') && (damageType != 'EMP') &&
            (damageType != 'NanoVirus') && (damageType != 'Drowned') && (damageType != 'KnockedOut') &&
            (damageType != 'Poison') && (damageType != 'PoisonEffect'))
            bleedRate += (origHealth-Health)/(0.3*Default.Health);  // 1/3 of default health = bleed profusely

    if (CarriedDecoration != None)
        DropDecoration();

    if ((actualDamage > 0) && (damageType == 'Poison'))
        StartPoison(Damage, instigatedBy);

    if (Health <= 0)
    {
        ClearNextState();
        //PlayDeathHit(actualDamage, hitLocation, damageType);
        if ( actualDamage > mass )
            Health = -1 * actualDamage;
        SetEnemy(instigatedBy, 0, true);

        // gib us if we get blown up
        if (DamageType == 'Exploded')
            Health = -10000;
        else
            Health = -1;

        Died(instigatedBy, damageType, HitLocation);

        if ((DamageType == 'Flamed') || (DamageType == 'Burned'))
        {
            bBurnedToDeath = true;
            ScaleGlow *= 0.1;  // blacken the corpse
        }
        else
            bBurnedToDeath = false;

        return;
    }

    // play a hit sound
    if (DamageType != 'Stunned')
        PlayTakeHitSound(actualDamage, damageType, 1);

    if ((DamageType == 'Flamed') && !bOnFire)
        CatchFire();




    ReactToInjury(instigatedBy, damageType, hitPos);
}

DefaultProperties
{

}