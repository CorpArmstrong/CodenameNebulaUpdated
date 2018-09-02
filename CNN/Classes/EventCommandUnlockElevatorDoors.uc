//=============================================================================
// EventCommandUnlockElevatorDoors.
//=============================================================================
class EventCommandUnlockElevatorDoors extends EventCommand;

var DeusExMover elevatorDoor;
var name elevatorDoorTag;

function ExecuteEvent()
{
    foreach AllActors(class 'DeusExMover', elevatorDoor, elevatorDoorTag)
    {
        elevatorDoor.bLocked = false;
    }
}

defaultproperties
{
    elevatorDoorTag=doors_docking
}
