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
// Endings are chosen from accumulated state -- flags the authored
// conversations already set -- so no new conversation content is needed.
// Verified with tools/con_dump.js --flagmap that every flag below is
// SET inside L2 (ET_SetFlag), not merely checked. That matters: a flag
// only CHECKED here would have been set in the Docks or L1 and could
// already be true on level entry, firing an ending immediately.
// AllObjectsDestroyed is the counter-example -- it is CHECK-only in L2
// and deliberately not used as an ending condition.
//
// Order encodes priority. Death outranks everything; nothing else can
// still be earned once the player is dead.
// ----------------------------------------------------------------------

function CheckEndingReached()
{
    if (bEndingTriggered)
        return;

    // MUTINY (worst) -- Gray Goo consumes LA. Death is its own failure state
    // and is judged immediately, without waiting for the level's final beat.
    if (flags.GetBool('PlayerDiedOnL2') || flags.GetBool('PlayerDiedDuringUpload'))
    {
        TravelToEnding(MAP_MUTINY);
        return;
    }

    // Everything below is judged only once L2 reaches its final beat.
    // FinalGoodbyePlayed is SET by the MagdaleneInsideTube conversation.
    if (!flags.GetBool('FinalGoodbyePlayed'))
        return;

    // HIJACKING (best) -- docks and L1 fall away, Tantalus and Magdalene make
    // it out. Earned by arming Magdalene, i.e. the MagdaleneHijackTheStation
    // path, which is what sets CanArmMagdalene.
    if (flags.GetBool('CanArmMagdalene'))
    {
        TravelToEnding(MAP_HIJACKING);
        return;
    }

    // TRANSCEND -- MJ12 exposed, but the real Tantalus dies. Earned by
    // winning the social confrontation with Wong, either by exposing him
    // (MeetSamanthaReed) or by planting doubt during the boss (SocialBoss).
    if (flags.GetBool('MikeWongExposed') || flags.GetBool('SeedsOfDoubtPlanted'))
    {
        TravelToEnding(MAP_TRANSCEND);
        return;
    }

    // CONSPIRACY -- the passive outcome. Page wins.
    TravelToEnding(MAP_CONSPIRACY);
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
    trackedFlag(0)=MikeWongExposed
    trackedFlag(1)=MetReedAndWong
    trackedFlag(2)=IsArrivalPlayed
    trackedFlag(3)=OnLevel2
    trackedFlag(4)=CanArmMagdalene
    trackedFlag(5)=ReadyForBossFight
    trackedFlag(6)=ReadyForSocialBoss
    trackedFlag(7)=FinalGoodbyePlayed
    trackedFlag(8)=AllObjectsDestroyed
    trackedFlag(9)=SeedsOfDoubtPlanted
    trackedFlag(10)=WongParanoid
    trackedFlag(11)=SamUnfriendly
    trackedFlag(12)=PlayerDied
    trackedFlag(13)=PlayerDiedOnL2
    trackedFlag(14)=PlayerDiedDuringUpload
    trackedFlag(15)=TantalusUploadStarted
    trackedFlag(16)=TantalusUploaded
    trackedFlag(17)=UndockedL2
    trackedFlag(18)=StartedBlueFusion
    trackedFlag(19)=TookSteeringWheel
    trackedFlag(20)=TimerExpired
    trackedFlag(21)=IsGameCompleted
}
