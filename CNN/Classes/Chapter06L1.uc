//-----------------------------------------------------------
// Chapter06L1 - Ring 1
//-----------------------------------------------------------
class Chapter06L1 extends MissionScript;

var() string levelName;

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
    FrobOnlyEntryDoors();

    // Chapter06.con holds an ungated copy of L2's OpheliaHallway ("Free
    // Ophelia!", then Ophelia hides). It is first in her list, so within
    // its 150 units -- or on a frob -- it played instead of Meet1InspRoom.
    class'Chapter06L2'.static.StripConversation(self, 'OpheliaHallway');
}

// The entry doors are frobbed open; the map also opened them as soon as the
// player came within 150 units of a proximity trigger.
function FrobOnlyEntryDoors()
{
    local Trigger t;

    foreach AllActors(class'Trigger', t)
        if (t.Event == 'Entry_Doors_Double')
            t.SetCollision(false, false, false);
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
