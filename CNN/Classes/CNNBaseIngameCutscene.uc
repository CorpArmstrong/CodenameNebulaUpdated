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

var vector unsafeStartLoc;      // the default PlayerStart, see TrySendPlayerOnceToGame
var bool unsafeStartCached;

// Hold the send-off until the camera path has carried the player away from
// the default PlayerStart. Only for maps whose PlayerStart is in a damage
// zone (MoonIntro); Chapter05 sets it.
var bool bDeferOnEarlyEsc;

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
    CacheUnsafeStart();
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

    // a send-off travels, and PreTravel() clears flags
    if (flags != none)
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
    // A new game replays the intro even though the map, saved at the end of
    // the last one, says it was played.
    if (player != none && player.bStartNewGameAfterIntro)
    {
        flags.SetBool(convNamePlayed, false);
        flags.SetBool('CNNCutsceneCleanup', false);
        player.bStartNewGameAfterIntro = false;

        // the saved map still has the player on the camera rails
        player.bInterpolating = false;
        player.Target = none;
        if (player.Physics == PHYS_Interpolating)
            player.SetPhysics(PHYS_Walking);
    }

    if (flags.GetBool(convNamePlayed))
    {
        // After we've teleported back and map has reloaded
        // set the flag, to skip recursive intro call.
        IsArrivalCompleted = true;

        // Make sure player is not hidden after interpolation state.
        player.bHidden = false;

        // the player is mortal again (see TrySendPlayerOnceToGame)
        flags.SetBool('CNNCutsceneCleanup', false);

        // reopening the same map with console `open` keeps the rail state
        player.bInterpolating = false;
        player.Target = none;
        if (player.Physics == PHYS_Interpolating)
            player.SetPhysics(PHYS_Walking);
        player.ViewTarget = none;
        player.bBehindView = false;
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

// Called after Super.PreTravel(), which clears flags.
function RestoreSoundVolume()
{
    if ((flags != none) && flags.GetBool(convNamePlayed) && !IsArrivalCompleted)
    {
        //SoundVolume = savedSoundVolume;
        player.SetInstantSoundVolume(SoundVolume);
    }
}

// Travel to the same map ignores the #tag and respawns the player at the
// default PlayerStart -- on MoonIntro, inside the meteor blast. So when the
// cutscene is skipped early, the send-off waits until the camera path has
// carried the player clear, sped up, with the player kept alive meanwhile
// (CNNCutsceneCleanup, see TantalusDenton.TakeDamage).
function TrySendPlayerOnceToGame()
{
    if (flags.GetBool(convNamePlayed) && !isArrivalCompleted)
    {
        if (bDeferOnEarlyEsc && IsPlayerNearUnsafeStart())
        {
            flags.SetBool('CNNCutsceneCleanup', true);
            AccelerateCutscene();
            return;
        }
        SendPlayerOnce();
    }
}

function CacheUnsafeStart()
{
    local PlayerStart ps;
    local PlayerStart best;

    foreach AllActors(class'PlayerStart', ps)
    {
        if (ps.bSinglePlayerStart)
        {
            best = ps;
            break;
        }
        if (best == none)
            best = ps;
    }

    if (best != none)
    {
        unsafeStartLoc = best.Location;
        unsafeStartCached = true;
    }
}

function bool IsPlayerNearUnsafeStart()
{
    if (player == none || !unsafeStartCached)
        return false;
    // the #tag is honoured from about 1800 units away
    return VSize(player.Location - unsafeStartLoc) < 1024.0;
}

function AccelerateCutscene()
{
    local InterpolationPoint iPoint;

    // the dialogue is already gone; only the camera path still runs
    foreach player.AllActors(class 'InterpolationPoint', iPoint)
    {
        iPoint.GameSpeedModifier = 8.0;
    }
}

// Ends the cutscene once, whoever notices the skip first: the Timer,
// TantalusDenton.EndConversation or TantalusDenton.ShowMainMenu.
function SendPlayerOnce()
{
    if (bSendPlayerFired || IsArrivalCompleted)
        return;
    // the player can be missing for a moment after the reload
    if (player == none || flags == none)
        return;
    bSendPlayerFired = true;

    // no expiration, or the reloaded map would replay the cutscene
    flags.SetBool(convNamePlayed, true);
    FinishCinematic();
    SendPlayer();
}

// ----------------------------------------------------------------------
// FinishCinematic()
// ----------------------------------------------------------------------

function FinishCinematic()
{
    local InterpolationPoint iPoint;

    // The camera chain is left whole: the map is saved on the way out,
    // and a broken chain would stay broken.

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

    // Travel to the same map keeps camera and rail state, so clear it.
    Player.ViewTarget = none;
    Player.bBehindView = false;

    Player.bInterpolating = false;
    Player.Target = none;
    if (Player.Physics == PHYS_Interpolating)
        Player.SetPhysics(PHYS_Walking);

    Level.Game.SendPlayer(player, sendToLocation);
}

defaultproperties
{
    // a skipped cutscene is noticed within 50ms
    checkTime=0.050000
}
