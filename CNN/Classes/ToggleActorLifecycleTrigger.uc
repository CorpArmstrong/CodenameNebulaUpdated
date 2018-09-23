//=============================================================================
// ToggleActorLifecycleTrigger.
//=============================================================================
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
    super.PostBeginPlay();
}

function Trigger(Actor Other, Pawn Instigator)
{
    ToggleActorLifecycle();
    super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        ToggleActorLifecycle();
        super.Touch(Other);
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

        if (currentActor.IsA('Trigger'))
        {
            currentActor.Trigger(self, DeusExPlayer(GetPlayerPawn()));
        }

        bActorAlive = true;
    }
    else
    {
        CNNSimpleActorSpawner(currentActor).StopSpawning();
        bActorAlive = false;
    }
}

defaultproperties
{
    actorType=CNN.AvatarGenerator
    spawnPointTag=AvatarPoint_1
}
