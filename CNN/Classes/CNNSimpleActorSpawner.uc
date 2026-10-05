//-----------------------------------------------------------
// CNNSimpleActorSpawner
//-----------------------------------------------------------
class CNNSimpleActorSpawner extends CNNTrigger;

var(SpawnData) class<ScriptedPawn> actorType;
var(SpawnData) name orderName;
var(SpawnData) name orderTag;
var(SpawnData) int spawnLimit;
var(SpawnData) float spawnRate;

var bool bSpawning;
var int spawnCounter;
var float nextSpawn;

var float internalCounter;

function Trigger(Actor Other, Pawn Instigator)
{
    bSpawning = !bSpawning;
    super.Trigger(Other, Instigator);
}

function StopSpawning()
{
    bSpawning = false;
}

// ============================================================================
// Tick
// ============================================================================

simulated function Tick(float TimeDelta)
{
    local ScriptedPawn spawned;

    super.Tick(TimeDelta);

    if (bSpawning && spawnCounter < spawnLimit)
    {
        internalCounter += TimeDelta;

        if (internalCounter > nextSpawn)
        {
            nextSpawn = internalCounter + spawnRate;
            spawned = Spawn(actorType, self);
            if (spawned != none)
                spawned.SetOrders(orderName, orderTag);
            spawnCounter++;
        }
    }
}

defaultproperties
{
    actorType=CNN.Avatar
    spawnRate=3.0
    orderName=RunningTo
    spawnLimit=50
}
