class CNNSetBurningTrigger extends CNNTrigger;

var() name actorName;

function SetBurning()
{
    local CNNBurningScientist actr;

    foreach AllActors(class 'CNNBurningScientist', actr, actorName)
    {
        if(actr.bCanBeBurned)
        {
			actr.TakeDamage(10, none, vect(0,0,0), vect(0,0,0), 'Burned');
        }
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    SetBurning();
    Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        SetBurning();
        Super.Touch(Other);
    }
}

