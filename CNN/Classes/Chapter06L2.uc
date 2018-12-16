//-----------------------------------------------------------
// Mission L2
//-----------------------------------------------------------
class Chapter06L2 extends MissionScript;

var(ChangeLevelOnDeath) string levelName;

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
    PrepareFirstFrame();
}

function PrepareFirstFrame()
{
    local Inventory anItem;
    local Inventory nextItem;

    if (flags.GetBool('PlayerDied'))
    {
        Player.RestoreAllHealth();

        while (Player.Inventory != none)
        {
            anItem = Player.Inventory;
            Player.DeleteInventory(anItem);
            anItem.Destroy();
        }
    }
}

function DoLevelStuff()
{
    /*
    if (player.IsInState('Dying'))
    {
        Level.Game.SendPlayer(player, levelName);
    }
    */
}

defaultproperties
{
    levelName="06_OpheliaL2#HumanServer"
}
