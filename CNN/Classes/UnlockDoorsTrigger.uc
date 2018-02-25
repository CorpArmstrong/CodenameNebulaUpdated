//-----------------------------------------------------------
// UnlockDoorsTrigger
//-----------------------------------------------------------
class UnlockDoorsTrigger extends Trigger;

var DeusExMover doorMovers[8];
var name doorTags[8];

function Trigger(Actor Other, Pawn Instigator)
{
    local int i;

    for (i = 0; i < ArrayCount(doorMovers); i++)
    {
        foreach AllActors(class'DeusExMover', doorMovers[i], doorTags[i])
	    {
		    doorMovers[i].bLocked = false;
	    }
    }
}

defaultproperties
{
    doorTags(0)=C_Entry1
    doorTags(1)=C_Entry2
}