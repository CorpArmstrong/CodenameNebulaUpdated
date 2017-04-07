class EventCommandTurnOnTriggerLight extends EventCommand;

var TriggerLight triggerLightActor;
var name triggerLightTag;

function ExecuteEvent()
{
    foreach AllActors(class 'TriggerLight', triggerLightActor, triggerLightTag)
    {
        triggerLightActor.Trigger(none, none);
    }
}

defaultproperties
{
    triggerLightTag=DocksTriggerLight
}