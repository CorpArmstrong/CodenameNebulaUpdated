class EventCommandTurnOffGravity extends EventCommand;

var ZoneInfo zoneInfo;
var name zoneInfoTag;
var name physicsActorTag;
var bool isApplied;

function ExecuteEvent()
{
    local ZoneInfo zInfo;
    local Actor physicsActor;

	Log("Fucking string shitlog");

    foreach AllActors(class 'ZoneInfo', zInfo, zoneInfoTag)
    {
        zoneInfo = zInfo;
        break;
    }

    foreach AllActors(class 'Actor', physicsActor, physicsActorTag)
    {
        physicsActor.SetPhysics(PHYS_Falling);
    }

    // Just for the test:
    isApplied = false;

    if (isApplied)
    {
        zoneInfo.ZoneGravity = vect(0, 0, -850);
    }
    else
    {
        zoneInfo.ZoneGravity = vect(0, 0, -1);
    }
}

DefaultProperties
{
    zoneInfoTag=ZoneInfoSimulatedGravity
    physicsActorTag=SimulatedPhysics
}
