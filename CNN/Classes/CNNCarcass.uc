//=============================================================================
// CNNCarass.
//=============================================================================
class CNNCarcass extends DeusExCarcass;

var(CNNCarass) bool bIndestructible;

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitLocation, Vector momentum, name damageType)
{
    if (!bIndestructible)
    {
        super.TakeDamage(Damage, instigatedBy, hitLocation, momentum, damageType);
    }
}

defaultproperties
{
    bIndestructible=true
}
