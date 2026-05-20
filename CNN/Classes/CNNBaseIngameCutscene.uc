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

// Cached at FirstFrame. Used by TrySendPlayerOnceToGame to detect when
// the IP chain has carried the player out of the default PlayerStart's
// radius — see that function for the engine-level reasoning.
var vector unsafeStartLoc;
var bool unsafeStartCached;

// Opt-in: defer SendPlayer until the IP chain moves the player out of
// the default PlayerStart's radius. Only needed when the PlayerStart
// is inside a damage zone (MoonIntro's meteor explosion). Docks and
// other cutscenes have safe PlayerStarts, so deferring there just
// strands the player invincible at a position the URL #tag never
// reaches. Default false; Chapter05 opts in.
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
    // Fresh New Game: TantalusDenton.ShowIntro sets bStartNewGameAfterIntro
    // before SendPlayer; PlayerPawn declares it as `var travel`, so it
    // survives the URL travel to this map. Without this branch, the .dxs
    // saved at the end of the previous playthrough's cutscene keeps
    // convNamePlayed=true and the intro is skipped on every subsequent
    // New Game — player spawns at the explosion zone with no cutscene.
    // Consume the flag so the cutscene's own SendPlayer (post-ESC URL
    // travel) doesn't re-trigger this branch.
    if (player != none && player.bStartNewGameAfterIntro)
    {
        flags.SetBool(convNamePlayed, false);
        flags.SetBool('CNNCutsceneCleanup', false);
        player.bStartNewGameAfterIntro = false;

        // Clear rail-mode state captured in .dxs from the previous
        // run. Vanilla DX1's New Game runs StartNewGame between intro
        // and gameplay (ResetPlayer + DeleteSaveGameFiles) which
        // implicitly clears this via different-map travel; CNN skips
        // that bridge so PHYS_Interpolating + Target=<IP> survives the
        // same-map travel. Without reset, the player loads still
        // walking the previous IP chain and StartConversationByName
        // never starts the new cutscene.
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

        // We're back on the post-cutscene mission instance — the
        // deferred-ESC invincibility gate has done its job. Clear it
        // so the player is mortal again. See TrySendPlayerOnceToGame.
        flags.SetBool('CNNCutsceneCleanup', false);

        // Defensive reset: SendPlayer already clears these before URL
        // travel, but console `open <map>` while already on the same
        // map bypasses that path and respawns at PlayerStart with the
        // .dxs rail state intact. Without this the camera interpolates
        // from the saved end-of-chain position back to PlayerStart on
        // every reopen.
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

function RestoreSoundVolume()
{
    if (flags.GetBool(convNamePlayed) && !IsArrivalCompleted)
    {
        //SoundVolume = savedSoundVolume;
        player.SetInstantSoundVolume(SoundVolume);
    }
}

// UE1's same-map URL travel (Level.Game.SendPlayer with #tag) writes a
// save at the current player.Location, reloads the map, and respawns
// the player at the default PlayerStart — IGNORING the URL #tag. On
// MoonIntro that drops the player back inside the meteor explosion
// zone and they die → L2. Workaround: when ESC fires early (player is
// still near the default PlayerStart), defer the URL travel. Set the
// CNNCutsceneCleanup flag to gate TantalusDenton.TakeDamage so the
// player survives the damage zone, and speed up the IP chain so they
// reach a safe save-position quickly. Once they're far enough away,
// SendPlayerOnce fires and UE1 honors #tag like it does for natural
// cutscene completion. See the table at the top of memory file
// project_moonintro_esc_pending.md for the position/routing matrix.
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
    // Picked empirically from the position/routing matrix: mid-cutscene
    // at ~1800 units from PlayerStart1 already gets #tag honored, so
    // 1024 leaves some margin. Smaller would risk firing too early;
    // larger delays UX without payoff.
    return VSize(player.Location - unsafeStartLoc) < 1024.0;
}

function AccelerateCutscene()
{
    local InterpolationPoint iPoint;

    // 8x cinematic playback. Without this, the deferred phase can last
    // many seconds while IPs creep along their original speed. The
    // dialog has already been aborted by ConWindowActive, so audio
    // pitch isn't a concern; only the camera path is still playing.
    foreach player.AllActors(class 'InterpolationPoint', iPoint)
    {
        iPoint.GameSpeedModifier = 8.0;
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
    local InterpolationPoint iPoint;

    // Reset the IP speed multiplier our defer-ESC accelerator pushed to
    // 8x. This is a non-destructive write because 1.0 IS the default —
    // .dxs will capture the default value and the cutscene replays from
    // a New Game at normal speed.
    //
    // Intentionally NOT touching CameraPoint.nextPoint here: that loop
    // (inherited from MissionScript) sets nextPoint=none on every CP to
    // halt the cinematic chain, but the modification is captured in the
    // same-map URL travel's .dxs and PERSISTS forever. On replay the
    // camera chain is broken (cutscene text plays, camera frozen at the
    // first CP). SendPlayer already resets player.ViewTarget=none which
    // detaches the camera; the chain itself doesn't need destroying.
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

    // Clear rail-mode fields too. ESC during a cutscene fires this
    // function while the player is still PHYS_Interpolating with
    // Target=<current IP>; without resetting, .dxs captures that state
    // and any subsequent same-map reload (URL #tag travel, console
    // `open`) restores it, causing the engine to interpolate the
    // camera/player back along the rails on entry.
    Player.bInterpolating = false;
    Player.Target = none;
    if (Player.Physics == PHYS_Interpolating)
        Player.SetPhysics(PHYS_Walking);

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
