class CNNSimpleActorSpawner extends CNNTrigger;

var(SpawnData) class<ScriptedPawn> actorType;
var(SpawnData) float spawnInterval;
var(SpawnData) name orderName;
var(SpawnData) name orderTag;

var int counter;
var bool bSpawning;
var ScriptedPawn sp;
var ScriptedPawn spawnee[10];

function PostBeginPlay()
{
    //
    Super.PostBeginPlay();
}

function Trigger(Actor Other, Pawn Instigator)
{
	if (!bSpawning) gotostate('SpawnActors');
    Super.Trigger(Other, Instigator);
}

// ============================================================================
// Tick
// ============================================================================

simulated function Tick(float TimeDelta)
{
	local int spawnIndex;
    Super.Tick(TimeDelta);

    if (bSpawning)
    {
        if (bNeedToSpawnActor(spawnIndex))
        {
            if (SpawnActor(sp, spawnIndex))
            {
                BroadcastMessage("Spawned actor: " $ sp.Name);
            }
        }
    }
}

function StopSpawning()
{
	bSpawning = false;
}

state SpawnActors
{
    Begin:
    for (counter = 0; counter < ArrayCount(spawnee); counter++)
    {
        if (SpawnActor(sp, counter))
        {
            Sleep(spawnInterval);
        }
    }
    bSpawning = true;
}

function bool SpawnActor(out ScriptedPawn _actor, int arrayIndex)
{
    local bool result;
    _actor = Spawn(actorType);

    if (_actor != none)
    {
        result = true;
        _actor.SetOrders(orderName, orderTag);
        spawnee[arrayIndex] = _actor;
    }

    return result;
}

function bool bNeedToSpawnActor(out int index)
{
    local bool result;
    local int ii;

    for (ii = 0; ii < ArrayCount(spawnee); ii++)
    {
        if (spawnee[ii] == none)
        {
            index = ii;
            BroadcastMessage("Spawned at index: " $ ii);
            result = true;
            break;
        }
    }

    return result;
}

defaultproperties
{
    actorType=CNN.Avatar
    spawnInterval=3.0
    orderName=RunningTo
}
