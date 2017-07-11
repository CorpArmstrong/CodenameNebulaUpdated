//=============================================================================
// Chapter05.
//=============================================================================
class Chapter05 expands MissionScript;

var byte savedSoundVolume;
var bool isIntroCompleted;
var bool PlayerGotMuscleAug;
var bool HasMuscleAug;
var bool hasCombatAug;
var bool HasLethalAug;
var bool hasNonLethalAug;
var bool HasAquaAug;
var bool HasPowerAug;
var bool HasHeartAug;
var bool HasSpeedAug;
var bool HasStealthAug;
var bool HasCloakAug;
var bool HasRadarAug;
var bool HasRegenAug;
var bool HasEnergyAug;
var bool HasSpyAug;
var bool HasBallisticAug;
var bool HasDefenseAug;
var bool HasEMPAug;
var bool HasEnviroAug;
var bool HasTargetAug;
var bool HasVisionAug;
var String sendToLocation;
var Name conversationName;
var Name actorTag;
var Actor actorToSpeak;
var Name cutsceneEndFlagName;
var(ChangeLevelOnDeath) string levelName;

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
    //RestoreSoundVolume();
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local ScriptedPawn Uber;
	local ScriptedPawn Magdalene;
	local Ship1 ship;
	local ScriptedPawn MagdaleneInSpacesuit;
    Super.Timer();
    SendPlayerOnceToGame();
	GivePlayerHisAugs();
	if (player.IsInState('Dying'))
	{
		Level.Game.SendPlayer(player, levelName);
	}
	if(flags.GetBool('ReadyToLeaveMoon'))
	{
		foreach allactors(class'ScriptedPawn',Uber,'UberAlles')
		Uber.EnterWorld();
		foreach allactors(class'ScriptedPawn',Magdalene,'MagdaleneDenton')
		MagdaleneInSpacesuit.LeaveWorld();
	}
	if(flags.GetBool('WalkOnMoon'))
	{
		foreach allactors(class'ScriptedPawn',MagdaleneInSpacesuit,'MagdaleneSpacesuit')
		MagdaleneInSpacesuit.EnterWorld();
	}	
	if(flags.GetBool('SpacecraftLanded'))
	{
		foreach allactors(class'Ship1',ship,'Spacecraft')
		ship.EnterWorld();
	}		
		
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
            else
            {
            	isIntroCompleted = true;
            	flags.SetBool(cutsceneEndFlagName, true, true, 0);
            	Level.Game.SendPlayer(player, sendToLocation);
			}

            // turn down the sound so we can hear the speech
            /*savedSoundVolume = SoundVolume;
            SoundVolume = 32;
            player.SetInstantSoundVolume(SoundVolume);*/
        }
    }
}
/*
function RestoreSoundVolume()
{
    if (flags.GetBool(cutsceneEndFlagName) && !isIntroCompleted)
    {
        SoundVolume = savedSoundVolume;
        player.SetInstantSoundVolume(SoundVolume);
    }
}*/

function SendPlayerOnceToGame()
{
    if (flags.GetBool(cutsceneEndFlagName) && !isIntroCompleted)
    {
        if (DeusExRootWindow(player.rootWindow) != none)
        {
            DeusExRootWindow(player.rootWindow).ClearWindowStack();
        }
		
		Player.bHidden = False;
        Level.Game.SendPlayer(player, sendToLocation);
    }
}


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
	if(flags.GetBool('HasAquaAug') && !flags.GetBool('PlayerGotAquaAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugAqualung');
        flags.SetBool('PlayerGotAquaAug', true, true, 0);
    }
	if(flags.GetBool('HasPowerAug') && !flags.GetBool('PlayerGotPowerAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugPower');
        flags.SetBool('PlayerGotPowerAug', true, true, 0);
    }
	if(flags.GetBool('HasHeartAug') && !flags.GetBool('PlayerGotHeartAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugHeartLung');
        flags.SetBool('PlayerGotHeartAug', true, true, 0);
    }
	if(flags.GetBool('HasSpeedAug') && !flags.GetBool('PlayerGotSpeedAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugSpeed');
        flags.SetBool('PlayerGotSpeedAug', true, true, 0);
    }
	if(flags.GetBool('HasStealthAug') && !flags.GetBool('PlayerGotStealthAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugStealth');
        flags.SetBool('PlayerGotStealthAug', true, true, 0);
    }
	if(flags.GetBool('HasBallisticAug') && !flags.GetBool('PlayerGotBallisticAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugBallistic');
        flags.SetBool('PlayerGotBallisticAug', true, true, 0);
    }
	if(flags.GetBool('HasCloakAug') && !flags.GetBool('PlayerGotCloakAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugCloak');
        flags.SetBool('PlayerGotCloakAug', true, true, 0);
    }
	if(flags.GetBool('HasDefenseAug') && !flags.GetBool('PlayerGotDefenseAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugDefense');
        flags.SetBool('PlayerGotDefenseAug', true, true, 0);
    }
	if(flags.GetBool('HasEMPAug') && !flags.GetBool('PlayerGotEMPAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugEMP');
        flags.SetBool('PlayerGotEMPAug', true, true, 0);
    }
	if(flags.GetBool('HasEnergyAug') && !flags.GetBool('PlayerGotEnergyAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugShield');
        flags.SetBool('PlayerGotEnergyAug', true, true, 0);
    }
	if(flags.GetBool('HasEnviroAug') && !flags.GetBool('PlayerGotEnviroAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugEnviro');
        flags.SetBool('PlayerGotEnviroAug', true, true, 0);
    }
	if(flags.GetBool('HasHeartAug') && !flags.GetBool('PlayerGotHeartAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugHeartLung');
        flags.SetBool('PlayerGotHeartAug', true, true, 0);
    }
	if(flags.GetBool('HasRadarAug') && !flags.GetBool('PlayerGotRadarAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugRadarTrans');
        flags.SetBool('PlayerGotRadarAug', true, true, 0);
    }
	if(flags.GetBool('HasRegenAug') && !flags.GetBool('PlayerGotRegenAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugHealing');
        flags.SetBool('PlayerGotRegenAug', true, true, 0);
    }
	if(flags.GetBool('HasSpyAug') && !flags.GetBool('PlayerGotSpyAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugDrone');
        flags.SetBool('PlayerGotSpyAug', true, true, 0);
    }
	if(flags.GetBool('HasTargetAug') && !flags.GetBool('PlayerGotTargetAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugTarget');
        flags.SetBool('PlayerGotTargetAug', true, true, 0);
    }
	if(flags.GetBool('HasLethalAug') && !flags.GetBool('PlayerGotLethalAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugSkullGunLethal');
        flags.SetBool('PlayerGotLethalAug', true, true, 0);
    }
	if(flags.GetBool('HasNonLethalAug') && !flags.GetBool('PlayerGotNonLethalAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugSkullGunNonLethal');
        flags.SetBool('PlayerGotNonLethalAug', true, true, 0);
    }
}

defaultproperties
{
    //missionName="Moon"
    sendToLocation="05_MoonIntro#TwoWeeksLater"
    conversationName=InExile
    actorTag=MagdaleneDenton
    cutsceneEndFlagName=IsIntroPlayed
	levelName="99_Endgame1"
}