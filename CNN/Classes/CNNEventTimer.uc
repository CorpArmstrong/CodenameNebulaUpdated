class CNNEventTimer extends Keypoint;

var(CNNEventTimerArgs) name timerEventTag;
var(CNNEventTimerArgs) string timerStarted;
var(CNNEventTimerArgs) string timerStopped;

var() bool bCountDown;          // count down?
var() float startTime;          // what time do we start from?
var() float criticalTime;       // when does the text turn red?
var() float destroyDelay;       // after timer has expired, how long until we destroy the window
var() string message;           // message to print on timer window
var TimerDisplay timerWin;
var float time;
var bool bDone;

var Dispatcher disp;

//
// count up or down depending on what the settings are
//
event Tick(float deltaTime)
{
    if (timerWin != None)
    {
    	if (!bDone && timerWin.time == 0)
    	{
    		StopTimer();
    		TimerEvent();
		}

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

	FindAndSetDispatcher();

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
        player.ClientMessage(timerStarted);
    }
    else if (!bDone && (timerWin != None))
    {
        bDone = True;
        SetTimer(destroyDelay, False);
        PlaySound(sound'Beep3', SLOT_Misc);
        player.ClientMessage(timerStopped);
    }
}

function FindAndSetDispatcher()
{
    local Dispatcher dp;

    foreach AllActors(class'Dispatcher', dp, timerEventTag)
        disp = dp;

    BroadcastMessage("Dispatcher name: " $  disp.Name);
}

function StopTimer()
{
	timerWin.bFlash = True;
	bDone = True;
    SetTimer(destroyDelay, False);
    PlaySound(sound'Beep3', SLOT_Misc);
    BroadcastMessage(timerStopped);
}

function TimerEvent()
{
    BroadcastMessage("Inside TimerEvent!");

    if (disp != none)
    {
       	BroadcastMessage("Dispatcher is not null!");
	    disp.Trigger(self, DeusExPlayer(GetPlayerPawn()));
    }
}

defaultproperties
{
     timerEventTag=LabEndingSuccessDispatcher
     timerStarted="Survive!"
     timerStopped="You've survived!"
     bCountDown=True
     StartTime=60.000000
     criticalTime=10.000000
     destroyDelay=5.000000
     Message="Countdown"
     bStatic=False
}
