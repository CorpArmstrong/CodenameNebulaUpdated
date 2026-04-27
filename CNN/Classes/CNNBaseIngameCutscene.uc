//-----------------------------------------------------------------------
// Class:    CNNBaseIngameCutscene
// Author:   CorpArmstrong
//-----------------------------------------------------------------------
class CNNBaseIngameCutscene extends MissionScript abstract;

var byte savedSoundVolume;
var bool IsArrivalCompleted;
var bool bSendPlayerFired;
var string sendToLocation;
var name conversationName;
var name convNamePlayed;
var name actorTag;

// ----------------------------------------------------------------------
// InitStateMachine()
// ----------------------------------------------------------------------

function InitStateMachine()
{
    Super.InitStateMachine();
    CheckIntroFlags();
}

// ----------------------------------------------------------------------
// FirstFrame()
//
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
    Super.FirstFrame();
    StartConversationWithActor();
}

// ----------------------------------------------------------------------
// PreTravel()
//
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
    Super.PreTravel();
    RestoreSoundVolume();
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
    Super.Timer();
    TrySendPlayerOnceToGame();
    DoLevelStuff();
}

// ----------------------------------------------------------------------
// DoLevelStuff
//
// Write level-specific logic here.
// ----------------------------------------------------------------------

function DoLevelStuff()
{
}

function CheckIntroFlags()
{
    if (flags.GetBool(convNamePlayed))
    {
        // After we've teleported back and map has reloaded
        // set the flag, to skip recursive intro call.
        IsArrivalCompleted = true;

        // Make sure player is not hidden after interpolation state.
        player.bHidden = false;
    }

    if (!IsArrivalCompleted)
    {
        // Set the PlayerTraveling flag (always want it set for
        // the intro and endgames)
        flags.SetBool('PlayerTraveling', true, true, 0);
    }
}

function StartConversationWithActor()
{
    local Actor actorToSpeak;

    if (!flags.GetBool(convNamePlayed))
    {
        if (player != none)
        {
            DeusExRootWindow(player.rootWindow).ResetFlags();

            foreach AllActors(class 'Actor', actorToSpeak, actorTag)
            {
                break;
            }

            if (actorToSpeak != none)
            {
                player.StartConversationByName(conversationName, actorToSpeak, false, true);
                //TurnDownSoundVolume();
            }
            else
            {
                Log("Conversation actor not found! Teleporting to start!");
                flags.SetBool(convNamePlayed, true, true, 0);
            }
        }
    }
}

// Turn down the sound, so we can hear the speech
function TurnDownSoundVolume()
{
    savedSoundVolume = SoundVolume;
    SoundVolume = 32;
    player.SetInstantSoundVolume(SoundVolume);
}

function RestoreSoundVolume()
{
    if (flags.GetBool(convNamePlayed) && !IsArrivalCompleted)
    {
        //SoundVolume = savedSoundVolume;
        player.SetInstantSoundVolume(SoundVolume);
    }
}

function TrySendPlayerOnceToGame()
{
    if (flags.GetBool(convNamePlayed) && !isArrivalCompleted)
    {
        SendPlayerOnce();
    }
}

// Single, idempotent entry point for cutscene cleanup. Callers: the Timer
// (via TrySendPlayerOnceToGame), TantalusDenton.EndConversation (fires when
// ESC during a bForcePlay convo aborts the dialog), and TantalusDenton.
// ShowMainMenu (fires when ESC reaches the root window directly). The
// bSendPlayerFired guard prevents re-entry while the level travel is pending.
function SendPlayerOnce()
{
    if (bSendPlayerFired || IsArrivalCompleted)
        return;
    // player can be None briefly post-reload before InitStateMachine
    // populates it; FinishCinematic dereferences player.AllActors, so
    // bail until the next Timer tick rather than Accessed-None'ing.
    if (player == none || flags == none)
        return;
    bSendPlayerFired = true;

    // Permanent flag (no expiration). The earlier (true, 0) form set
    // bExpiringFlag=true with expiration=0, which DeleteExpiredFlags wipes
    // on the post-reload mission instance — making the cutscene restart
    // instead of staying ended.
    flags.SetBool(convNamePlayed, true);
    FinishCinematic();
    SendPlayer();
}

// ----------------------------------------------------------------------
// FinishCinematic()
// ----------------------------------------------------------------------

function FinishCinematic()
{
    local CameraPoint cPoint;
    local InterpolationPoint iPoint;

    // Loop through all the CameraPoints and set the "nextPoint"
    // to None will effectively cause them to halt.
    foreach player.AllActors(class 'CameraPoint', cPoint)
    {
        cPoint.nextPoint = none;
        //cPoint.Destroy();
    }

    // Loop through all the InterpolationPoints and set the "GameSpeedModifier"
    // to 1 so game time scale will be normal.
    foreach player.AllActors(class 'InterpolationPoint', iPoint)
    {
        iPoint.GameSpeedModifier = 1;
    }
}

function SendPlayer()
{
    if (DeusExRootWindow(player.rootWindow) != none)
    {
        DeusExRootWindow(player.rootWindow).ClearWindowStack();
    }

    Player.bHidden = false;
    Player.Visibility = Player.Default.Visibility;
    // DEUS_EX STM - added AI invisibility
    Player.bDetectable = true;

    // Reset camera state the cutscene hijacked. Without this, ViewTarget
    // stays pointing at a stale CameraPoint across the same-map #tag travel,
    // leaving the player with no visible model and the cinematic eye height.
    // Different-map travel resets this implicitly; #tag travel does not.
    Player.ViewTarget = none;
    Player.bBehindView = false;

    Level.Game.SendPlayer(player, sendToLocation);
}

defaultproperties
{
    // Faster than parent MissionScript's 1-second Timer. ESC during a
    // bForcePlay cutscene is eaten by ConWindowActive.AbortCinematicConvo,
    // which terminates the dialog (setting convNamePlayed) but doesn't
    // know about CNNBaseIngameCutscene. Polling at 50ms lets our Timer
    // pick up that flag and fire SendPlayerOnce within ~50ms — no
    // perceptible double-press required.
    checkTime=0.050000
}
