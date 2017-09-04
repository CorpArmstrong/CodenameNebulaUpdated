//-----------------------------------------------------------------------
// Class:    ObjectsDetroyNotifier
// Author:   CorpArmstrong
//-----------------------------------------------------------------------

class ObjectsDestroyNotifier extends Actor;

var() name goalCompleteName;

const OBJECTS_COUNT = 32;
var bool bPolling;
var DeusExPlayer player;

struct ObervableObject
{
    var() name tag;
    var() name goalName;
    var Actor actr;
    var bool bDestroyed;
};

var(ObservableObjects) ObervableObject objects[32];

function PostBeginPlay()
{
    player = DeusExPlayer(GetPlayerPawn());
    FindObjects();
    bPolling = true;
    Super.PostBeginPlay();
}

function FindObjects()
{
    local Actor actr;
    local int i;

    for (i = 0; i < ArrayCount(objects); i++)
    {
		if (objects[i].tag != '')
		{
			foreach AllActors(class'Actor', actr, objects[i].tag)
			{
				objects[i].actr = actr;
			}
		}
		else
		{
			objects[i].bDestroyed = true;
		}
    }
}

function PollObjects()
{
    local int i;
	local int deletedObjectsCounter;

    for (i = 0; i < ArrayCount(objects); i++)
    {
        if (objects[i].actr != none && !objects[i].bDestroyed)
        {
            // bDeleteMe is set shortly after Destroy() is called
            if (objects[i].actr.bDeleteMe)
            {
                objects[i].tag = '';
				objects[i].goalName = '';
                objects[i].actr = none;
                objects[i].bDestroyed = true;
				deletedObjectsCounter++;
            }
        }
		else
		{
			deletedObjectsCounter++;
		}
    }
	
	if (deletedObjectsCounter == OBJECTS_COUNT)
	{
		bPolling = false;
		
		if (player != none)
		{
			player.GoalCompleted(goalCompleteName);
		}
	}
}

simulated function Tick(float TimeDelta)
{
    Super.Tick(TimeDelta);

    if (bPolling)
    {
        PollObjects();
    }
}

function Destroyed()
{
    local int i;
    Super.Destroyed();

    bPolling = false;

    for (i = 0; i < ArrayCount(objects); i++)
    {
        if (objects[i].actr != none)
        {
            objects[i].tag = '';
            objects[i].goalName = '';
            objects[i].actr = none;
        }
    }
}
