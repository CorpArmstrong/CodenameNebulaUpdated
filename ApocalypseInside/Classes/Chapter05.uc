//=============================================================================
// Chapter05.
//=============================================================================
class Chapter05 expands MissionScript;

var byte savedSoundVolume;
var bool isIntroCompleted;
var String sendToLocation;
var Name conversationName;
var Name actorTag;
var Actor actorToSpeak;
var Name CutsceneEndFlagName;

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
}

// ----------------------------------------------------------------------

function CheckIntroFlags()
{
	if (flags.GetBool(CutsceneEndFlagName))
	{
		// After we've teleported back and map has reloaded
		// set the flag, to skip recursive intro call.
		isIntroCompleted = true;
	}

	if (!isIntroCompleted)
	{
	    // Set the PlayerTraveling flag (always want it set for
		// the intro and endgames)
		flags.SetBool('PlayerTraveling', true, true, 0);
	}
}

function StartConversationWithActor()
{
	if (!flags.GetBool(CutsceneEndFlagName))
	{
	   	if (player != none)
		{
			DeusExRootWindow(player.rootWindow).ResetFlags();

			foreach AllActors(class'Actor', actorToSpeak, actorTag)
				break;

			if (actorToSpeak != none) {
				player.StartConversationByName(conversationName, actorToSpeak, false, true);
			}

			// turn down the sound so we can hear the speech
			savedSoundVolume = SoundVolume;
			SoundVolume = 32;
			player.SetInstantSoundVolume(SoundVolume);
		}
	}
}

function RestoreSoundVolume()
{
	if (flags.GetBool(CutsceneEndFlagName) && !isIntroCompleted)
	{
		SoundVolume = savedSoundVolume;
		player.SetInstantSoundVolume(SoundVolume);
	}
}

function SendPlayerOnceToGame()
{
	if (flags.GetBool(CutsceneEndFlagName) && !isIntroCompleted)
	{
		if (DeusExRootWindow(player.rootWindow) != none) {
			DeusExRootWindow(player.rootWindow).ClearWindowStack();
		}
			Level.Game.SendPlayer(player, sendToLocation);
		
	}
	
}

defaultproperties
{
    missionName="Moon"
	sendToLocation="Moon_V1#TwoMonthsLater"
	conversationName=CutsceneMoon
	actorTag=Magdalene
	CutsceneEndFlagName=IsIntroPlayed
}