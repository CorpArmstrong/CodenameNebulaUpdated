class EventCommandToggleGravity extends EventCommand;

var ZoneInfo gravityZoneInfo;
var name zoneInfoTag;
var name physicsActorTag;
var bool isGravityApplied;

function ExecuteEvent()
{
    local ZoneInfo zInfo;
    local Actor physicsActor;

    isGravityApplied = !isGravityApplied;

    if (gravityZoneInfo == none)
    {
        foreach AllActors(class 'ZoneInfo', zInfo, zoneInfoTag)
        {
            gravityZoneInfo = zInfo;
            break;
        }
    }

    if (isGravityApplied)
    {
	    gravityZoneInfo.ZoneGravity = vect(0, 0, -850);

		foreach AllActors(class 'Actor', physicsActor, physicsActorTag)
    	{
            physicsActor.SetPhysics(PHYS_Falling);
    	}
    }
    else
    {
    	gravityZoneInfo.ZoneGravity = vect(0, 0, -1);

        foreach AllActors(class 'Actor', physicsActor, physicsActorTag)
    	{
            physicsActor.SetPhysics(PHYS_None);
    	}
    }
}

DefaultProperties
{
    zoneInfoTag=ZoneInfoSimulatedGravity
    physicsActorTag=SimulatedPhysics
	eventCommandTag=EC_ToggleGravity
}
