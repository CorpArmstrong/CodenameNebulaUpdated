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
    Super.Trigger(Other, Instigator);
}

function StopSpawning()
{
    bSpawning = false;
    BroadcastMessage("Inside StopSpawning!");
}

// ============================================================================
// Tick
// ============================================================================

simulated function Tick(float TimeDelta)
{
	Super.Tick(TimeDelta);

	if (bSpawning && spawnCounter < spawnLimit)
	{
 		BroadcastMessage("InternalCounter: " $ internalCounter $ "; nextSpawn: " $ nextSpawn);
 		internalCounter += TimeDelta;

 		if (internalCounter > nextSpawn)
 		{
 			nextSpawn = internalCounter + spawnRate;
 			Spawn(actorType, self).SetOrders(orderName, orderTag);
 			spawnCounter++;
 			BroadcastMessage("Spawned actor! num: " $ spawnCounter);
 		}
 	}
 	else
 	{
 		BroadcastMessage("Don't spawn anymore!");
 	}
}

defaultproperties
{
    actorType=CNN.Avatar
    spawnRate=3.0
    orderName=RunningTo
    spawnLimit=50
}
