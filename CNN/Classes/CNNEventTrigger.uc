class CNNEventTrigger extends Trigger;

var(CodeEvent) class<EventCommand> codeEventClass;
var EventCommand ev;
var bool codeEventSpawned;

function Trigger(Actor Other, Pawn Instigator)
{
    if (!codeEventSpawned)
    {
       ev = GetCodeEvent();

       if (ev == none)
       {
          ev = Spawn(codeEventClass);
       }

       codeEventSpawned = true;
    }

    ev.ExecuteEvent();
}

function EventCommand GetCodeEvent()
{
    local Actor evs;

	foreach AllActors(codeEventClass, evs)
		break;

	return EventCommand(evs);
}

defaultproperties
{
}
