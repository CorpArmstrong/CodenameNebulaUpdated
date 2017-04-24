//-----------------------------------------------------------------------
// CNNBaseIngameCutscene
// by CorpArmstrong
//-----------------------------------------------------------------------
class CNNBaseIngameCutscene expands MissionScript;

var byte savedSoundVolume;
var bool isIntroCompleted;
var String sendToLocation;
var Name conversationName;
var Name actorTag;
var Actor actorToSpeak;
var Name cutsceneEndFlagName;

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
    if (!flags.GetBool(cutsceneEndFlagName))
    {
        if (player != none)
        {
            DeusExRootWindow(player.rootWindow).ResetFlags();

            foreach AllActors(class'Actor', actorToSpeak, actorTag)
                break;

            if (actorToSpeak != none)
            {
                if(player.StartConversationByName(conversationName, actorToSpeak, false, true))
                {
					log("Starting conversation.");
				}
				else
				{
					log("Can't start conversation! Teleporting to start!");
					Level.Game.SendPlayer(player, sendToLocation);
				}
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
    if (flags.GetBool(cutsceneEndFlagName) && !isIntroCompleted)
    {
        SoundVolume = savedSoundVolume;
        player.SetInstantSoundVolume(SoundVolume);
    }
}

function SendPlayerOnceToGame()
{
    if (flags.GetBool(cutsceneEndFlagName) && !isIntroCompleted)
    {
        if (DeusExRootWindow(player.rootWindow) != none)
        {
            DeusExRootWindow(player.rootWindow).ClearWindowStack();
        }

        Level.Game.SendPlayer(player, sendToLocation);
    }
}

defaultproperties
{
    sendToLocation="50_OpheliaL1_WithIntro#Loc1"
    conversationName=OpheliaUICutscene
    actorTag=Secretary
    cutsceneEndFlagName=IsIntroPlayed
}
