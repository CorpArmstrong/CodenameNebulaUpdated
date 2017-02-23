//=============================================================================
// Chapter01.
//=============================================================================
class Chapter01 expands MissionScript;

function Timer() {
	
	Super.Timer();
	
	if (Player.IsInState('Dying'))
		{
			Level.Game.SendPlayer(Player, "AvatarServer?Difficulty="$Player.combatDifficulty);
		}
	}

defaultproperties
{
     missionName="Escape from Area 51"
}
