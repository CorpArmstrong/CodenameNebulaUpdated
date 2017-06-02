//=============================================================================
// CNNEventsDispatcher: works like a normal dispatcher, but it's more useful
// for calling external code, passed in classes array.
//=============================================================================
class CNNEventDispatcher extends Dispatcher;

var(CodeEvents) class<EventCommand> CodeEventClasses[8];
var(CodeEvents) float CodeEventDelays[8];
var EventCommand ev;
var int counter;

//
// Dispatch events.
//
state Dispatch
{
    Begin:
    disable('Trigger');
    for( i=0; i<ArrayCount(OutEvents); i++ )
    {
        if( OutEvents[i] != '' )
        {
            Sleep( OutDelays[i] );
            foreach AllActors( class 'Actor', Target, OutEvents[i] )
                Target.Trigger( Self, Instigator );
        }
    }
    enable('Trigger');

    // CorpArmstrong:
    gotostate('ProcessEvents');
}

state ProcessEvents
{
    Begin:
    for(counter = 0; counter < ArrayCount(CodeEventClasses); counter++)
    {
        if(CodeEventClasses[counter] != none)
        {
            Sleep(CodeEventDelays[counter]);
            InstantiateEventCommandWithCheck(CodeEventClasses[counter]);
        }
    }
}

function InstantiateEventCommandWithCheck(Class<EventCommand> codeEventClass)
{
    ev = GetCodeEvent(codeEventClass);

    if (ev == none)
    {
        ev = Spawn(codeEventClass);
    }

    ev.ExecuteEvent();
}

function EventCommand GetCodeEvent(Class<EventCommand> codeEventClass)
{
    local Actor evs;

    foreach AllActors(codeEventClass, evs)
        break;

    return EventCommand(evs);
}

defaultproperties
{
    CodeEventNames[0]=class'CNN.EventCommandToggleGravity'
}
