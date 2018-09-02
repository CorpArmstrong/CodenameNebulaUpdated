//-----------------------------------------------------------
// SpawnTrigger
//-----------------------------------------------------------
class SpawnTrigger extends CNNTrigger;

var () name ScriptedPawnTag;

function Trigger(Actor Other, Pawn Instigator)
{
    local ScriptedPawn A;

    foreach AllActors(class 'ScriptedPawn', A, ScriptedPawnTag)
    {
        A.EnterWorld();
    }

    Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    local ScriptedPawn A;

    if (IsRelevant(Other))
    {
        foreach AllActors(class 'ScriptedPawn', A, ScriptedPawnTag)
        {
            A.EnterWorld();
        }

        Super.Touch(Other);
    }
}

defaultproperties
{
}
