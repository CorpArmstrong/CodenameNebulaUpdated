//-----------------------------------------------------------
// Mission Docks
//-----------------------------------------------------------
class Chapter06 extends CNNBaseIngameCutscene;

var(ChangeLevelOnDeath) string levelName;

function DoLevelStuff()
{
    if (player.IsInState('Dying'))
    {
        flags.SetBool('PlayerDied', true);
        Level.Game.SendPlayer(player, levelName);
    }
    else if (IsArrivalCompleted && !flags.GetBool('DocksArrivalEMP'))
        ArrivalEMP();
}

// The EMP grenades by the landing spot go off as the player arrives, not
// as traps counting down, and leave the player without bioenergy.
function ArrivalEMP()
{
    local EMPGrenade grenade;

    flags.SetBool('DocksArrivalEMP', true);

    foreach RadiusActors(class'EMPGrenade', grenade, 256, player.Location)
        if (grenade.bProximityTriggered && grenade.bArmed && !grenade.bDisabled)
            grenade.skillTime = 0.01;

    player.Energy = 0;
}

defaultproperties
{
    sendToLocation="06_OpheliaDocks#Docked"
    conversationName=ApproachingOphelia
    convNamePlayed=ApproachingOphelia_Played
    actorTag=MagdaleneDenton
    levelName="06_OpheliaL2#HumanServer"
}
