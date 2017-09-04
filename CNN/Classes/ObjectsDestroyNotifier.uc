//-----------------------------------------------------------------------
// Class:    ObjectsDetroyNotifier
// Author:   CorpArmstrong
//-----------------------------------------------------------------------

class ObjectsDestroyNotifier extends Actor;

var() name goalCompleteName;

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
	
	if (deletedObjectsCounter == ArrayCount(objects))
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

/*
defaultproperties
{
	objects[0].tag=LibertyEvidence
	objects[1]=BigTank
	objects[2]=CarEvidence
	objects[3]=BuddhaEvidence
	objects[4]=PaulDentonCarcassEvidence
	objects[5]=JosephManderleyCarcassEvidence
	objects[6]=MeadCarcassEvidence
	objects[7]=DeusExMoverMonaLisa
	objects[8]=AlienCarcassEvidence
	objects[9]=DeusExMoverRocket1
	objects[10]=DeusExMoverRocket2
	objects[11]=DeusExMoverRocket3
	objects[12]=SkullEvidence1
	objects[13]=SkullEvidence2
	objects[14]=SkullEvidence3
	objects[15]=BoneEvidence1
	objects[16]=BoneEvidence2
	objects[17]=BoneEvidence3
	objects[18]=BoneEvidence4
	objects[19]=BoneEvidence5
}
*/
