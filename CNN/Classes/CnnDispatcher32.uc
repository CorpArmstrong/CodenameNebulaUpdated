//-----------------------------------------------------------
// CnnDispatcher copy. have a more calls and settings.
//-----------------------------------------------------------
class CnnDispatcher32 expands CNNSimpleTrigger;

// features:
// 1) call Trigger() by the PlayerPawn
// 2) can't react on collision
// 3) maybe include a some bugs :)
// 4) one new setting (WaitAfter or WaitBefore event)
// 5) eventName & eventWait was grouped into one struct
// 6) 32 Actions!!

struct SEventCall
{
	var() name eventName;
	var() float eventWait;
};

enum EWaitingMode
{
	EWM_WaitBefore,
	EWM_WaitAfter,
};


var(Dispatcher) SEventCall EventCalls[32];
var(Dispatcher) EWaitingMode WaitingMode;

//var (Dispatcher) name  OutEvents[32]; // Events to generate.
//var (Dispatcher) float OutDelays[32]; // Relative delays before generating events.
var int i;

function ActivatedON()
{
	bEnabled = false;      // prevent to triggering\touching
	gotostate('Dispatch');
}

function TouchIN()
{
	// Touches is dont works with dispatcher
}

function TouchOUT()
{
	// nothing
}

//
// Dispatch events.
//
state Dispatch
{
Begin:
	//disable('ActivatedON');
	disable('Trigger');

	switch (WaitingMode)
	{
		case EWM_WaitBefore:

			for( i=0; i<ArrayCount(EventCalls); i++ )
			{
				if( EventCalls[i].eventName != '' )
				{
					Sleep( EventCalls[i].eventWait );

					foreach AllActors( class 'Actor', Target, EventCalls[i].EventName )
						Target.Trigger( Self, GetPlayerPawn() );
				}
			}

			break;

		case EWM_WaitAfter:

			for( i=0; i<ArrayCount(EventCalls); i++ )
			{
				if( EventCalls[i].eventName != '' )
				{
					foreach AllActors( class 'Actor', Target, EventCalls[i].EventName )
						Target.Trigger( Self, GetPlayerPawn() );

					Sleep( EventCalls[i].eventWait );
				}
			}

			break;
	}

	enable('Trigger');
	super.ActivatedON(); // calls events, and restore bEnabled if it's needs
}


DefaultProperties
{

}
