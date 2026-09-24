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
//
// No BroadcastMessage here: the debug lines this used to send went to the
// HUD every single frame, and one still being sent while the level tore
// down its root window crashed the ending travel (ntdll access violation,
// found 2026-09-24 surviving the tube countdown).
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
