//-----------------------------------------------------------------------
// Class:    CNNBaseIngameCutscene
// Author:   CorpArmstrong
//-----------------------------------------------------------------------

class CNNBaseIngameCutscene expands MissionScript abstract;

var byte savedSoundVolume;
var bool IsArrivalCompleted;
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
    SendPlayerOnceToGame();
    DoLevelStuff();
}

// ----------------------------------------------------------------------

function DoLevelStuff() {} // Write level-specific logic here.

function CheckIntroFlags()
{
    if (flags.GetBool(convNamePlayed))
    {
        // After we've teleported back and map has reloaded
        // set the flag, to skip recursive intro call.
        IsArrivalCompleted = true;
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

            foreach AllActors(class'Actor', actorToSpeak, actorTag)
                break;

            if (actorToSpeak != none)
            {
                player.StartConversationByName(conversationName, actorToSpeak, false, true);
                TurnDownSoundVolume();
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
        SoundVolume = savedSoundVolume;
        player.SetInstantSoundVolume(SoundVolume);
    }
}

function SendPlayerOnceToGame()
{
    if (flags.GetBool(convNamePlayed) && !isArrivalCompleted)
    {
        if (DeusExRootWindow(player.rootWindow) != none)
        {
            DeusExRootWindow(player.rootWindow).ClearWindowStack();
        }

		Player.Invisible(false);

        /*
		if (player.IsInState('Interpolating'))
        {
            Log("Camera interpolation path is longer than conversation!");
            Log("Terminating interpolation!");
            BroadcastMessage("Terminating interpolation!");
            SetPhysics(PHYS_Walking);
            player.GoToState('PlayerWalking');
            Level.Game.SendPlayer(player, "Mutiny");
        }*/

        Level.Game.SendPlayer(player, sendToLocation);
    }
}

