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
}

defaultproperties
{
    sendToLocation="06_OpheliaDocks#Docked"
    conversationName=ApproachingOphelia
    convNamePlayed=ApproachingOphelia_Played
    actorTag=MagdaleneDenton
    levelName="06_OpheliaL2#HumanServer"
}
