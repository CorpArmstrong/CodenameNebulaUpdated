//-----------------------------------------------------------
// Mission L2
//
// All L2 quest logic lives here rather than in editor-placed actor
// properties. The QuestSystem class was designed to be configured in
// UnrealEd (questPathList is var(QuestPaths)), but no map ever configured
// it, and binary .dx properties cannot be diffed or reviewed in git.
// Driving the endings from script keeps the logic in source control.
//
// NOTE ON Timer(): Chapter05/Chapter06 extend CNNBaseIngameCutscene, whose
// Timer() calls DoLevelStuff() for them. This class extends MissionScript
// directly, and base MissionScript.Timer() does NOT call DoLevelStuff() --
// so DoLevelStuff() here was dead code until this override was added.
//-----------------------------------------------------------
class Chapter06L2 extends MissionScript;

var(ChangeLevelOnDeath) string levelName;

// Ending maps. All four already exist and ship.
const MAP_MUTINY     = "06_Mutiny";
const MAP_CONSPIRACY = "06_Conspiracy";
const MAP_HIJACKING  = "06_Hijacking";
const MAP_TRANSCEND  = "06_Transcend";

// Set true to log every flag change to the game log. Launch with -log to
// watch it. This is how we learn which flags the authored conversations
// actually fire, since no .con declares an ending flag.
var(Debug) bool bLogFlagChanges;

// Flags to watch, polled once per Timer tick so we can log exactly when each
// one fires during play.
//
// This is a fixed list rather than a FlagBase iterator walk on purpose.
// FlagBase does expose CreateIterator/GetNextFlag (see FlagEditWindow), but
// GetNextFlag needs an EFlagType out-param, and that enum lives in
// ConPlayBase in the DeusEx package: bare `EFlagType` won't resolve from a
// CNN class, and UE1 rejects qualified type names on locals. A fixed list
// costs nothing here because tools/con_dump.js can read every flag any
// conversation declares, so this list is exhaustive by construction.
//
// trackedValue is byte, not bool: UE1 stores bools as bitfields and rejects
// bool arrays outright ("Bool arrays are not allowed").
const MAX_TRACKED_FLAGS = 32;
var(Debug) Name trackedFlag[32];
var byte  trackedValue[32];
var int   trackedCount;
var bool  bTrackingPrimed;

var bool  bEndingTriggered;
var float levelSeconds;

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
    PrepareFirstFrame();
}

function PrepareFirstFrame()
{
    local Inventory anItem;

    if (flags.GetBool('PlayerDied'))
    {
        Player.RestoreAllHealth();

        while (Player.Inventory != none)
        {
            anItem = Player.Inventory;
            Player.DeleteInventory(anItem);
            anItem.Destroy();
        }
    }
}

// ----------------------------------------------------------------------
// Timer()
//
// MissionScript.Timer() only initializes flags; it never calls
// DoLevelStuff(). Drive it here.
// ----------------------------------------------------------------------

function Timer()
{
    super.Timer();
    DoLevelStuff();
}

function DoLevelStuff()
{
    if ((flags == None) || (Player == None))
        return;

    levelSeconds += checkTime;

    if (bLogFlagChanges)
        LogChangedFlags();

    CheckPlayerDeath();
    CheckEndingReached();
}

// ----------------------------------------------------------------------
// CheckPlayerDeath()
//
// Death before the upload sequence is a different ending from death during
// it, so the two are recorded as separate flags rather than one.
// ----------------------------------------------------------------------

function CheckPlayerDeath()
{
    if (!Player.IsInState('Dying'))
        return;

    if (flags.GetBool('TantalusUploadStarted'))
        flags.SetBool('PlayerDiedDuringUpload', true);
    else
        flags.SetBool('PlayerDiedOnL2', true);
}

// ----------------------------------------------------------------------
// CheckEndingReached()
//
// First match wins, so order encodes priority. Death outranks everything:
// if the player is dead, no other ending can still be earned.
// ----------------------------------------------------------------------

function CheckEndingReached()
{
    if (bEndingTriggered)
        return;

    // Transcendence -- upload completed. Checked before death-during-upload
    // because reaching the upload at all is the achievement.
    if (flags.GetBool('TantalusUploaded'))
    {
        TravelToEnding(MAP_TRANSCEND);
        return;
    }

    if (flags.GetBool('PlayerDiedDuringUpload'))
    {
        TravelToEnding(MAP_TRANSCEND);
        return;
    }

    if (flags.GetBool('PlayerDiedOnL2'))
    {
        TravelToEnding(MAP_MUTINY);
        return;
    }

    // Hijack -- all three station tasks done before the countdown ran out.
    if (flags.GetBool('UndockedL2') &&
        flags.GetBool('StartedBlueFusion') &&
        flags.GetBool('TookSteeringWheel') &&
        !flags.GetBool('TimerExpired'))
    {
        TravelToEnding(MAP_HIJACKING);
        return;
    }

    // Conspiracy -- countdown expired without a hijack attempt. Page wins.
    if (flags.GetBool('TimerExpired') && !flags.GetBool('UndockedL2'))
    {
        TravelToEnding(MAP_CONSPIRACY);
        return;
    }
}

function TravelToEnding(string endMapName)
{
    bEndingTriggered = true;
    flags.SetBool('IsGameCompleted', true);
    Log("CNN L2: ending reached after " $ int(levelSeconds) $ "s -> " $ endMapName);
    Level.Game.SendPlayer(Player, endMapName);
}

// ----------------------------------------------------------------------
// LogChangedFlags()
//
// Logs a line the first time a flag is seen and again whenever its value
// changes. FlagBase is native with no source, but FlagEditWindow shows the
// iterator API: CreateIterator / GetNextFlag / DestroyIterator.
// ----------------------------------------------------------------------

function LogChangedFlags()
{
    local int i;
    local bool flagValue;
    local byte packedValue;

    // Count the configured entries once, then poll only those.
    if (!bTrackingPrimed)
    {
        bTrackingPrimed = true;
        for (i = 0; i < MAX_TRACKED_FLAGS; i++)
        {
            if (trackedFlag[i] == '')
                break;
            trackedCount = i + 1;
            trackedValue[i] = 255;      // sentinel: forces a first-seen log
        }
        Log("CNN L2: watching " $ trackedCount $ " flags");
    }

    for (i = 0; i < trackedCount; i++)
    {
        flagValue   = flags.GetBool(trackedFlag[i]);
        packedValue = 0;
        if (flagValue)
            packedValue = 1;

        if (trackedValue[i] != packedValue)
        {
            trackedValue[i] = packedValue;
            Log("CNN L2 flag @" $ int(levelSeconds) $ "s: " $ trackedFlag[i] $ " = " $ flagValue);
        }
    }
}

defaultproperties
{
    levelName="06_OpheliaL2#HumanServer"
    bLogFlagChanges=True

    // Every flag OpheliaL2.con declares (via tools/con_dump.js), plus the
    // ending flags this script owns. None of the ending flags are set by any
    // conversation yet -- that is the gap this level's logic has to close.
    trackedFlag(0)='MikeWongExposed'
    trackedFlag(1)='MetReedAndWong'
    trackedFlag(2)='IsArrivalPlayed'
    trackedFlag(3)='OnLevel2'
    trackedFlag(4)='CanArmMagdalene'
    trackedFlag(5)='ReadyForBossFight'
    trackedFlag(6)='ReadyForSocialBoss'
    trackedFlag(7)='FinalGoodbyePlayed'
    trackedFlag(8)='AllObjectsDestroyed'
    trackedFlag(9)='SeedsOfDoubtPlanted'
    trackedFlag(10)='WongParanoid'
    trackedFlag(11)='SamUnfriendly'
    trackedFlag(12)='PlayerDied'
    trackedFlag(13)='PlayerDiedOnL2'
    trackedFlag(14)='PlayerDiedDuringUpload'
    trackedFlag(15)='TantalusUploadStarted'
    trackedFlag(16)='TantalusUploaded'
    trackedFlag(17)='UndockedL2'
    trackedFlag(18)='StartedBlueFusion'
    trackedFlag(19)='TookSteeringWheel'
    trackedFlag(20)='TimerExpired'
    trackedFlag(21)='IsGameCompleted'
}
