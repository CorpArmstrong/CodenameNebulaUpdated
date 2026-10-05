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

// The tube button is routed through this script -- see RouteTubeButton().
const TUBE_BUTTON_TAG = 'CNNTubeButton';
// Tube glass bottom below its mover origin -- see FixTubeMover().
const TUBE_GLASS_BOTTOM = 50.0;
// How far Magdalene may trail the player near the tube lab before she is
// brought up behind him. Was the 800-unit conversation radius; that let
// her walk into the lab long after the player (user, 2026-10-02).
const MAG_CATCHUP_DIST = 300;

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
var bool      bSoldierFallbackDone;
var bool      bTubeLogged;
var float     tubeLogDelay;

// MJ12 arrival countdown and the ship's wheel -- see StartMJ12Countdown().
const MJ12_COUNTDOWN_SECONDS = 240.0;
const MJ12_ARRIVAL_GRACE     = 3.0;

// SocialBoss event indices (bridge CONEVENTS dump, 2026-10-02) -- see
// ValidateSocialBoss(). Actions key on the SPEECH line that follows each
// placeholder: speech waits for audio, so WatchConversation() always sees
// it, while comments and triggers can pass within a single frame.
const SB_TROOPER_SHOT   = 7;    // Tantalus "Son of a bitch!" (after TRIGGER MikeExecutesMJ12Troop)
const SB_ARMSTRONG_SHOT = 27;   // Tantalus "Armstrong!", after his groan -- a speaker
                                // killed on his own line aborts the scene
const SB_JOHNSON_SHOT   = 39;   // Tantalus "No!!!", after Johnson's plea
const SB_SAMANTHA_SHOT  = 54;   // Wong "You are NEXT", after "Samantha, your mother..."
const SB_MEPH_SHOT_A    = 66;   // "So mote it be." -- Apologize branch
const SB_MEPH_SHOT_B    = 77;   // "So mote it be." -- Manipulate branch
const SB_WONG_TURNS_A   = 67;   // Wong "Your Chinese sucks heck."
const SB_WONG_TURNS_B   = 78;   // Wong "You still Dontgivafucker!"
var Conversation watchedCon;
var ConEvent     lastSeenEvent;

var float        mj12SecondsLeft;
var float        mj12ArrivedSeconds;
var transient TimerDisplay mj12Window;   // never saved -- see CNNEventTimer.timerWin
var bool         bWheelHintShown;
var ScriptedPawn sbTrooper;
var bool         bSocialBossFight;
var bool         bWongHostile;
var bool         bMephHostile;
var bool         bSocialBossStarted;
var bool         bSocialBossReleased;
var int          initCount;          // InitStateMachine runs; SNAP shows it (save/load audit)
var localized string BridgeNotClearMessage;
var localized string MJ12GoalText;
var localized string MJ12StartMessage;
var localized string MJ12TimerLabel;
var localized string MJ12ArrivedMessage;
var localized string WheelNeedsMagdaleneMessage;

function InitStateMachine()
{
    super.InitStateMachine();
    initCount++;
    Log("CNN L2: InitStateMachine run " $ initCount $ ", PlayerTraveling=" $ flags.GetBool('PlayerTraveling'));
    FirstFrame();
    PrepareFirstFrame();
}

function PrepareFirstFrame()
{
    local Inventory anItem, nextItem;

    // Dying on L1 sends the player here, healed and with nothing. Once:
    // PlayerDied is never cleared, and this runs again on every load of
    // an L2 save, which stripped the inventory each time (found
    // 2026-10-05, save/load audit).
    if (flags.GetBool('PlayerDied') && !flags.GetBool('PlayerDiedHandledOnL2'))
    {
        flags.SetBool('PlayerDiedHandledOnL2', true);
        Player.RestoreAllHealth();

        // As vanilla Mission05 takes JC's gear: the NanoKeyRing and the
        // items that are not real inventory stay. Destroying them too left
        // references behind that crashed the next save (2026-10-05).
        anItem = Player.Inventory;
        while (anItem != none)
        {
            nextItem = anItem.Inventory;
            if (!anItem.IsA('NanoKeyRing') && anItem.bDisplayableInv)
            {
                if (anItem.IsA('ChargedPickup'))
                    ChargedPickup(anItem).ChargedPickupEnd(Player);
                Player.DeleteInventory(anItem);
                anItem.Destroy();
            }
            anItem = nextItem;
        }
    }

    RestoreSavedState();

    RepairCommCenterBattle();
    DisableStaleTubeMapExit();
    FixTubeMover();
    RouteTubeButton();
    RemoveStrayL1Conversations();
    DedupeConversations();
    TrimMagdaleneCoilGuns();
    RebindHostages();
    SetSocialBossCarcasses();
    ProtectSocialBossCast();
    ValidateSocialBoss();
    ProtectShipsWheel();
    DisablePageAndSamantha();
    DumpConversationLists();
}

// ----------------------------------------------------------------------
// DisablePageAndSamantha()
//
// The Bob Page / Samantha Reed storyline is not implemented on L2: Page's
// elevator infolink sends the player to his daughter in the Gravity Lab,
// and nothing there plays (MeetSamanthaReed's second speaker is an
// offstage double, SamGivesQuest needs a flag nothing sets). Until it is
// built, switch the whole thread off so the player is not sent after it:
//
//   - the DataLinkTrigger for DL_BobPageInElevator (and its TalkToPage goal);
//   - the ConversationTrigger for MeetSamanthaReed;
//   - Samantha's own conversations, so frobbing her does nothing.
//
// The Uber Alles holocomm is a separate thread and is left alone.
// User-decided 2026-10-02. To bring the storyline back, drop this call
// from PrepareFirstFrame().
// ----------------------------------------------------------------------

function DisablePageAndSamantha()
{
    local DataLinkTrigger dlTrigger;
    local ConversationTrigger conTrigger;
    local DeusExGoal goal;

    foreach AllActors(class'DataLinkTrigger', dlTrigger)
    {
        if (dlTrigger.datalinkTag == 'DL_BobPageInElevator')
        {
            dlTrigger.SetCollision(false, false, false);
            dlTrigger.datalinkTag = '';
            Log("CNN L2: disabled Bob Page infolink trigger " $ dlTrigger.Name);
        }
    }

    foreach AllActors(class'ConversationTrigger', conTrigger)
    {
        if (conTrigger.conversationTag == 'MeetSamanthaReed')
        {
            conTrigger.SetCollision(false, false, false);
            conTrigger.conversationTag = '';
            Log("CNN L2: disabled Samantha Reed trigger " $ conTrigger.Name);
        }
    }

    StripConversation('MeetSamanthaReed');
    StripConversation('SamGivesQuest');
    StripConversation('FindMeganReed');

    goal = Player.FindGoal('TalkToPage');
    if (goal != None)
        Player.DeleteGoal(goal);
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

// ----------------------------------------------------------------------
// DedupeConversations()
//
// Chapter06.con holds duplicate copies of most L2 conversations -- same
// conName, same owner BindName -- and they load BEFORE OpheliaL2.con's.
// StartConversationByName takes the first name match, so the stale copy
// always wins. Confirmed live on this level:
//
//     MJ12Sergeant [0] MeetSoldiers   [1] MeetSoldiers
//     Magdalene    [1] MagdaleneHijackTheStation  [4] (again)
//     SamanthaReed [0] MeetSamanthaReed           [1] (again)
//     OpheliaUI    [0] OpheliaHallway             [2] (again)
//
// Load order was established from OpheliaHallway: con_dump shows only
// OpheliaL2.con's copy carries the OnLevel2 precondition, and the live dump
// puts that one at index [2]. So the LATER duplicate is this level's real
// one, and every earlier copy is Chapter06.con's.
//
// Consequence in play: MeetSoldiers ran to completion and set nothing,
// because Chapter06.con's copy has no ReadyForBossFight SET and does not
// fire CommCenterDispatcher -- so the comm centre battle could never start
// no matter how the dispatcher was wired. The same mechanism sat in front
// of MagdaleneHijackTheStation (CanArmMagdalene, the Hijacking ending) and
// MagdaleneInsideTube (FinalGoodbyePlayed, the ending gate itself).
//
// Keeping the LAST duplicate keeps the level-specific copy. Deleting the
// duplicates from Chapter06.con would be the real fix, but that needs
// ConEdit; this achieves the same for L2 only and leaves the other maps'
// use of Chapter06.con untouched.
//
// UPDATE (2026-09-23): "last wins" is only a proxy for "the real one", and
// it is WRONG for Magdalene specifically. Confirmed live via CNNConverse:
// after dedup, Magdalene's surviving MagdaleneHijackTheStation still had
// "(no flags)" -- Chapter06.con's contentless stub was the one that loaded
// last for this actor, so dedup kept the stub and threw away OpheliaL2.con's
// real copy (the one with SET CanArmMagdalene). Playing it organically
// completed in under a second and set nothing, which looked like a broken
// conversation system but was actually the wrong .con surviving dedup.
//
// Fixed by preferring flag content over position: if ANY duplicate for a
// given name carries real flag references (SET/CHECK -- a stub never does,
// that's the whole reason it's a stub), keep the last FLAGGED one and drop
// every flagless copy outright, regardless of where it sits in the list.
// Only fall back to pure "last wins" when every duplicate is equally
// flagless (e.g. MeetSoldiers, where the load-order assumption above still
// holds and there's no flag content to tell copies apart by).
//
// UPDATE 2 (2026-09-23): flagRefList wasn't the right signal either -- live
// testing after the first update showed Magdalene's surviving
// MagdaleneHijackTheStation STILL had flagRefList==None (so bAnyFlagged was
// False for this name and dedupe silently fell back to plain "last wins",
// same stub as before), and a deeper CNNConverse diagnostic then showed WHY
// it looks empty either way: ConPlay.StartConversation() does
// `currentEvent = con.eventList`, and for this actor's surviving copy
// eventList is also None -- a conversation with literally zero events,
// which state PlayEvent's Begin: label detects and immediately
// TerminateConversation()s, before a single line plays. That is a stronger,
// more direct stub signal than flagRefList (whose relationship to
// mid-conversation SET/CHECK events is unclear -- ArmMagdalene shows real
// flags through it, but a SetFlag event buried in a conversation body
// apparently doesn't). Switched the criterion to eventList: a conversation
// with no events cannot possibly be the real one, full stop.
// ----------------------------------------------------------------------

function DedupeConversations()
{
    local Actor a;

    foreach AllActors(class'Actor', a)
    {
        if (a.conListItems != None)
            DedupeOneActor(a);
    }
}

function bool ConNameHasNonEmptyCopy(Actor a, Name conName)
{
    local ConListItem scan;

    scan = ConListItem(a.conListItems);
    while (scan != None)
    {
        if ((scan.con != None) && (scan.con.conName == conName) && (scan.con.eventList != None))
            return true;
        scan = scan.next;
    }
    return false;
}

function bool IsLastOccurrence(ConListItem item, bool bNonEmptyOnly)
{
    local ConListItem scan;

    scan = item.next;
    while (scan != None)
    {
        if ((scan.con != None) && (scan.con.conName == item.con.conName) &&
            (!bNonEmptyOnly || (scan.con.eventList != None)))
        {
            return false;
        }
        scan = scan.next;
    }
    return true;
}

function DedupeOneActor(Actor a)
{
    local ConListItem item, prev, next;
    local bool bKeep, bThisNonEmpty, bAnyNonEmpty;

    prev = None;
    item = ConListItem(a.conListItems);

    while (item != None)
    {
        next = item.next;

        if (item.con == None)
        {
            bKeep = true;
        }
        else
        {
            bThisNonEmpty = (item.con.eventList != None);
            bAnyNonEmpty = ConNameHasNonEmptyCopy(a, item.con.conName);

            if (bAnyNonEmpty)
                bKeep = bThisNonEmpty && IsLastOccurrence(item, true);
            else
                bKeep = IsLastOccurrence(item, false);
        }

        if (!bKeep)
        {
            if (prev == None)
                a.conListItems = next;
            else
                prev.next = next;

            Log("CNN L2 dedupe: dropped stale " $ string(item.con.conName) $
                " from " $ a.BindName);
        }
        else
        {
            prev = item;
        }

        item = next;
    }
}

// ----------------------------------------------------------------------
// DumpConversationLists()
//
// Logs every conversation bound to the level's key actors, in list order,
// with the flags each one references.
//
// Why: Chapter06.con holds DUPLICATE copies of most L2 conversations --
// same conName, same owner BindName -- and those copies reference none of
// L2's flags. StartConversationByName walks conListItems and takes the
// FIRST name match, so if a duplicate sits ahead of the real one the scene
// plays perfectly and sets nothing. That matches the reports exactly:
// MeetSoldiers "ended normally" but ReadyForBossFight never set, so
// CommCenterDispatcher never fired and the comm centre battle never
// started.
//
// Order and flag content cannot be read from the .con files -- they only
// show what exists, not what the engine linked first -- so dump it from
// the live list before changing anything.
// ----------------------------------------------------------------------

function DumpConversationLists()
{
    local Actor a;

    foreach AllActors(class'Actor', a)
    {
        if ((a.conListItems == None) || (a.BindName == ""))
            continue;

        if ((a.BindName == "MJ12Sergeant") || (a.BindName == "Magdalene") ||
            (a.BindName == "SamanthaReed") || (a.BindName == "OpheliaUI") ||
            (a.BindName == "MikeWong")     || (a.BindName == "DrMephistopheles"))
        {
            DumpOneActorsConversations(a);
        }
    }
}

function DumpOneActorsConversations(Actor a)
{
    local ConListItem item;
    local ConFlagRef flagRef;
    local string flagList;
    local int index;

    item = ConListItem(a.conListItems);

    while (item != None)
    {
        if (item.con != None)
        {
            flagList = "";
            flagRef  = item.con.flagRefList;

            while (flagRef != None)
            {
                flagList = flagList $ " " $ string(flagRef.flagName);
                flagRef  = flagRef.nextFlagRef;
            }

            if (flagList == "")
                flagList = " (no flags)";

            Log("CNN L2 cons: " $ a.BindName $ " [" $ index $ "] " $
                string(item.con.conName) $ " flags:" $ flagList);
        }

        index++;
        item = item.next;
    }
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

                Log("CNN L2: removed conversation '" $ conName $
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
// RouteTubeButton() / Trigger() / PutMagdaleneInTube()
//
// Magdalene must be inside the tube when its glass comes down (user,
// 2026-10-02, variant A). The map's LoadingInTube scene walks her in, but
// only if she arrives before the player presses the button, and polling for
// the button from Timer() is up to a second late while the glass takes
// about that long to close. So the button is routed through this script:
// at load its Event becomes TUBE_BUTTON_TAG (this actor's Tag), and
// Trigger() puts her at MagdalenePoint first, then fires the map's own
// MiniGameDispatcher (glass, goodbye, upload timer, avatar spawner)
// unchanged. FixTubeMover() keeps the glass from bouncing off her.
// ----------------------------------------------------------------------

function RouteTubeButton()
{
    local Actor a;

    // A loaded save already has the button rerouted, but a fresh mission
    // script (every load spawns one) still needs the Tag -- without it the
    // button did nothing after a load (found 2026-10-05, save/load audit).
    foreach AllActors(class'Actor', a)
    {
        if ((a.Event == 'MiniGameDispatcher') || ((a.Event == TUBE_BUTTON_TAG) && (a != self)))
        {
            a.Event = TUBE_BUTTON_TAG;
            Tag = TUBE_BUTTON_TAG;
            Log("CNN L2: tube button " $ a.Name $ " routed through the mission script");
        }
    }
}

function Trigger(Actor Other, Pawn EventInstigator)
{
    local Dispatcher disp;

    PutMagdaleneInTube();

    foreach AllActors(class'Dispatcher', disp, 'MiniGameDispatcher')
        disp.Trigger(Other, EventInstigator);
}

function PutMagdaleneInTube()
{
    local Magdalene mag;
    local Actor point;

    foreach AllActors(class'Magdalene', mag)
        break;
    if ((mag == None) || (mag.Health <= 0) || mag.IsInState('Dying'))
        return;

    // MagdalenePoint is the tube's centre -- see FixTubeMover().
    foreach AllActors(class'Actor', point, 'MagdalenePoint')
        break;
    if (point == None)
        return;

    if (VSize(mag.Location - point.Location) > 16)
    {
        if (mag.SetLocation(point.Location))
            Log("CNN L2: put Magdalene in the tube at the button");
        else
            Log("CNN L2: could not put Magdalene in the tube (blocked)");
    }
    mag.SetRotation(point.Rotation);
    mag.SetOrders('Standing', '', true);
}

// ----------------------------------------------------------------------
// FixTubeMover()
//
// The upload tube's glass (CNNMover0, tag CNNMoverTube) is mis-keyed in the
// map. Open (key 1, where the level starts) it hangs over the tube's base
// in line with the neighbouring Bob Page tube; MagdalenePoint, where the
// map's LoadingInTube scene parks Magdalene, is within 4 units of its
// centre (brush bbox minus PrePivot, measured from L2_export.t3d). But the
// closed key is offset by (-64,-64): the glass slid diagonally off the base
// and came down beside her instead of on her (seen in play 2026-10-02).
// Moving BasePos under the open key makes it rise and fall vertically over
// the base; the glass does not move at load. ME_IgnoreWhenEncroach stops it
// bouncing back off her. She is meant to be shut inside (user, variant A).
//
// The closed key was also too low: the glass sank into the floor
// and stopped at Magdalene's shoulders (seen in play 2026-10-02). So the
// closed height is set from the floor traced under MagdalenePoint: the
// glass bottom is TUBE_GLASS_BOTTOM below the mover origin (brush bbox
// -64 plus PrePivot 14, from L2_export.t3d), and the open key is
// re-expressed so the open glass stays exactly where the map put it.
// ----------------------------------------------------------------------

function FixTubeMover()
{
    local Mover tube;
    local Actor point;
    local vector openPos, hitLocation, hitNormal;

    foreach AllActors(class'Actor', point, 'MagdalenePoint')
        break;

    foreach AllActors(class'Mover', tube, 'CNNMoverTube')
    {
        tube.MoverEncroachType = ME_IgnoreWhenEncroach;
        openPos = tube.BasePos + tube.KeyPos[1];

        tube.BasePos.X = openPos.X;
        tube.BasePos.Y = openPos.Y;

        if ((point != None) &&
            (Trace(hitLocation, hitNormal, point.Location - vect(0,0,300),
                   point.Location + vect(0,0,40), true) != None))
        {
            tube.BasePos.Z = hitLocation.Z + TUBE_GLASS_BOTTOM;
        }

        tube.KeyPos[1] = openPos - tube.BasePos;
        Log("CNN L2: tube mover " $ tube.Name $ " closes straight down onto " $
            tube.BasePos $ " (floor " $ hitLocation.Z $ "), open key " $ tube.KeyPos[1] $
            ", keyNum=" $ tube.KeyNum $ " loc=" $ tube.Location);
    }
}

// Logs where the tube glass is a few seconds after the button, so a manual
// run shows whether it actually closed (KeyNum 0 = down).
function LogTubeAfterUpload()
{
    local Mover tube;

    if (bTubeLogged || !flags.GetBool('TantalusUploadStarted'))
        return;

    tubeLogDelay += checkTime;
    if (tubeLogDelay < 4.0)
        return;

    bTubeLogged = true;
    foreach AllActors(class'Mover', tube, 'CNNMoverTube')
        Log("CNN L2: tube after button: KeyNum=" $ tube.KeyNum $ " state=" $ tube.GetStateName() $
            " opening=" $ tube.bOpening $ " loc=" $ tube.Location);
}

// ----------------------------------------------------------------------
// CheckSoldierSoftlock()
//
// The only way down to the lower labs is OpenCommCenterDoors (a locked,
// unbreakable, unfrobbable DeusExMover), fired by CommCenterDispatcher from
// the end of MeetSoldiers. That conversation is owned by the MJ12 sergeant
// (MJ12Commando0, BindName MJ12Sergeant), and eight avatars stand within
// ~500 units of his squad. If he dies before the talk -- crossfire while the
// player fights the avatars -- the conversation can never start and the
// level is soft-locked (user, 2026-10-02). In that case do what the
// conversation would have done.
// ----------------------------------------------------------------------

function CheckSoldierSoftlock()
{
    local ScriptedPawn sergeant, p;
    local Dispatcher disp;

    if (bSoldierFallbackDone || flags.GetBool('ReadyForBossFight'))
        return;

    foreach AllActors(class'ScriptedPawn', p)
    {
        if (p.BindName == "MJ12Sergeant")
        {
            sergeant = p;
            break;
        }
    }

    if ((sergeant != None) && (sergeant.Health > 0) && !sergeant.IsInState('Dying'))
        return;

    bSoldierFallbackDone = true;
    flags.SetBool('ReadyForBossFight', true);
    foreach AllActors(class'Dispatcher', disp, 'CommCenterDispatcher')
        disp.Trigger(Player, Player);
    Log("CNN L2: MJ12 sergeant died before MeetSoldiers -- opened the comm centre doors anyway");
}

// ----------------------------------------------------------------------
// DisableStaleTubeMapExit()
//
// The tube button fires MiniGameDispatcher, which starts a 30s survival
// countdown (CNNEventTimer). When it runs out it fires
// LabEndingSuccessDispatcher, whose OutEvents(3) is MutinyMapExit -- a
// MapExit with DestMap="transcendence". That was the GDD's "survived the
// upload -> Benevolent Dictator" exit, but the map is now 06_Transcend, so
// it fails. Found from play 2026-09-24: a player who reached the tube
// without Magdalene (so the MagdaleneInsideTube goodbye never ran) got
// "Failed to load 'transcendence'" instead of an ending.
//
// Retagging it leaves the dispatcher's other events (shake, tube mover,
// lifecycle toggle) intact while the dispatcher's MutinyMapExit event finds
// nothing. CheckEndingReached() makes the same trip on TimerExpired (set by
// CNNEventTimer), so the ending is logged and chosen in one place like the
// others. Only an exit pointing at the missing map is touched.
// ----------------------------------------------------------------------

function DisableStaleTubeMapExit()
{
    local MapExit exit;

    foreach AllActors(class'MapExit', exit)
    {
        if (Caps(exit.DestMap) == "TRANSCENDENCE")
        {
            exit.Tag = 'DisabledStaleMapExit';
            Log("CNN L2: disabled stale MapExit '" $ exit.Name $ "' (DestMap=transcendence)");
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
// reviewable and keeps it in source control. Only a slot that still holds
// the duplicate is touched, so fixing the map properly later makes this a
// no-op.
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// RestoreSavedState()
//
// Mission scripts are not kept in a savegame: every load spawns a fresh
// Chapter06L2 (DeusExPlayer.TravelPostAccept -> SpawnScript), which is why
// vanilla missions keep their state in flags. Loading a save with the MJ12
// countdown running ended in Conspiracy at once, the clock being back at
// zero (found 2026-10-05, save/load audit). So what must survive a load is
// mirrored in flags and read back here, before anything acts on it.
// ----------------------------------------------------------------------

function RestoreSavedState()
{
    local ScriptedPawn p;

    if (flags.GetBool('MJ12TimerStarted') && !flags.GetBool('MJ12Arrived'))
    {
        mj12SecondsLeft = flags.GetInt('MJ12SecondsLeft');
        if (mj12SecondsLeft <= 0)
            mj12SecondsLeft = MJ12_COUNTDOWN_SECONDS;   // a save from before the flag existed
    }

    bSocialBossStarted = flags.GetBool('SocialBossStarted');
    bSocialBossFight   = flags.GetBool('SocialBossFight');

    foreach AllActors(class'ScriptedPawn', p, 'SocialBossTrooper')
        sbTrooper = p;

    if (flags.GetBool('MJ12TimerStarted'))
        Log("CNN L2: restored -- MJ12 " $ int(mj12SecondsLeft) $ "s, social boss started=" $
            bSocialBossStarted $ " fight=" $ bSocialBossFight $ " trooper=" $ (sbTrooper != None));
}

function SetSocialBossFight()
{
    bSocialBossFight = true;
    flags.SetBool('SocialBossFight', true);
}

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

    CheckMagdaleneArmed();
    CheckUploadStarted();
    UpdateMJ12Countdown();
    CheckSocialBossFight();
    CheckShipsWheel();
    CheckSoldierSoftlock();
    LogTubeAfterUpload();
    CheckPlayerDeath();
    CheckEndingReached();
}

// ----------------------------------------------------------------------
// CheckMagdaleneArmed()
//
// MagdaleneHijackTheStation is linear and unavoidable on the way to the IoT
// terminal, and always ends by setting CanArmMagdalene -- which, as its name
// says, only unlocks ArmMagdalene ("I'll give you a weapon"). Keying
// Hijacking on CanArmMagdalene alone made Conspiracy unreachable in play
// (found 2026-09-24). ArmMagdalene sets no flag; its outcome is the weapon
// it transfers to her. So Hijacking now needs her actually armed by the
// player: one of the four weapons ArmMagdalene can hand over. Her own coil
// gun (InitialInventory) doesn't count. User-decided 2026-09-24.
// ----------------------------------------------------------------------

function CheckMagdaleneArmed()
{
    local Magdalene mag;

    if (flags.GetBool('MagdaleneArmed') || !flags.GetBool('CanArmMagdalene'))
        return;

    foreach AllActors(class'Magdalene', mag)
        break;
    if (mag == None)
        return;

    if ((mag.FindInventoryType(class'WeaponPlasmaRifle') != None) ||
        (mag.FindInventoryType(class'WeaponAssaultGun') != None) ||
        (mag.FindInventoryType(class'WeaponSnowblind') != None) ||
        (mag.FindInventoryType(class'WeaponMiniCrossbow') != None) ||
        (mag.FindInventoryType(class'WeaponCrowbar') != None))  // the "mini-crossbow" line actually hands over WeaponCrowbar
    {
        flags.SetBool('MagdaleneArmed', true);
    }
}

// ----------------------------------------------------------------------
// CheckUploadStarted()
//
// The tube button (MiniGameDispatcher) is the GDD's L2_PressUploadButton:
// it starts the upload countdown, shown by CNNEventTimer's window. Nothing
// in the map or the conversations sets TantalusUploadStarted, so without
// this CheckPlayerDeath() could never tell a death during the upload from
// one before it.
// ----------------------------------------------------------------------

function CheckUploadStarted()
{
    local CNNEventTimer uploadTimer;

    if (!flags.GetBool('TantalusUploadStarted'))
    {
        foreach AllActors(class'CNNEventTimer', uploadTimer)
        {
            if (uploadTimer.timerWin != None)
            {
                flags.SetBool('TantalusUploadStarted', true);
                break;
            }
        }
    }

    BringMagdaleneToTube();
}

// ----------------------------------------------------------------------
// BringMagdaleneToTube()
//
// The tube scenes need Magdalene close: the map's LoadingInTube walks her
// into the tube and the button starts the MagdaleneInsideTube goodbye, both
// only within the engine's 800-unit conversation radius. In play she falls
// behind when she stops to fight (a bridge guard drew her off, 2026-10-02).
//
// Earlier versions moved her straight into the tube once the player was
// within 700 units of the button -- through walls, before the player had
// even entered the lab -- so she seemed to appear there by magic (user,
// 2026-10-02). Now she only catches up: once she is more than
// MAG_CATCHUP_DIST away and out of the player's sight, she is put a few
// steps behind the player and keeps
// following, and the map's own scene takes it from there. Never after the
// button, and never while either of them is in a conversation. If she is
// not following -- never freed, hostile or dead -- nothing happens and the
// upload plays out without her.
// ----------------------------------------------------------------------

function BringMagdaleneToTube()
{
    local Magdalene mag;
    local Actor a, button;
    local rotator facing;
    local vector behind;
    local int dist;

    if (flags.GetBool('TantalusUploadStarted') || flags.GetBool('TimerExpired'))
        return;
    if (Player.IsInState('Conversation'))
        return;

    foreach AllActors(class'Magdalene', mag)
        break;

    if ((mag == None) || (mag.Health <= 0) || mag.IsInState('Dying') ||
        mag.IsInState('Conversation') || (mag.Orders != 'Following'))
        return;

    dist = VSize(mag.Location - Player.Location);
    if (dist <= MAG_CATCHUP_DIST)
        return;

    foreach AllActors(class'Actor', a)
    {
        if ((a.Event == 'MiniGameDispatcher') || (a.Event == TUBE_BUTTON_TAG))
        {
            button = a;
            break;
        }
    }
    if ((button == None) || (VSize(Player.Location - button.Location) > 1500))
        return;

    // Out of sight only, so nobody watches her appear.
    if (Player.LineOfSightTo(mag))
        return;

    facing = Player.Rotation;
    facing.Pitch = 0;
    behind = Player.Location - 150 * vector(facing);
    if (!FastTrace(behind, Player.Location))
        return;

    if (mag.SetLocation(behind))
    {
        mag.SetRotation(facing);
        Log("CNN L2: Magdalene caught up behind the player (was " $ dist $ " units away)");
    }
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

    // MUTINY (worst) -- Gray Goo consumes LA. Death is judged immediately,
    // without waiting for the level's final beat, whether it happens before
    // the upload or during it. The GDD (L2_UploadTimerCheck) sends a death
    // during the upload to the sad Transcendence instead, but that shares
    // 06_Transcend and its quote with surviving the upload, so dying would
    // have been a shortcut to the same screen. Deliberate departure,
    // user-decided 2026-09-24.
    // Giving up to Mephistopheles in the social boss scene ("CAUSE AN
    // APOCALYPSE") ends the same way, once the scene is over (authors'
    // flowchart; user, 2026-10-02).
    if (flags.GetBool('PlayerDiedOnL2') || flags.GetBool('PlayerDiedDuringUpload') ||
        (flags.GetBool('PlayerGaveUp') && !Player.IsInState('Conversation')))
    {
        TravelToEnding(MAP_MUTINY);
        return;
    }

    // The three living endings are three choices after Magdalene proposes
    // the hijack (GDD, L2_QuestImplementation.txt Phases 5-8; "variant A",
    // user-decided 2026-09-24). Her conversation opens the bridge and starts
    // the MJ12 arrival countdown -- see UpdateMJ12Countdown().

    // HIJACKING (best) -- Tantalus clears the bridge and takes the ship's
    // wheel before MJ12 arrive, with Magdalene alive. See CheckShipsWheel().
    if (flags.GetBool('TookSteeringWheel'))
    {
        TravelToEnding(MAP_HIJACKING);
        return;
    }

    // TRANSCEND -- the upload in the tube. The button closes the tube, starts
    // Magdalene's goodbye (MagdaleneInsideTube) if she is in it, a 60 s
    // upload countdown (CNNEventTimer) and the avatar spawner; the level ends
    // only once that minute is survived (TimerExpired). Ending on the goodbye
    // instead cut the fight out entirely -- it played ~7 s after the button
    // (user, 2026-10-02). Where the map's own MapExit pointed before the
    // rename -- see DisableStaleTubeMapExit(). A conversation still playing
    // when the timer runs out finishes first.
    if (flags.GetBool('TimerExpired') && !Player.IsInState('Conversation'))
    {
        TravelToEnding(MAP_TRANSCEND);
        return;
    }

    // CONSPIRACY -- MJ12 docked before either was done. Page wins. Waits a
    // few seconds after the arrival message so it doesn't cut to black.
    if (flags.GetBool('MJ12Arrived') && (mj12ArrivedSeconds >= MJ12_ARRIVAL_GRACE))
        TravelToEnding(MAP_CONSPIRACY);
}

// ----------------------------------------------------------------------
// StartMJ12Countdown() / UpdateMJ12Countdown()
//
// The GDD's hijack window: once Magdalene proposes hijacking the station
// (the end of MagdaleneHijackTheStation sets CanArmMagdalene), MJ12 are on
// their way. The bridge door opens -- nothing in the map or conversations
// ever opened BridgeDoor -- and a countdown starts. It is paused, and its
// window handed over, once the tube upload has started: that path has its
// own countdown, and must not fail into Conspiracy mid-upload. No voiced
// line announces MJ12 (Page's infolink is a panic, not a warning), so the
// countdown is shown with text only.
// ----------------------------------------------------------------------

function StartMJ12Countdown()
{
    local DeusExMover door;
    local DeusExGoal goal;

    flags.SetBool('MJ12TimerStarted', true);
    mj12SecondsLeft = MJ12_COUNTDOWN_SECONDS;
    flags.SetInt('MJ12SecondsLeft', int(mj12SecondsLeft));

    foreach AllActors(class'DeusExMover', door, 'BridgeDoor')
    {
        door.bLocked = false;
        if (door.KeyNum == 0)
            door.DoOpen();
        Log("CNN L2: bridge door " $ door.Name $ " state=" $ door.GetStateName() $ " keyNum=" $ door.KeyNum $ " opening=" $ door.bOpening);
    }

    PrepareSocialBoss();
    MoveMephistophelesNextToWong();

    goal = Player.AddGoal('L2_HijackBeforeMJ12', true);
    if (goal != None)
        goal.SetText(MJ12GoalText);
    Player.ClientMessage(MJ12StartMessage);
    Log("CNN L2: MJ12 countdown started (" $ int(MJ12_COUNTDOWN_SECONDS) $ "s), bridge door opened");
}

function UpdateMJ12Countdown()
{
    local DeusExRootWindow root;

    if (flags.GetBool('MJ12Arrived'))
    {
        mj12ArrivedSeconds += checkTime;
        return;
    }

    if (!flags.GetBool('MJ12TimerStarted'))
    {
        if (flags.GetBool('CanArmMagdalene'))
            StartMJ12Countdown();
        return;
    }

    // The tube upload owns the timer window from here on (CNNEventTimer
    // replaces ours) and the MJ12 clock stops.
    if (flags.GetBool('TantalusUploadStarted'))
    {
        mj12Window = None;
        return;
    }

    // Paused while the social boss scene plays (user, 2026-10-02).
    if (IsSocialBossPlaying())
        return;

    mj12SecondsLeft -= checkTime;
    flags.SetInt('MJ12SecondsLeft', int(mj12SecondsLeft));

    if (mj12Window == None)
    {
        root = DeusExRootWindow(Player.rootWindow);
        if ((root != None) && (root.hud != None))
            mj12Window = class'CNNTimerDisplay'.static.CreateIn(root.hud);
        if (mj12Window != None)
            mj12Window.message = MJ12TimerLabel;
    }
    if (mj12Window != None)
    {
        mj12Window.time = FMax(mj12SecondsLeft, 0);
        mj12Window.bCritical = (mj12SecondsLeft <= 30);
    }

    if (mj12SecondsLeft <= 0)
    {
        flags.SetBool('MJ12Arrived', true);
        if (mj12Window != None)
        {
            mj12Window.bFlash = true;
            mj12Window.Destroy();
            mj12Window = None;
        }
        Player.ClientMessage(MJ12ArrivedMessage);
        Log("CNN L2: MJ12 countdown ran out");
    }
}

// ----------------------------------------------------------------------
// Social Boss (Mephistopheles and Wong at the ship's wheel)
//
// OpheliaL2.con's SocialBoss is written and voiced but never played: its
// hostages are named CorpArmstrongHostage / DrJohnsonHostage /
// SamanthaReedHostage while the pawns sitting on the bridge carry
// CorpArmstrong / DrJohnson / SamanthaReed, and every execution and shot is
// an ET_Comment placeholder the engine skips. This replaces the four avatar
// guards of 2026-09-24 (plan: CNNDocs/L2_SocialBoss_Plan.md, user-approved
// 2026-10-02):
//
//   - at load the bridge hostages take the conversation's names;
//   - when the MJ12 countdown opens the bridge, Wong is armed and an MJ12
//     trooper hostage is placed for the opening execution;
//   - WatchConversation() follows the running conversation every frame and
//     the placeholders are acted out on the speech line after each one, by
//     event index -- comment text loads as garbage, so positions are the
//     only reliable key, and ValidateSocialBoss() checks them at load;
//   - outcomes: GiveUp -> PlayerGaveUp -> Mutiny; ATTACK, or Wong turning
//     on the player after the Chinese branches -> a fight; the wheel opens
//     once Mephistopheles and Wong are both dead.
// ----------------------------------------------------------------------

function ScriptedPawn FindPawnByBindName(string bindName)
{
    local ScriptedPawn p;

    foreach AllActors(class'ScriptedPawn', p)
        if (p.BindName == bindName)
            return p;
    return None;
}

function bool IsAlive(ScriptedPawn p)
{
    return (p != None) && (p.Health > 0) && !p.IsInState('Dying');
}

// The hostages are the pawns already sitting in the bridge corridor; the
// Y/Z test keeps offstage doubles (Samantha has one at Y=+3788) out.
//
// Each also gets its real name for the subtitles: Deus Ex shows the
// UnfamiliarName ("Soldier", "Surgeon") of anyone the player has not
// spoken to yet, and the player meets these three only in this scene
// (reported 2026-10-05).
function RebindHostages()
{
    local ScriptedPawn p;

    foreach AllActors(class'ScriptedPawn', p)
    {
        if ((p.Location.Y > -3500) || (p.Location.Z > -1000))
            continue;
        if (p.BindName == "CorpArmstrong")
            p.BindName = "CorpArmstrongHostage";
        else if (p.BindName == "DrJohnson")
        {
            p.BindName = "DrJohnsonHostage";
            DropAllConversations(p);
        }
        else if (p.BindName == "SamanthaReed")
            p.BindName = "SamanthaReedHostage";
        else
            continue;
        if (p.FamiliarName != "")
            p.UnfamiliarName = p.FamiliarName;
        Log("CNN L2: social boss hostage " $ p.Name $ " -> " $ p.BindName);
    }
}

// Dr. Johnson has no conversation of his own on L2, but the mission's
// conversation packages hand him his L1 ones, which then played when the
// player talked to him here (reported 2026-10-05). SocialBoss is
// Mephistopheles's and binds Johnson by name, so it is unaffected.
function DropAllConversations(Actor a)
{
    local ConListItem item;

    for (item = ConListItem(a.conListItems); item != None; item = item.next)
        if (item.con != None)
            Log("CNN L2: dropped " $ item.con.conName $ " from " $ a.Name);
    a.conListItems = None;
}

// The map gives Magdalene InitialInventory CNNWeaponCoilGun with Count=99,
// meant as ammo, but a weapon's Count spawns that many separate guns: she
// carried 99 coil guns (found 2026-10-05). Keep the one she holds.
function TrimMagdaleneCoilGuns()
{
    local Magdalene mag;
    local Inventory item, next, keep;
    local int n;

    foreach AllActors(class'Magdalene', mag)
    {
        keep = mag.Weapon;
        if ((keep == None) || (keep.Class != class'CNNWeaponCoilGun'))
            keep = mag.FindInventoryType(class'CNNWeaponCoilGun');

        for (item = mag.Inventory; item != None; item = next)
        {
            next = item.Inventory;
            if ((item.Class == class'CNNWeaponCoilGun') && (item != keep))
            {
                mag.DeleteInventory(item);
                item.Destroy();
                n++;
            }
        }
    }
    if (n > 0)
        Log("CNN L2: removed " $ n $ " extra coil guns from Magdalene");
}

// Mephistopheles, Wong and the hostages wear map-specific looks, but their
// classes leave bodies in stock outfits (a plain doctor, a man in a dress
// shirt; reported 2026-10-05). Each gets a carcass class with its own
// mesh, skins and scale.
function SetSocialBossCarcasses()
{
    SetCarcass(FindPawnByBindName("DrMephistopheles"), class'MephistophelesCarcass');
    SetCarcass(FindPawnByBindName("MikeWong"), class'MikeWongCarcass');
    SetCarcass(FindPawnByBindName("CorpArmstrongHostage"), class'CArmstrongDeadCarcass');
    SetCarcass(FindPawnByBindName("SamanthaReedHostage"), class'SamanthaReedCarcass');
}

function SetCarcass(ScriptedPawn p, class<Carcass> carcassClass)
{
    if (p != None)
        p.CarcassType = carcassClass;
}

// Everyone in the scene stays alive until it starts, and the executions
// and the fight happen as written: WongExecutes() and MakeHostile() take
// the protection off the one pawn each needs (user, 2026-10-05). Skipped
// once the scene has started, so re-running level setup cannot make a
// fighting Wong immortal again.
function ProtectSocialBossCast()
{
    if (bSocialBossStarted)
        return;

    Protect(FindPawnByBindName("DrMephistopheles"));
    Protect(FindPawnByBindName("MikeWong"));
    Protect(FindPawnByBindName("CorpArmstrongHostage"));
    Protect(FindPawnByBindName("DrJohnsonHostage"));
    Protect(FindPawnByBindName("SamanthaReedHostage"));
    Protect(sbTrooper);
}

function Protect(ScriptedPawn p)
{
    if (p == None)
        return;
    p.bInvincible = true;
    Log("CNN L2: social boss -- " $ p.Name $ " (" $ p.BindName $ ") protected until the scene");
}

function Conversation FindSocialBossConversation()
{
    local ScriptedPawn meph;
    local ConListItem item;

    meph = FindPawnByBindName("DrMephistopheles");
    if (meph == None)
        return None;
    for (item = ConListItem(meph.conListItems); item != None; item = item.next)
        if ((item.con != None) && (item.con.conName == 'SocialBoss'))
            return item.con;
    return None;
}

function ConEvent SocialBossEvent(Conversation con, int index)
{
    local ConEvent ev;
    local int i;

    for (ev = con.eventList; (ev != None) && (i < index); ev = ev.nextEvent)
        i++;
    return ev;
}

// The event indices below come from the bridge's CONEVENTS dump of the
// shipped .con (2026-10-02). If the conversation is ever re-edited they
// shift, so say so in the log rather than act on the wrong lines.
function ValidateSocialBoss()
{
    local Conversation con;
    local bool bOk;

    con = FindSocialBossConversation();
    if (con == None)
    {
        Log("CNN L2: social boss conversation not found");
        return;
    }

    bOk = (ConEventTrigger(SocialBossEvent(con, SB_TROOPER_SHOT - 1)) != None) &&
          (ConEventSpeech(SocialBossEvent(con, SB_TROOPER_SHOT)) != None) &&
          (ConEventSpeech(SocialBossEvent(con, SB_ARMSTRONG_SHOT)) != None) &&
          (ConEventSpeech(SocialBossEvent(con, SB_JOHNSON_SHOT)) != None) &&
          (ConEventSpeech(SocialBossEvent(con, SB_SAMANTHA_SHOT)) != None) &&
          (ConEventSpeech(SocialBossEvent(con, SB_MEPH_SHOT_A)) != None) &&
          (ConEventSpeech(SocialBossEvent(con, SB_MEPH_SHOT_B)) != None) &&
          (ConEventSpeech(SocialBossEvent(con, SB_WONG_TURNS_A)) != None) &&
          (ConEventSpeech(SocialBossEvent(con, SB_WONG_TURNS_B)) != None) &&
          (SocialBossEvent(con, 56).label == "AttackMeph") &&
          (SocialBossEvent(con, 58).label == "GiveUp");

    if (bOk)
        Log("CNN L2: social boss event layout as expected");
    else
        Log("CNN L2: WARNING social boss event layout changed -- executions may hit the wrong lines");
}

// Called by StartMJ12Countdown(): the bridge is open from here on.
function PrepareSocialBoss()
{
    local ScriptedPawn wong, trooper;
    local vector spot;
    local int i;

    // Normally set by Daedalus's infolink on the main deck, which a player
    // can walk past; the scene must not depend on it.
    flags.SetBool('ReadyForSocialBoss', true);

    wong = FindPawnByBindName("MikeWong");
    if (wong != None)
        GiveWeapon(wong, class'WeaponPistol');

    // The opening execution needs an MJ12 hostage; none stands on the bridge.
    if (wong != None)
    {
        spot = wong.Location + vect(-70, 70, 0);
        trooper = Spawn(class'MJ12Troop',,, spot, wong.Rotation);
        if (trooper == None)
            trooper = Spawn(class'MJ12Troop',,, wong.Location + vect(70, 70, 0), wong.Rotation);
    }
    if (trooper != None)
    {
        for (i = 0; i < ArrayCount(trooper.InitialInventory); i++)
            trooper.InitialInventory[i].Inventory = None;
        trooper.InitializePawn();
        trooper.ChangeAlly('Player', 1, true);
        trooper.SetOrders('Standing', '', true);
        trooper.Tag = 'SocialBossTrooper';   // found again after a load (RestoreSavedState)
        sbTrooper = trooper;
    }
    ProtectSocialBossCast();
    Log("CNN L2: social boss prepared -- Wong armed=" $ (wong != None) $ " MJ12 hostage=" $ (sbTrooper != None));
}

function GiveWeapon(ScriptedPawn p, class<Inventory> weaponClass)
{
    if (p.FindInventoryType(weaponClass) != None)
        return;
    p.InitialInventory[0].Inventory = weaponClass;
    p.InitialInventory[0].Count = 1;
    p.InitializeInventory();
}

// Wong shoots someone on a conversation line. The victim is first taken out
// of the conversation, or its death aborts the whole scene twice over:
// ScriptedPawn.Died() calls AbortConversation while bInConversation, and
// leaving the Conversation state does too unless bConversationEndedNormally,
// and ConPlayBase.ActorDestroyed() terminates it when the pawn is destroyed
// for its carcass while still in ConActorsBound (all three seen in play
// 2026-10-02). Victims are shot after their last line, so dropping them
// from the bound lists is safe.
function WongExecutes(ScriptedPawn victim)
{
    local ScriptedPawn wong;
    local int k;

    if (!IsAlive(victim))
        return;

    wong = FindPawnByBindName("MikeWong");
    victim.bInConversation = false;
    victim.bConversationEndedNormally = true;
    if (Player.conPlay != None)
    {
        for (k = 0; k < ArrayCount(Player.conPlay.ConActorsBound); k++)
            if (Player.conPlay.ConActorsBound[k] == victim)
                Player.conPlay.ConActorsBound[k] = None;
        Player.conPlay.IsConActorInList(victim, true);
    }
    victim.bInvincible = false;
    if (wong != None)
        wong.PlaySound(Sound'DeusExSounds.Weapons.PistolFire', SLOT_None, 2.0);
    victim.TakeDamage(1000, wong, victim.Location + vect(0, 0, 30), vect(0, 0, 0), 'Shot');
    Log("CNN L2: social boss -- Wong shot " $ victim.Name);
}

// ----------------------------------------------------------------------
// WatchConversation() -- runs every frame from Tick()
//
// Conversations play on DeusEx.ConPlay: TantalusDenton's StartConversation
// override (the only place CNN's own ConPlay subclass would be spawned) has
// been commented out since 2020, so nothing can hook ConPlay itself. This
// follows the player's conPlay instead: each new current event is reported
// to ConversationEventStarted(), and each newly started conversation gets
// its skill gates repaired before any choice is shown (PatchChoiceSkills).
// ----------------------------------------------------------------------

function Tick(float deltaTime)
{
    Super.Tick(deltaTime);
    WatchConversation();
}

function WatchConversation()
{
    local ConEvent ev;

    if ((Player == None) || (Player.conPlay == None) || (Player.conPlay.con == None))
    {
        watchedCon = None;
        lastSeenEvent = None;
        return;
    }

    if (Player.conPlay.con != watchedCon)
    {
        watchedCon = Player.conPlay.con;
        lastSeenEvent = None;
        PatchChoiceSkills(watchedCon);
    }
    RepairItemClasses(watchedCon);

    ev = Player.conPlay.currentEvent;
    if ((ev != None) && (ev != lastSeenEvent))
    {
        lastSeenEvent = ev;
        ConversationEventStarted(watchedCon, ev);
    }
}

// ArmMagdalene's assault-gun and napalm branches name item classes the
// engine cannot find: the native bind looks each CheckObject/TransferObject
// up as "DeusEx.<objectName>", so WeaponAssaultRifle (Deus Ex's is
// WeaponAssaultGun) and WeaponSnowblind (a CNN class) come back None, and
// the check fails or nothing is handed over ("Failed to load Class
// DeusEx.WeaponAssaultRifle" in every L2 log). CNNConPlay was written to
// fix this but is never spawned. The bind runs again whenever a
// conversation is looked up, and an event is processed the moment it
// becomes current, so the classes are put back every frame while a
// conversation plays -- it walks one event list, and the item events come
// after spoken lines that wait for audio.
function RepairItemClasses(Conversation con)
{
    local ConEvent ev;

    for (ev = con.eventList; ev != None; ev = ev.nextEvent)
    {
        if ((ConEventTransferObject(ev) != None) && (ConEventTransferObject(ev).giveObject == None))
            ConEventTransferObject(ev).giveObject = ResolveItemClass(ConEventTransferObject(ev).objectName);
        else if ((ConEventCheckObject(ev) != None) && (ConEventCheckObject(ev).checkObject == None))
            ConEventCheckObject(ev).checkObject = ResolveItemClass(ConEventCheckObject(ev).objectName);
    }
}

function class<Inventory> ResolveItemClass(string objName)
{
    local string key;

    key = Caps(objName);
    if (key == "WEAPONASSAULTRIFLE")
        return class'WeaponAssaultGun';
    if ((key == "WEAPONSNOWBLIND") || (key == "APOCALYPSEINSIDE.WEAPONSNOWBLIND"))
        return class'WeaponSnowblind';
    return None;
}

// SocialBoss gates "(Apologize to Wong)" and "(Manipulate Wong)" on skill
// "Chinese", but the engine resolves no class by that name (CNN's is
// AiSkillChinese), leaves skillNeeded None and offered both to every player
// (found 2026-10-02). ConChoice keeps no skill-name string, so the gated
// choices are recognised by their jump labels. The .con asks for level 3
// (Master, as in the authors' flowchart); Trained is enough, Master being
// out of reach in one playthrough (user, 2026-10-02). Runs once the
// conversation has started, i.e. after the engine's own bind.
function PatchChoiceSkills(Conversation con)
{
    local ConEvent ev;
    local ConChoice choice;

    for (ev = con.eventList; ev != None; ev = ev.nextEvent)
    {
        if (ConEventChoice(ev) == None)
            continue;
        for (choice = ConEventChoice(ev).ChoiceList; choice != None; choice = choice.nextChoice)
        {
            if ((choice.skillNeeded == None) &&
                ((choice.choiceLabel == "ApologizetoWong") || (choice.choiceLabel == "ManipulateWong")))
            {
                choice.skillNeeded = class'AiSkillChinese';
                choice.skillLevelNeeded = 1;
            }
        }
    }
}

// Called by WatchConversation() for every event of a conversation as it
// becomes current.
function ConversationEventStarted(Conversation con, ConEvent ev)
{
    local ConEvent scan;
    local int i;

    if ((con == None) || (con.conName != 'SocialBoss'))
        return;

    for (scan = con.eventList; (scan != None) && (scan != ev); scan = scan.nextEvent)
        i++;
    if (scan == None)
        return;

    if (i == 0)
    {
        bSocialBossStarted = true;
        flags.SetBool('SocialBossStarted', true);
        Player.GoalCompleted('MeetDaedalusInTheCommandCenter');
        Log("CNN L2: social boss started, MJ12 timer at " $ int(mj12SecondsLeft) $ "s");
    }

    if (i == SB_TROOPER_SHOT)
        WongExecutes(sbTrooper);
    else if (i == SB_ARMSTRONG_SHOT)
        WongExecutes(FindPawnByBindName("CorpArmstrongHostage"));
    else if (i == SB_JOHNSON_SHOT)
        WongExecutes(FindPawnByBindName("DrJohnsonHostage"));
    else if (i == SB_SAMANTHA_SHOT)
        WongExecutes(FindPawnByBindName("SamanthaReedHostage"));
    else if ((i == SB_MEPH_SHOT_A) || (i == SB_MEPH_SHOT_B))
    {
        flags.SetBool('WongBetrayedMeph', true);
        // Wong turns on the player right after; set it now in case losing
        // the conversation's owner cuts the last lines short.
        SetSocialBossFight();
        WongExecutes(FindPawnByBindName("DrMephistopheles"));
    }
    else if ((i == SB_WONG_TURNS_A) || (i == SB_WONG_TURNS_B))
        SetSocialBossFight();

    if (ev.label == "AttackMeph")
        SetSocialBossFight();
    else if (ev.label == "GiveUp")
        flags.SetBool('PlayerGaveUp', true);
}

function bool IsSocialBossPlaying()
{
    return (Player.conPlay != None) && (Player.conPlay.con != None) &&
           (Player.conPlay.con.conName == 'SocialBoss');
}

// After ATTACK, or once Wong turns on the player, whoever of the two is
// still alive fights; nudged back into Attacking while idle or fleeing
// (both are civilians by class and would otherwise run).
function CheckSocialBossFight()
{
    local ScriptedPawn wong, meph;

    // Every way through the scene ends in the fight or in giving up, but if
    // it is ever cut short, the two must not stay immortal: the wheel only
    // opens over their bodies.
    if (bSocialBossStarted && !bSocialBossReleased && !IsSocialBossPlaying())
    {
        bSocialBossReleased = true;
        wong = FindPawnByBindName("MikeWong");
        meph = FindPawnByBindName("DrMephistopheles");
        if (wong != None)
            wong.bInvincible = false;
        if (meph != None)
            meph.bInvincible = false;
    }

    if (!bSocialBossFight || Player.IsInState('Conversation') || (Player.conPlay != None))
        return;

    wong = FindPawnByBindName("MikeWong");
    meph = FindPawnByBindName("DrMephistopheles");

    if (!bWongHostile && IsAlive(wong))
    {
        MakeHostile(wong);
        bWongHostile = true;
    }
    if (!bMephHostile && IsAlive(meph))
    {
        MakeHostile(meph);
        bMephHostile = true;
    }
    NudgeToAttack(wong);
    NudgeToAttack(meph);
}

function MakeHostile(ScriptedPawn p)
{
    GiveWeapon(p, class'WeaponPistol');
    p.bInvincible = false;
    p.ChangeAlly('Player', -1, true);
    if (Player.Alliance != '')
        p.ChangeAlly(Player.Alliance, -1, true);
    p.bFearHacking = false;
    p.bFearWeapon = false;
    p.bFearShot = false;
    p.bFearInjury = false;
    p.bFearIndirectInjury = false;
    p.bFearCarcass = false;
    p.bFearDistress = false;
    p.bFearAlarm = false;
    p.bFearProjectiles = false;
    p.bHateWeapon = true;
    p.bHateShot = true;
    p.bHateInjury = true;
    Log("CNN L2: social boss -- " $ p.Name $ " turns on the player, MJ12 timer at " $ int(mj12SecondsLeft) $ "s");
}

function NudgeToAttack(ScriptedPawn p)
{
    if (!IsAlive(p))
        return;
    if (p.IsInState('Standing') || p.IsInState('Wandering') || p.IsInState('Fleeing') ||
        p.IsInState('Sitting') || p.IsInState('Conversation'))
    {
        p.SetEnemy(Player, Level.TimeSeconds, true);
        p.GotoState('Attacking');
    }
}

// Mephistopheles (Doctor7, Tag Mephistopheles) stands at (866,-4480), right
// between the approach and the wheel at (861,-4563), so in play he blocks
// frobbing it (reported 2026-09-24). He was first moved behind the wheel;
// the scene reads better with him beside Wong among the hostages (user,
// 2026-10-05). Same floor as Wong (-1352 around (782,-4058), per
// map_probe), so Wong's height works for him too; he faces the way Wong
// does, towards the player's approach. The candidates are tried in order
// in case something stands in the first spot.
function MoveMephistophelesNextToWong()
{
    local ScriptedPawn meph, wong;
    local vector offset[4];
    local rotator facing;
    local int i;

    wong = FindPawnByBindName("MikeWong");
    if (wong == None)
        return;

    offset[0] = vect(63, -50, 0);
    offset[1] = vect(90, 0, 0);
    offset[2] = vect(0, -90, 0);
    offset[3] = vect(-90, 0, 0);
    facing.Yaw = wong.Rotation.Yaw;

    foreach AllActors(class'ScriptedPawn', meph, 'Mephistopheles')
    {
        for (i = 0; i < ArrayCount(offset); i++)
            if (meph.SetLocation(wong.Location + offset[i]))
                break;

        if (i < ArrayCount(offset))
        {
            meph.SetOrders('Standing', '', true);
            meph.SetRotation(facing);
            meph.DesiredRotation = facing;   // Standing otherwise turns him back to face the screens
            Log("CNN L2: moved Mephistopheles next to Wong at " $ meph.Location);
        }
        else
            Log("CNN L2: could not move Mephistopheles next to Wong (blocked)");
    }
}

// The ship's wheel is a breakable decoration and stands right where the
// social boss fight happens: stray pistol fire destroyed it in a test run
// (2026-10-02), after which Hijacking could never be reached.
function ProtectShipsWheel()
{
    local ShipsWheel wheel;

    foreach AllActors(class'ShipsWheel', wheel)
    {
        wheel.bInvincible = true;
        Log("CNN L2: ship's wheel " $ wheel.Name $ " made indestructible");
    }
}

// The wheel opens once Mephistopheles and Wong are both dead -- one rule
// for every way the scene can go (user, 2026-10-02).
function bool IsBridgeClear()
{
    return !IsAlive(FindPawnByBindName("DrMephistopheles")) && !IsAlive(FindPawnByBindName("MikeWong"));
}

// ----------------------------------------------------------------------
// CheckShipsWheel()
//
// Taking the wheel is frobbing ShipsWheel0 on the bridge, which spins it
// (vanilla ShipsWheel.Frob sets bSpinning for 2-7s -- long enough for this
// 1s poll). It only counts while the MJ12 countdown runs, and only with
// Mephistopheles and Wong dead and Magdalene alive: hijacking is her plan, and the ending
// shows her at the wheel. Otherwise the player is told why, once per spin.
// ----------------------------------------------------------------------

function CheckShipsWheel()
{
    local ShipsWheel wheel;
    local Magdalene mag;

    if (flags.GetBool('TookSteeringWheel') || !flags.GetBool('MJ12TimerStarted') ||
        flags.GetBool('MJ12Arrived') || flags.GetBool('TantalusUploadStarted'))
        return;

    foreach AllActors(class'ShipsWheel', wheel)
        break;
    if (wheel == None)
        return;

    if (!wheel.bSpinning)
    {
        bWheelHintShown = false;
        return;
    }

    if (!IsBridgeClear())
    {
        if (!bWheelHintShown)
        {
            bWheelHintShown = true;
            Player.ClientMessage(BridgeNotClearMessage);
            Log("CNN L2: wheel refused, Mephistopheles or Wong still alive");
        }
        return;
    }

    // Magdalene only has to be alive, not at the wheel: she can't get up to
    // the helm platform (found in play 2026-09-24), and it's her plan either
    // way. User-decided.
    foreach AllActors(class'Magdalene', mag)
        break;

    if ((mag != None) && (mag.Health > 0) && !mag.IsInState('Dying'))
    {
        flags.SetBool('TookSteeringWheel', true);
        Log("CNN L2: took the ship's wheel, bridge cleared, Magdalene alive");
    }
    else if (!bWheelHintShown)
    {
        bWheelHintShown = true;
        Player.ClientMessage(WheelNeedsMagdaleneMessage);
    }
}

// ----------------------------------------------------------------------
// Snap() -- L2's part of the bridge's SNAP (save/load audit, 2026-10-05):
// everything a save and a load must carry over, one line per key.
// ----------------------------------------------------------------------

function Snap(TantalusDenton p)
{
    local MJ12Troop troop;
    local DeusExCarcass carc;
    local Mover tube;
    local ShipsWheel wheel;
    local string list;
    local int i, n;

    p.AgentOut("l2.init=" $ initCount $ " mj12=" $ int(mj12SecondsLeft) $ " window=" $ (mj12Window != None));
    p.AgentOut("l2.socialboss=started:" $ bSocialBossStarted $ " fight:" $ bSocialBossFight $
               " wong:" $ bWongHostile $ " meph:" $ bMephHostile $ " released:" $ bSocialBossReleased);

    for (i = 0; i < ArrayCount(trackedFlag); i++)
        if ((trackedFlag[i] != '') && flags.GetBool(trackedFlag[i]))
            list = list $ " " $ trackedFlag[i];
    p.AgentOut("l2.flags=" $ list);

    SnapPawn(p, FindPawnByBindName("Magdalene"));
    SnapPawn(p, FindPawnByBindName("DrMephistopheles"));
    SnapPawn(p, FindPawnByBindName("MikeWong"));
    SnapPawn(p, FindPawnByBindName("CorpArmstrongHostage"));
    SnapPawn(p, FindPawnByBindName("DrJohnsonHostage"));
    SnapPawn(p, FindPawnByBindName("SamanthaReedHostage"));
    SnapPawn(p, FindPawnByBindName("MJ12Sergeant"));
    SnapPawn(p, sbTrooper);

    n = 0;
    foreach AllActors(class'MJ12Troop', troop)
        n++;
    p.AgentOut("l2.count mj12troop=" $ n);
    n = 0;
    foreach AllActors(class'DeusExCarcass', carc)
        n++;
    p.AgentOut("l2.count carcasses=" $ n);

    foreach AllActors(class'Mover', tube, 'CNNMoverTube')
        p.AgentOut("l2.tube keyNum=" $ tube.KeyNum $ " z=" $ int(tube.Location.Z) $ " base=" $ int(tube.BasePos.Z));
    foreach AllActors(class'ShipsWheel', wheel)
        p.AgentOut("l2.wheel invincible=" $ wheel.bInvincible);
}

function SnapPawn(TantalusDenton p, ScriptedPawn sp)
{
    local Inventory item;
    local int n;

    if (sp == None)
        return;
    for (item = sp.Inventory; item != None; item = item.Inventory)
        n++;
    p.AgentOut("pawn." $ sp.BindName $ "=" $ sp.Name $ " alive=" $ IsAlive(sp) $ " health=" $ sp.Health $
               " state=" $ sp.GetStateName() $ " orders=" $ sp.Orders $ " invincible=" $ sp.bInvincible $
               " weapon=" $ sp.Weapon $ " items=" $ n $ " carcass=" $ sp.CarcassType $
               " name=" $ sp.UnfamiliarName $ " cons=" $ (sp.conListItems != None) $
               " loc=" $ int(sp.Location.X) $ "," $ int(sp.Location.Y));
}

function TravelToEnding(string endMapName)
{
    local DeusExRootWindow root;

    // Travelling within mission 6 saves L2 first, and that save walks the
    // HUD. Dying during the upload countdown left an aug icon whose
    // clientObject pointed at a freed object, and the save GPFed on it
    // (FArchiveSaveTagExports <- IwHUDActiveAug.clientObject, 2026-09-24).
    // L2's HUD is never shown again after an ending, so drop those
    // references rather than chase which object went first.
    root = DeusExRootWindow(Player.rootWindow);
    if ((root != None) && (root.hud != None) && (IwHUDActiveItemsDisplay(root.hud.activeItems) != None))
        IwHUDActiveItemsDisplay(root.hud.activeItems).ClearAugmentationDisplay();

    // The root window travels with the player; don't carry the MJ12
    // countdown onto the ending map.
    if (mj12Window != None)
    {
        mj12Window.Destroy();
        mj12Window = None;
    }

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
    trackedFlag(22)=MagdaleneArmed
    trackedFlag(23)=MJ12TimerStarted
    trackedFlag(24)=MJ12Arrived
    trackedFlag(25)=PlayerGaveUp
    trackedFlag(26)=WongBetrayedMeph
    trackedFlag(27)=SocialBossStarted
    trackedFlag(28)=SocialBossFight
    MJ12GoalText="Hijack the station: clear Page's avatars off the bridge and take the ship's wheel with Magdalene before MJ12 arrive. Or upload yourselves in the Avatar Lab tube."
    BridgeNotClearMessage="Mephistopheles and Wong still hold the bridge."
    MJ12StartMessage="MJ12 are on their way. The bridge is open."
    MJ12TimerLabel="MJ12 ARRIVAL"
    MJ12ArrivedMessage="MJ12 have docked with Ophelia."
    WheelNeedsMagdaleneMessage="Without Magdalene there is no one to fly her with."
}
