//-----------------------------------------------------------------------
// Class:    CNNAgentBridge
//-----------------------------------------------------------------------
//
// Polls CNN\System\CNNAgentCmd.txt once a second via the engine's own
// "exec <file>" console feature, so an external process can drive the
// player's existing CNNGoto/CNNFire/CNNWhere/CNNProbe/CNNTestEnding exec
// functions (see TantalusDenton.uc) without a human at the keyboard.
//
// Runs as its own Actor -- not folded into TantalusDenton's Timer() --
// because DeusExPlayer.Timer() (TantalusDenton's parent) already owns the
// single Timer slot on the player pawn for fire-damage-over-time; a
// second SetTimer() there would fight it. A separate Actor gets its own
// independent Timer for free.
//
// Started manually from the console with `CNNAgentStart` (see
// TantalusDenton.uc) -- this is a dev/test tool, not something every
// playthrough should spawn.
//-----------------------------------------------------------------------

class CNNAgentBridge extends Actor;

var() float pollInterval;
var TantalusDenton targetPlayer;

function PostBeginPlay()
{
    SetTimer(pollInterval, True);
    super.PostBeginPlay();
}

function SetTarget(TantalusDenton p)
{
    targetPlayer = p;
}

function Timer()
{
    if (targetPlayer == None)
        return;

    targetPlayer.ConsoleCommand("exec CNNAgentCmd.txt");

    // Drives CNNWaitFlag()'s poll-with-timeout primitive (2026-09-23) --
    // checked every tick regardless of whether a new command just arrived,
    // so a pending wait keeps progressing toward its deadline even on
    // ticks where CNNAgentCmd.txt hasn't changed. See TantalusDenton.uc.
    targetPlayer.CNNAgentCheckWait();
}

defaultproperties
{
    pollInterval=1.0
    bHidden=true
    RemoteRole=ROLE_None
}
