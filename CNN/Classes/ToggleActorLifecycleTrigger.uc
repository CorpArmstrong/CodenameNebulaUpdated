class ToggleActorLifecycleTrigger extends CNNTrigger;

var() class<Actor> actorType;
var() name spawnPointTag;

var Actor spawnPoint;
var vector spawnLocation;
var rotator spawnRotation;
var bool bActorAlive;
var Actor currentActor;

function PostBeginPlay()
{
    SetSpawnPoint();
    Super.PostBeginPlay();
}

function Trigger(Actor Other, Pawn Instigator)
{
	ToggleActorLifecycle();
    Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        ToggleActorLifecycle();
        Super.Touch(Other);
    }
}

function SetSpawnPoint()
{
    local Actor spawnPoint;

    if (spawnPointTag != '')
    {
        foreach AllActors(class'Actor', spawnPoint, spawnPointTag)
        {
            spawnPoint = spawnPoint;
            break;
        }
    }

    if (spawnPoint != none)
    {
        spawnLocation = spawnPoint.Location;
        spawnRotation = spawnPoint.Rotation;
    }
    else
    {
        spawnLocation = self.Location;
        spawnRotation = self.Rotation;
    }
}

function ToggleActorLifecycle()
{
	if (!bActorAlive)
	{
		currentActor = Spawn(actorType,,, spawnLocation, spawnRotation);
		bActorAlive = true;
	}
	else
	{
		// currentActor.Destroy(); ???
		AvatarGenerator(currentActor).StopGenerator();
		bActorAlive = false;
	}
}

defaultproperties
{
	actorType=CNN.AvatarGenerator
	spawnPointTag=AvatarPoint_1
}
