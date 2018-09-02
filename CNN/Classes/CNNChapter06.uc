class CNNChapter06 extends MissionScript;

var(ChangeLevelOnDeath) string levelName;

function InitStateMachine()
{
    Super.InitStateMachine();
    FirstFrame();
}

function Timer()
{
    Super.Timer();

	if (player.IsInState('Dying'))
	{
		Level.Game.SendPlayer(player, levelName);
	}
}

defaultproperties
{
    levelName="Mutiny"
}
