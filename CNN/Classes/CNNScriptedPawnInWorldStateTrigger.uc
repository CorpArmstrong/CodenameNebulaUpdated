//-----------------------------------------------------------
//  Class:    CNNScriptedPawnInWorldStateTrigger
//  Author:   CorpArmstrong
//
//  This trigger will process scripted pawns's world
//  presence i.e methods EnterWorld(), LeaveWorld()
//  based on bInWorld property value.
//  bInWorld = true - means EnterWorld(), otherwise LeaveWorld();
//  Works like basic trigger, but with multiple entries (8)
//-----------------------------------------------------------

class CNNScriptedPawnInWorldStateTrigger extends CNNTrigger;

struct PawnsInWorldState
{
    var() name pawnTag;
    var() bool bInWorld;
};

var(PawnsState) PawnsInWorldState pawnsState[8];

function ProcessScriptedPawnInWorldState()
{
    local int i;
    local ScriptedPawn A;

    for (i = 0; i < ArrayCount(pawnsState); i++)
    {
        if (pawnsState[i].pawnTag != '')
        {
            foreach AllActors(class 'ScriptedPawn', A, pawnsState[i].pawnTag)
            {
                if (pawnsState[i].bInWorld)
                {
                    A.EnterWorld();
                }
                else
                {
                    A.LeaveWorld();
                }
            }
        }
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    ProcessScriptedPawnInWorldState();
    super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        ProcessScriptedPawnInWorldState();
        super.Touch(Other);
    }
}
