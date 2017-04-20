//=============================================================================
// Chapter05.
//=============================================================================
class Chapter05 expands CNNBaseIngameCutscene;

var byte savedSoundVolume;
var bool isIntroCompleted;
var bool PlayerGotMuscleAug;
var bool HasMuscleAug;
var bool hasCombatAug;
var String sendToLocation;
var Name conversationName;
var Name actorTag;
var Actor actorToSpeak;
var Name CutsceneEndFlagName;

// ----------------------------------------------------------------------
// FirstFrame()
//
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
    Super.FirstFrame();
    //StartConversationWithActor(); Intro will start in first person mode and the convo will be interactive.
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
    Super.Timer();
    GivePlayerHisAugs();
}

// ----------------------------------------------------------------------

function GivePlayerHisAugs()
{
    if(flags.GetBool('HasMuscleAug') && !flags.GetBool('PlayerGotMuscleAug'))
	{
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugMuscle');
        flags.SetBool('PlayerGotMuscleAug', true, true, 0);
    }
    if(flags.GetBool('HasCombatAug') && !flags.GetBool('PlayerGotCombatAug'))
    {
    	Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugCombat');
		flags.SetBool('PlayerGotCombatAug', true, true, 0);
	}
}

defaultproperties
{
    missionName="Moon"
    sendToLocation="05_MoonIntro#TwoMonthsLater"
    conversationName=InExile
    actorTag=Magdalene
    CutsceneEndFlagName=IsIntroPlayed
}