//-----------------------------------------------------------
//  my own Dispatcher analog (maybe ugly.. i know)
//-----------------------------------------------------------
class CnnDispatcher expands CNNSimpleTrigger;

// features:
// 1) call Trigger() by the PlayerPawn
// 2) can't react on collision
// 3) maybe include a some bugs :)

var (Dispatcher) name  OutEvents[16]; // Events to generate.
var (Dispatcher) float OutDelays[16]; // Relative delays before generating events.
var int i;

function ActivatedON()
{
    bEnabled = false;      // prevent to triggering\touching
    gotostate('Dispatch');
}

// Touches is dont works with dispatcher
function TouchIN()
{
}

function TouchOUT()
{
    // nothing
}

//
// Dispatch events.
//
state Dispatch
{
Begin:
    disable('Trigger');

    for (i = 0; i < ArrayCount(OutEvents); i++)
    {
        if (OutEvents[i] != '')
        {
            Sleep(OutDelays[i]);

            foreach AllActors( class 'Actor', Target, OutEvents[i] )
            {
                Target.Trigger(self, GetPlayerPawn());
            }
        }
    }

    enable('Trigger');
    super.ActivatedON(); // calls events, and restore bEnabled if it's needs
}
