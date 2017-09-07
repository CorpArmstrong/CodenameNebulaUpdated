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

            foreach AllActors(class'Actor', actorToSpeak, actorTag)
                break;

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

function SendPlayerOnceToGame()
{
	if (flags.GetBool(convNamePlayed) && !isArrivalCompleted)
	{
		FinishCinematic();
		SendPlayer();
	}
}

// ----------------------------------------------------------------------
// FinishCinematic()
// ----------------------------------------------------------------------

function FinishCinematic()
{
	local CameraPoint cPoint;

	// Loop through all the CameraPoints and set the "nextPoint"
	// to None will will effectively cause them to halt.

	foreach player.AllActors(class'CameraPoint', cPoint)
	{
		cPoint.nextPoint = None;
		cPoint.Destroy();
	}
}

function SendPlayer()
{
	if (DeusExRootWindow(player.rootWindow) != none)
	{
		DeusExRootWindow(player.rootWindow).ClearWindowStack();
	}

	Player.Invisible(false);
	Level.Game.SendPlayer(player, sendToLocation);
}
