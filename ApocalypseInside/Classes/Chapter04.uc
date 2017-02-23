//=============================================================================
// Chapter04.
//=============================================================================
class Chapter04 expands MissionScript;

var int TantalusSkillLevel;

function Timer() {

	Super.Timer();
	
	TantalusSkillLevel = Player.SkillSystem.GetSkillLevelValue(class'AiSkillChinese');
	
	if (Player.IsInState('Dying'))
		{
			Player.drugEffectTimer += 60.0;
			Level.Game.SendPlayer(Player, "AvatarServer?Difficulty="$Player.combatDifficulty);
			player.HealPlayer(100, False);
		}
		
	if (TantalusSkillLevel == 2.00) {
		flags.SetBool('Chinese_Elementary',True);
		}
	
	}

defaultproperties
{
     missionName="HK and LA"
}
