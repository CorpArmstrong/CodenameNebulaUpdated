//-----------------------------------------------------------
// CNNEventTimer.
//-----------------------------------------------------------
class CNNEventTimer extends Keypoint;

var(CNNEventTimerArgs) name timerEventTag;
var(CNNEventTimerArgs) string timerStarted;
var(CNNEventTimerArgs) string timerStopped;

var() bool bCountDown;          // count down?
var() float startTime;          // what time do we start from?
var() float criticalTime;       // when does the text turn red?
var() float destroyDelay;       // after timer has expired, how long until we destroy the window
var() string message;           // message to print on timer window
var transient TimerDisplay timerWin;   // never saved; remade after a load
var bool bRunning;
var float time;
var bool bDone;

var Dispatcher disp;

//
// Count up or down depending on what the settings are
//
event Tick(float deltaTime)
{
    if (bRunning && (timerWin == none))
        RestoreWindow();

    if (timerWin != none)
    {
        if (!bDone && timerWin.time == 0)
        {
            StopTimer();
            TimerEvent();
        }

        if (bDone)
        {
            timerWin.bFlash = true;
            return;
        }

        if (bCountDown)
        {
            time -= deltaTime;

            if (time < 0)
            {
                time = 0;
            }

            if (time <= criticalTime)
            {
                timerWin.bCritical = true;
            }
        }
        else
        {
            time += deltaTime;

            if (time >= criticalTime)
            {
                timerWin.bCritical = true;
            }
        }

        timerWin.time = time;
    }
}

//
// destroy the window
//
function Timer()
{
    // a destroyed window must not stay referenced
    if (timerWin != none)
    {
        timerWin.Destroy();
        timerWin = none;
    }
}

//
// Start or stop the timer
//
function Trigger(Actor Other, Pawn EventInstigator)
{
    local DeusExPlayer player;

    FindAndSetDispatcher();
    player = DeusExPlayer(EventInstigator);

    if (player == none)
    {
        return;
    }

    super.Trigger(Other, EventInstigator);

    if (timerWin == none)
    {
        if (bCountDown)
        {
            time = startTime;
        }
        else
        {
            time = 0;
        }

        // the HUD has one timer slot; take over the MJ12 countdown's window
        timerWin = DeusExRootWindow(player.rootWindow).hud.timer;
        if (timerWin == none)
            timerWin = class'CNNTimerDisplay'.static.CreateIn(DeusExRootWindow(player.rootWindow).hud);
        if (timerWin == none)
            return;
        timerWin.bFlash = false;
        timerWin.time = time;
        timerWin.bCritical = False;
        timerWin.message = message;
        bDone = False;
        bRunning = true;
        PlaySound(sound'Beep3', SLOT_Misc);
        player.ClientMessage(timerStarted);
    }
    else if (!bDone && (timerWin != none))
    {
        bDone = true;
        SetTimer(destroyDelay, false);
        PlaySound(sound'Beep3', SLOT_Misc);
        player.ClientMessage(timerStopped);
    }
}

//
// bring the window back after a load
//
function RestoreWindow()
{
    local DeusExPlayer player;
    local DeusExRootWindow root;

    player = DeusExPlayer(GetPlayerPawn());
    if (player == none)
        return;
    root = DeusExRootWindow(player.rootWindow);
    if ((root == none) || (root.hud == none))
        return;

    timerWin = root.hud.timer;
    if (timerWin == none)
        timerWin = class'CNNTimerDisplay'.static.CreateIn(root.hud);
    if (timerWin == none)
        return;
    timerWin.bFlash = false;
    timerWin.time = time;
    timerWin.bCritical = (bCountDown && (time <= criticalTime));
    timerWin.message = message;
    if (disp == none)
        FindAndSetDispatcher();
}

function FindAndSetDispatcher()
{
    local Dispatcher dp;

    foreach AllActors(class'Dispatcher', dp, timerEventTag)
    {
        disp = dp;
    }
}

function StopTimer()
{
    timerWin.bFlash = true;
    bDone = true;
    bRunning = false;
    SetTimer(destroyDelay, false);
    PlaySound(sound'Beep3', SLOT_Misc);
    BroadcastMessage(timerStopped);
}

function TimerEvent()
{
    local DeusExPlayer player;

    // the mission script ends the level on this
    player = DeusExPlayer(GetPlayerPawn());
    if ((player != none) && (player.FlagBase != none))
        player.FlagBase.SetBool('TimerExpired', true);

    if (disp != none)
        disp.Trigger(self, player);
}

defaultproperties
{
    timerEventTag=LabEndingSuccessDispatcher
    timerStarted="Survive!"
    timerStopped="You've survived!"
    bCountDown=true
    StartTime=60.000000
    criticalTime=10.000000
    destroyDelay=5.000000
    Message="Countdown"
    bStatic=false
}
