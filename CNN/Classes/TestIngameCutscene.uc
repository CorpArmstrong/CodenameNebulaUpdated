//-----------------------------------------------------------------------
// CNNBaseIngameCutscene
// by CorpArmstrong
//-----------------------------------------------------------------------
class TestIngameCutscene expands MissionScript;

var byte savedSoundVolume;
var bool isIntroCompleted;
var String sendToLocation;
var Name conversationName;
var Name actorTag;
var Actor actorToSpeak;

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
	if (flags.GetBool('isIntroPlayed'))
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
	local ScriptedPawn pawn;

	if (!flags.GetBool('isIntroPlayed'))
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
	if (flags.GetBool('isIntroPlayed') && !isIntroCompleted)
	{
		SoundVolume = savedSoundVolume;
		player.SetInstantSoundVolume(SoundVolume);
	}
}

function SendPlayerOnceToGame()
{
	if (flags.GetBool('isIntroPlayed') && !isIntroCompleted)
	{
		if (DeusExRootWindow(player.rootWindow) != none) {
			DeusExRootWindow(player.rootWindow).ClearWindowStack();
		}

		Level.Game.SendPlayer(player, sendToLocation);
	}
}

defaultproperties
{
	sendToLocation="50_OpheliaL1_Burning_Cutscene#theline"
	conversationName=OpheliaUICutscene
	actorTag=Secretary
}
