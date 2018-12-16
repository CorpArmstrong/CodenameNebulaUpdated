//-----------------------------------------------------------
// Chapter06L1 - Ring 1
//-----------------------------------------------------------
class Chapter06L1 extends MissionScript;

var() string levelName;

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
}

function Timer()
{
    Super.Timer();

    if (player.IsInState('Dying'))
    {
        flags.SetBool('PlayerDied', true);
        Level.Game.SendPlayer(player, levelName);
    }
}

defaultproperties
{
    levelName="06_OpheliaL2#HumanServer"
}
