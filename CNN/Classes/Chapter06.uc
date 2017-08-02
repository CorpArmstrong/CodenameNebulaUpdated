//-----------------------------------------------------------
// Mission Docks
//-----------------------------------------------------------

class Chapter06 extends CNNBaseIngameCutscene;

var(ChangeLevelOnDeath) string levelName;
var int TantalusSkillLevel;

function DoLevelStuff()
{
    if (player.IsInState('Dying'))
	{
		Level.Game.SendPlayer(player, levelName);
	}

    TantalusSkillLevel = Player.SkillSystem.GetSkillLevelValue(class'AiSkillFrench');

    if (TantalusSkillLevel == 2.00)
    {
		flags.SetBool('French_Elementary', True);
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

