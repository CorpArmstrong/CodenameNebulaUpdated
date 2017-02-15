//=============================================================================
// burdenTimer.
//
// burden enhancements: 
//   - this timer triggers its Event when its time expires
//   - allows custom start, stop and expire messages
//=============================================================================
class burdenTimer expands Keypoint;

var() bool bCountDown;			// count down?
var() float startTime;			// what time do we start from?
var() float criticalTime;		// when does the text turn red?
var() float destroyDelay;		// after timer has expired, how long until we destroy the window
var() string message;			// message to print on timer window
var TimerDisplay timerWin;
var float time;
var bool bDone;

//------------------------------------------------------------------------
// - added for burden
//------------------------------------------------------------------------
var bool bExpired;			// has the timer expired?
var() string strStartMessage;		// client message when the timer starts
var() string strStopMessage;		// client message when the timer stops
var() string strExpiredMessage;		// client message when the timer expires

//
// count up or down depending on what the settings are
//
event Tick(float deltaTime)
{
	if (timerWin != None)
	{
		if (bDone)
		{
			timerWin.bFlash = True;
			return;
		}

		if (bCountDown)
		{
			time -= deltaTime;
			if (time < 0)
				time = 0;

			if (time <= criticalTime)
				timerWin.bCritical = True;
		}
		else
		{
			time += deltaTime;

			if (time >= criticalTime)
				timerWin.bCritical = True;
		}

		timerWin.time = time;

		//------------------------------------------------------------------------
		// - added for burden:
		// - once the timer expires, activate the Expired() function one time
		//------------------------------------------------------------------------

		if (time <= 0.0 && (!bExpired))
		{
			Expired();
			bExpired = True;
		}

	}
}

//
// destroy the window
//
function Timer()
{
	timerWin.Destroy();
}

//
// start or stop the timer
//
function Trigger(Actor Other, Pawn EventInstigator)
{
	local DeusExPlayer player;

	player = DeusExPlayer(EventInstigator);

	if (player == None)
		return;

	Super.Trigger(Other, EventInstigator);
	
	if (timerWin == None)
	{
		if (bCountDown)
			time = startTime;
		else
			time = 0;

		timerWin = DeusExRootWindow(player.rootWindow).hud.CreateTimerWindow();
		timerWin.time = time;
		timerWin.bCritical = False;
		timerWin.message = message;
		bDone = False;
		PlaySound(sound'Beep3', SLOT_Misc);
		player.ClientMessage(strStartMessage);
	}
	else if (!bDone && (timerWin != None))
	{
		bDone = True;
		SetTimer(destroyDelay, False);
		PlaySound(sound'Beep3', SLOT_Misc);
		player.ClientMessage(strStopMessage);
	}
}

//------------------------------------------------------------------------
// - added for burden:
// - trigger the Event and play the expired message
//------------------------------------------------------------------------
function Expired()
{
	local DeusExPlayer player;
	local Actor A;

	player = DeusExPlayer(GetPlayerPawn());

	// log( "--> function Expired now activated...");

	if (player != None)
	{
		foreach AllActors(class 'Actor', A, Event)
			A.Trigger(Self, Player);

		player.ClientMessage(strExpiredMessage);
	}
	else
	{
		log( "--> burdenTimer: player is None...");
	}	
}

defaultproperties
{
    bCountDown=True
    StartTime=60.00
    criticalTime=10.00
    destroyDelay=5.00
    Message="Countdown"
    strStartMessage="Timer Started"
    strStopMessage="Timer Stopped"
    strExpiredMessage="Timer Expired"
    bStatic=False
}
