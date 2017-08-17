//-----------------------------------------------------------------------
// Class:    CNNDetonationTrigger
// Author:   CorpArmstrong
//-----------------------------------------------------------------------

class CNNDetonationTrigger extends CNNTrigger;

const OBJECTS_COUNT = 16;

struct ObervableObject
{
    var() name tag;
    var Actor actr;
	var bool bDestroyed;
};

var(ObjectsToDetonate) ObervableObject objects[16];

function PostBeginPlay()
{
    FindObjects();
    Super.PostBeginPlay();
}

function FindObjects()
{
	local Actor actr;
    local int i;

    for (i = 0; i < ArrayCount(objects); i++)
    {
        foreach AllActors(class'Actor', actr, objects[i].tag)
        {
            objects[i].actr = actr;
        }
    }
}

function DestroyObjects()
{
	local int i;
	
	for (i = 0; i < ArrayCount(objects); i++)
    {
        if (objects[i].actr != none && !objects[i].bDestroyed)
		{
			objects[i].actr.TakeDamage(3000, none, vect(0,0,0), vect(0,0,0), 'Shot');
			objects[i].bDestroyed = true;
		}
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    DestroyObjects();
    Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        DestroyObjects();
        Super.Touch(Other);
    }
}
