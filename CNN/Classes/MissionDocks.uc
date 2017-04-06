//-----------------------------------------------------------
// Mission Docks
//-----------------------------------------------------------
class MissionDocks extends MissionScript;

var ZoneInfo zoneInfo;
var name zoneInfoTag;
var name physicsActorTag;
var name physicsFlag;

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
}

function FirstFrame()
{
    local ZoneInfo zInfo;
    Super.FirstFrame();

    foreach AllActors(class 'ZoneInfo', zInfo, zoneInfoTag)
    {
        zoneInfo = zInfo;
        break;
    }

    flags.SetBool(physicsFlag, false);
}

function Timer()
{
    super.Timer();
    if(flags.GetBool(physicsFlag))
    {
        flags.SetBool(physicsFlag, false);
        SimulateGravity(true);
    }
}

function SimulateGravity(bool isApplied)
{
    local Actor physicsActor;

    foreach AllActors(class 'Actor', physicsActor, physicsActorTag)
    {
        physicsActor.SetPhysics(PHYS_Falling);
    }

    if (isApplied)
    {
        zoneInfo.ZoneGravity = vect(0, 0, -850);
    }
    else
    {
        zoneInfo.ZoneGravity = vect(0, 0, -1);
    }
}

function TestEvent()
{
    SimulateGravity(false);
}

DefaultProperties
{
    zoneInfoTag=ZoneInfoSimulatedGravity
    physicsActorTag=SimulatedPhysics
    physicsFlag=gravityApplied
}