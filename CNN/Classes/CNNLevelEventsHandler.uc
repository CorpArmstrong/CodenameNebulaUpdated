class CNNLevelEventsHandler extends Trigger;

function Trigger(Actor Other, Pawn Instigator)
{
    HandleEvent(Other);
    Super.Trigger(Other, Instigator);
}

function HandleEvent(Actor Other)
{
	local CNNTrigger trig;
	
	if (Other.IsA('CNNTrigger'))
	{
		trig = CNNTrigger(Other);
		
		if (trig.se.bSendEvent && trig.se.eventName != '')
		{
			gotostate(trig.se.eventName);
		}
	}
}

state TemplateState
{
	Begin:
	BroadcastMessage("H - from state!");
}

state SimpleState
{
	Begin:
	BroadcastMessage("From SimpleState!");
}