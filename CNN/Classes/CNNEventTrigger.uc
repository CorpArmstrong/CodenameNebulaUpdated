class CNNEventTrigger extends Trigger;

var(CodeEvent) class<EventCommand> codeEventClass;
var EventCommand ev;

function Trigger(Actor Other, Pawn Instigator)
{
	if (!IsActorSpawned())
	{
		Spawn(codeEventClass).ExecuteEvent();
	}
	else
	{
		ev.ExecuteEvent();
	}
}

function bool IsActorSpawned()
{
	local bool bEventActorFound;
    local Actor evs;

	foreach AllActors(codeEventClass, evs, /*Tag*/codeEventClass.default.eventCommandTag)
	{
		bEventActorFound = true;
		ev = EventCommand(evs);
		break;
	}

	return bEventActorFound;
}

defaultproperties
{
}
