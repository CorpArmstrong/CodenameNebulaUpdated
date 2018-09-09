//-----------------------------------------------------------
// CNNChapter06.
//-----------------------------------------------------------
class CNNChapter06 extends MissionScript;

var(ChangeLevelOnDeath) string levelName;

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
}

function Timer()
{
    super.Timer();

    if (player.IsInState('Dying'))
    {
        Level.Game.SendPlayer(player, levelName);
    }
}

defaultproperties
{
    levelName="Mutiny"
}
