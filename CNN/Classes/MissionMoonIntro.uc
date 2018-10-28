//=============================================================================
// MissionMoonIntro.
//=============================================================================
class MissionMoonIntro extends MissionScript;

var byte savedSoundVolume;
var bool isIntroCompleted;
var bool PlayerGotMuscleAug;
var bool HasMuscleAug;
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
    super.InitStateMachine();
    CheckIntroFlags();
}

// ----------------------------------------------------------------------
// FirstFrame()
//
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
    super.FirstFrame();
}

// ----------------------------------------------------------------------
// PreTravel()
//
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
    super.PreTravel();
    RestoreSoundVolume();
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
    super.Timer();
    GivePlayerHisAugs();
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

function GivePlayerHisAugs()
{
    if (flags.GetBool('HasMuscleAug') && !flags.GetBool('PlayerGotMuscleAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugMuscle');
        flags.SetBool('PlayerGotMuscleAug', true, true, 0);
    }

    if (flags.GetBool('HasCombatAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugCombat');
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

            if (actorToSpeak != none)
            {
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
        if (DeusExRootWindow(player.rootWindow) != none)
        {
            DeusExRootWindow(player.rootWindow).ClearWindowStack();
        }

        Level.Game.SendPlayer(player, sendToLocation);
    }
}

defaultproperties
{
    sendToLocation="05_MoonIntro#TwoMonthsLater"
    conversationName=InExile
    actorTag=Magdalene
    CutsceneEndFlagName=IsIntroPlayed
}
