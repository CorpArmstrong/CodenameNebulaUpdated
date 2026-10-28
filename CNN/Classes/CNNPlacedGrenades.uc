//=============================================================================
// CNNPlacedGrenades.
//
// ThrownProjectile.Flying.Explode flashes the screen of DeusExPlayer(Owner),
// so a grenade placed in a map has no owner and logs Accessed None twice
// when it goes off -- set off by the player, by another explosion or by a
// shot. The player becomes the owner of every placed grenade (no owner, no
// instigator). An owned trap no longer goes off for its owner, so the
// player's approach is checked here, as ThrownProjectile.Tick does for a
// trap without one.
//
// TantalusDenton.PostPostBeginPlay spawns it on every map.
//=============================================================================
class CNNPlacedGrenades extends Info;

function Tick(float deltaTime)
{
    local ThrownProjectile grenade;
    local DeusExPlayer player;

    Super.Tick(deltaTime);

    player = DeusExPlayer(Owner);
    if (player == none)
        return;

    foreach AllActors(class'ThrownProjectile', grenade)
    {
        if (grenade.Instigator != none)
            continue;

        if (grenade.Owner == none)
            grenade.SetOwner(player);

        if ((grenade.Owner == player) && grenade.bProximityTriggered && grenade.bArmed && !grenade.bDisabled &&
            (grenade.skillTime == 0) && (VSize(player.Location - grenade.Location) < grenade.proxRadius))
            grenade.skillTime = FClamp(-20.0 * player.SkillSystem.GetSkillLevelValue(class'SkillDemolition'), 1.0, 10.0);
    }
}

defaultproperties
{
    bAlwaysRelevant=True
}
