//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CNNTrigger expands Trigger;

struct SEvent
{
	var() bool bSendEvent;
	var() name eventName;
};

var() SEvent se;

function Trigger(Actor Other, Pawn EventInstigator)
{
	super.Trigger(Other, EventInstigator);
	
	if (se.bSendEvent && se.eventName != '')
	{
	
	}
}

function FindLevelEventsHandler()
{
//
}

function MsgBox ( string message )
{
    local DeusExPlayer player;
    player = DeusExPlayer(GetPlayerPawn());
    player.clientMessage( message );
}

defaultproperties
{
     Texture=Texture'CNN.S_CNNTrig'
}
