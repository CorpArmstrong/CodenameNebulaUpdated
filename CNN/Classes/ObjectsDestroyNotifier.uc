//-----------------------------------------------------------------------
// Class:    ObjectsDetroyNotifier
// Author:   CorpArmstrong
//-----------------------------------------------------------------------

class ObjectsDestroyNotifier extends Actor;

const OBJECTS_COUNT = 16;
var bool bStartPolling;
var DeusExPlayer player;

struct ObervableObject
{
    var() name tag;
    var() name goalName;
    var Actor actr;
    var bool bDestroyed;
};

var(ObservableObjects) ObervableObject objects[16];

function PostBeginPlay()
{
    player = DeusExPlayer(GetPlayerPawn());
    FindObjects();
    bStartPolling = true;
    Super.PostBeginPlay();
}

function FindObjects()
{
    local Actor actr;
    local int i;

    for (i = 0; i < OBJECTS_COUNT; i++)
    {
        foreach AllActors(class'Actor', actr, objects[i].tag)
        {
            objects[i].actr = actr;
        }
    }
}

function PollObjects()
{
    local int i;

    for (i = 0; i < OBJECTS_COUNT; i++)
    {
        if (objects[i].actr != none && !objects[i].bDestroyed)
        {
            // bDeleteMe is set shortly after Destroy() is called
            if (objects[i].actr.bDeleteMe)
            {
                objects[i].tag = '';
                objects[i].actr = none;
                objects[i].bDestroyed = true;

                if (player != none)
                {
                    player.GoalCompleted(objects[i].goalName);
                }

                objects[i].goalName = '';
            }
        }
    }
}

simulated function Tick(float TimeDelta)
{
    Super.Tick(TimeDelta);

    if (bStartPolling)
    {
        PollObjects();
    }
}

function Destroyed()
{
    local int i;
    Super.Destroyed();

    bStartPolling = false;

    for (i = 0; i < OBJECTS_COUNT; i++)
    {
        if (objects[i].actr != none)
        {
            objects[i].tag = '';
            objects[i].goalName = '';
            objects[i].actr = none;
        }
    }
}

