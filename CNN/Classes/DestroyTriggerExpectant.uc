//-----------------------------------------------------------
// ожидатель на уничтожение
//-----------------------------------------------------------
class DestroyTriggerExpectant expands CNNActor;
var () float CheckDelay;
var () name ScriptedPawnTag;
var () bool bExpect;

function Timer()
{
        local ScriptedPawn A;
        local DeusExPlayer player;


    if (bExpect)
    {
        player = DeusExPlayer(GetPlayerPawn());

        if ( player != none )
        {
            if (player.IsInState('Conversation'))
            {
                 SetTimer(CheckDelay, false);
                 return;
            }
            else
            {
                 foreach AllActors( class 'ScriptedPawn', A, ScriptedPawnTag )
                    A.Destroy();

                 TurnOff();
            }
        }
    }

}

function TurnOn()
{
    bExpect = true;

    SetTimer(CheckDelay, false);
}

function TurnOff()
{
    bExpect = false;
}

defaultproperties
{
     CheckDelay=0.200000
}
