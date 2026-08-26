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

// Magdalene combat diagnostics. She was observed going straight into
// run-and-shoot the instant the player arrived in the lower labs, which
// blocks MagdaleneHijackTheStation -- a ScriptedPawn in combat will not
// start a conversation, so the Hijacking ending is unreachable while this
// happens. Nothing in the log said WHO she was fighting, so log it.
var(Debug) bool bLogMagdalene;
var Magdalene watchedMagdalene;
var name      lastMagOrders;
var string    lastMagEnemy;
var bool      bMagWatchPrimed;

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

    RepairSamanthaReedTrigger();
    RepairCommCenterBattle();
    RemoveStrayL1Conversations();
}

// ----------------------------------------------------------------------
// RemoveStrayL1Conversations()
//
// Two conversations authored for the Docks/L1 map are gated on the
// OnLevel2 flag (verified with con_dump --records on
// OpheliaDocksAndL1.con):
//
//     Meet1InspRoom      owner OpheliaUI   PRECOND OnLevel2
//     ApproachingOphelia owner Magdalene   PRECOND OnLevel2
//
// L2 contains actors with both of those BindNames AND sets OnLevel2 from a
// FlagTrigger a few steps from the spawn. So the moment the player walks in,
// both L1 conversations become available on L2 and compete with the real
// ones -- StartConversationByName walks conListItems and takes the first
// match, so which one wins is list order, not intent.
//
// Observed in play: talking to Ophelia on L2 started the L1 inspection-room
// scene, which then blocked the game because L1's scripted sequence does not
// exist here. The Magdalene one is the more damaging of the two, since it
// competes with MagdaleneHijackTheStation -- the only thing that sets
// CanArmMagdalene, and therefore the only route to the Hijacking ending.
//
// Fixing this properly means editing preconditions in ConEdit. Unlinking the
// entries from the owning actors' conversation lists achieves the same thing
// for this level only, in code, and leaves the .con untouched so L1 keeps
// working.
// ----------------------------------------------------------------------

function RemoveStrayL1Conversations()
{
    StripConversation('Meet1InspRoom');
    StripConversation('ApproachingOphelia');
}

function StripConversation(name conName)
{
    local Actor a;
    local ConListItem item, prev;

    foreach AllActors(class'Actor', a)
    {
        if (a.conListItems == None)
            continue;

        prev = None;
        item = ConListItem(a.conListItems);

        while (item != None)
        {
            if ((item.con != None) && (item.con.conName == conName))
            {
                // Unlink, keeping the rest of the actor's list intact.
                if (prev == None)
                    a.conListItems = item.next;
                else
                    prev.next = item.next;

                Log("CNN L2: removed stray L1 conversation '" $ conName $
                    "' from " $ a.BindName);
            }
            else
            {
                prev = item;
            }

            item = item.next;
        }
    }
}

// ----------------------------------------------------------------------
// RepairSamanthaReedTrigger()
//
// The map's ConversationTrigger for MeetSamanthaReed was placed with
// conversationTag set but BindName left empty. ConversationTrigger guards
// its ENTIRE body with
//
//     if ((BindName != "") && (conversationTag != ''))
//
// so an empty BindName makes the trigger inert -- it never calls
// StartConversationByName, and it does so silently, with no warning in the
// log. The level's two working triggers both carry BindName="Magdalene".
//
// That one missing property is what made the Transcend ending unreachable:
// MikeWongExposed is SET only inside ContinueOn, which is part of the
// Samantha Reed scene, and this trigger is the only thing in the map that
// can start it. Transcend's alternate condition, SeedsOfDoubtPlanted, is
// gated behind ReadyForSocialBoss and is dead for separate reasons.
//
// Fixing it in UnrealEd would mean a binary .dx change that cannot be
// diffed or reviewed. Assigning the property here keeps the fix in source
// control, which is the same reason the rest of L2's logic lives in script.
//
// Matched on conversationTag rather than Tag: Tag is the generic
// 'ConversationTrigger' on two of the three, while conversationTag is
// unique. Only an empty BindName is filled in, so if the map is ever fixed
// properly this becomes a no-op instead of fighting the map.
// ----------------------------------------------------------------------

function RepairSamanthaReedTrigger()
{
    local ConversationTrigger conTrigger;

    foreach AllActors(class'ConversationTrigger', conTrigger)
    {
        if ((conTrigger.conversationTag == 'MeetSamanthaReed') &&
            (conTrigger.BindName == ""))
        {
            conTrigger.BindName = "SamanthaReed";
            Log("CNN L2: repaired MeetSamanthaReed trigger (BindName was empty)");
        }
    }
}

// ----------------------------------------------------------------------
// RepairCommCenterBattle()
//
// The CommCenterDispatcher fires the comm centre fight:
//
//     OutEvents(0)=OpenCommCenterDoors
//     OutEvents(1)=MJ12AllianceTrigger      MJ12Troops -> Avatars  = -1.0
//     OutEvents(2)=AvatarsAllianceTrigger   Avatars -> MJ12Troops  = -1.0
//     OutEvents(3)=MJ12OrdersTrigger        MJ12 run to the battle
//     OutEvents(4)=MJ12OrdersTrigger        <-- copy-paste slip
//
// Slot 4 repeats slot 3 instead of firing AvatarsOrdersTrigger, which sits
// in the map at (1240,-1848,-1338) fully configured -- Orders=RunningTo,
// ordersTag=CommCenterBattleSpawnPoint, Event=AvatarsFightGroup -- and is
// referenced by nothing at all. Its only appearance anywhere in
// L2_export.t3d is its own Tag= line.
//
// So MJ12 gets ordered into the fight and the Avatars never do. Reported
// from play as "the avatars attacked me but the two sides ignored each
// other".
//
// Rewriting the slot here rather than in UnrealEd keeps the change
// reviewable, same reasoning as RepairSamanthaReedTrigger(). Only a slot
// that still holds the duplicate is touched, so fixing the map properly
// later makes this a no-op.
// ----------------------------------------------------------------------

function RepairCommCenterBattle()
{
    local Dispatcher disp;
    local int i;
    local int dupIndex;
    local bool bAlreadyPresent;

    foreach AllActors(class'Dispatcher', disp, 'CommCenterDispatcher')
    {
        dupIndex = -1;
        bAlreadyPresent = false;

        // Walk once to see what is actually there. Never assume index 4 --
        // if the map is edited the slot may move, and blindly writing an
        // index could clobber a legitimate event.
        for (i = 0; i < 8; i++)
        {
            if (disp.OutEvents[i] == 'AvatarsOrdersTrigger')
                bAlreadyPresent = true;
            else if (disp.OutEvents[i] == 'MJ12OrdersTrigger')
            {
                if (dupIndex >= 0)          // second one: the duplicate
                    continue;
                dupIndex = i;
            }
        }

        if (bAlreadyPresent || (dupIndex < 0))
            continue;

        // Reclaim the LAST duplicate, keeping the first MJ12 order intact.
        for (i = 7; i > dupIndex; i--)
        {
            if (disp.OutEvents[i] == 'MJ12OrdersTrigger')
            {
                disp.OutEvents[i] = 'AvatarsOrdersTrigger';
                Log("CNN L2: repaired CommCenterDispatcher OutEvents(" $ i $
                    ") MJ12OrdersTrigger -> AvatarsOrdersTrigger");
                break;
            }
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

    if (bLogMagdalene)
        LogMagdaleneState();

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
    // (ContinueOn, inside the Samantha Reed scene) or by planting doubt during
    // the boss (AccuseofBluffing, under SocialBoss). NOTE: neither is reachable
    // in the shipped map -- see CNNDocs/L2_WalkthroughMap.md section 6.
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

// ----------------------------------------------------------------------
// LogMagdaleneState()
//
// Logs Magdalene's orders / current enemy / alliance whenever any of them
// change. Logged only on change, so a quiet level costs one line.
//
// The question this exists to answer: she starts shooting the moment the
// player reaches the lower labs, and combat blocks the conversation that
// sets CanArmMagdalene. Knowing WHO she targets separates the candidates --
// the JC Avatar standing ~250 units away at (894,-2315,-1303), an Avatar
// that wandered in, or the player.
// ----------------------------------------------------------------------

function LogMagdaleneState()
{
    local Magdalene mag;
    local string enemyName;

    if (!bMagWatchPrimed)
    {
        bMagWatchPrimed = true;
        foreach AllActors(class'Magdalene', mag)
        {
            watchedMagdalene = mag;
            break;
        }

        if (watchedMagdalene == None)
        {
            Log("CNN L2 magdalene: no Magdalene actor in this level");
            return;
        }
    }

    if (watchedMagdalene == None)
        return;

    if (watchedMagdalene.Enemy != None)
        enemyName = string(watchedMagdalene.Enemy.Name) $ " [" $
                    string(watchedMagdalene.Enemy.Class.Name) $ "]";
    else
        enemyName = "none";

    if ((watchedMagdalene.Orders != lastMagOrders) || (enemyName != lastMagEnemy))
    {
        lastMagOrders = watchedMagdalene.Orders;
        lastMagEnemy  = enemyName;

        Log("CNN L2 magdalene @" $ int(levelSeconds) $ "s: orders=" $
            string(watchedMagdalene.Orders) $ " enemy=" $ enemyName $
            " alliance=" $ string(watchedMagdalene.Alliance) $
            " health=" $ watchedMagdalene.Health);
    }
}

defaultproperties
{
    levelName="06_OpheliaL2#HumanServer"
    bLogFlagChanges=True
    bLogMagdalene=True

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
