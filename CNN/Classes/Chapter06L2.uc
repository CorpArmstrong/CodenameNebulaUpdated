//-----------------------------------------------------------
// Mission L2
//-----------------------------------------------------------
class Chapter06L2 extends MissionScript;

var(ChangeLevelOnDeath) string levelName;

// Ending maps
const MAP_MUTINY     = "06_Mutiny";
const MAP_CONSPIRACY = "06_Conspiracy";
const MAP_HIJACKING  = "06_Hijacking";
const MAP_TRANSCEND  = "06_Transcend";

// The tube button triggers this script -- see RouteTubeButton().
const TUBE_BUTTON_TAG = 'CNNTubeButton';
// Tube glass bottom below its mover origin -- see FixTubeMover().
const TUBE_GLASS_BOTTOM = 50.0;
// How far Magdalene may trail the player near the tube lab before she
// catches up -- see BringMagdaleneToTube().
const MAG_CATCHUP_DIST = 300;

// Log the tracked flags whenever they change.
var(Debug) bool bLogFlagChanges;

// The flags to log, polled every Timer tick. A fixed list: FlagBase's
// iterator needs an enum the CNN package cannot name. Bytes, as UE1 has
// no bool arrays.
const MAX_TRACKED_FLAGS = 32;
var(Debug) Name trackedFlag[32];
var byte  trackedValue[32];
var int   trackedCount;
var bool  bTrackingPrimed;

var bool  bEndingTriggered;
var float levelSeconds;

// Log Magdalene's orders, enemy and alliance whenever they change.
var(Debug) bool bLogMagdalene;
var Magdalene watchedMagdalene;
var name      lastMagOrders;
var string    lastMagEnemy;
var bool      bMagWatchPrimed;
var bool      bSoldierFallbackDone;
var bool      bTubeLogged;
var float     tubeLogDelay;

// MJ12 arrival countdown -- see StartMJ12Countdown().
const MJ12_COUNTDOWN_SECONDS = 240.0;
const MJ12_ARRIVAL_GRACE     = 3.0;

// SocialBoss events acted out by this script -- see ValidateSocialBoss().
// Each is the spoken line after the placeholder: lines wait for their
// audio, so the per-frame watch never misses them.
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

    // The map's level info has no MapName, and saves are named after it.
    if ((dxInfo != none) && (dxInfo.mapName == ""))
    {
        dxInfo.mapName = "06_OpheliaL2";
        localURL = Caps(dxInfo.mapName);
    }
    initCount++;
    Log("CNN L2: InitStateMachine run " $ initCount $ ", PlayerTraveling=" $ flags.GetBool('PlayerTraveling'));
    FirstFrame();
    PrepareFirstFrame();
}

function PrepareFirstFrame()
{
    local Inventory anItem, nextItem;

    // Dying on L1 sends the player here, healed and with nothing -- once, as
    // this runs again on every load.
    if (flags.GetBool('PlayerDied') && !flags.GetBool('PlayerDiedHandledOnL2'))
    {
        flags.SetBool('PlayerDiedHandledOnL2', true);
        Player.RestoreAllHealth();

        // As in Mission05: the keyring and non-inventory items stay.
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
// The Page / Samantha Reed storyline is not built on L2: Page's infolink
// sends the player to the Gravity Lab, where nothing plays. Switch the
// thread off -- the infolink, the meeting trigger and her conversations.
// The Uber Alles holocomm is not part of it.
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
    if (goal != none)
        Player.DeleteGoal(goal);
}

// ----------------------------------------------------------------------
// RemoveStrayL1Conversations()
//
// Two L1 conversations (Meet1InspRoom, ApproachingOphelia) are gated on
// OnLevel2 and their owners exist here too, so they would play on L2 in
// place of the real ones.
// ----------------------------------------------------------------------

function RemoveStrayL1Conversations()
{
    StripConversation('Meet1InspRoom');
    StripConversation('ApproachingOphelia');
}

// ----------------------------------------------------------------------
// DedupeConversations()
//
// Chapter06.con also holds copies of most L2 conversations -- same name,
// same owner -- and the first match is the one that plays. Some copies
// are empty stubs that set none of L2's flags. Keep one copy per name:
// the last one with events, else the last one.
// ----------------------------------------------------------------------

function DedupeConversations()
{
    local Actor a;

    foreach AllActors(class'Actor', a)
    {
        if (a.conListItems != none)
            DedupeOneActor(a);
    }
}

function bool ConNameHasNonEmptyCopy(Actor a, Name conName)
{
    local ConListItem scan;

    scan = ConListItem(a.conListItems);
    while (scan != none)
    {
        if ((scan.con != none) && (scan.con.conName == conName) && (scan.con.eventList != none))
            return true;
        scan = scan.next;
    }
    return false;
}

function bool IsLastOccurrence(ConListItem item, bool bNonEmptyOnly)
{
    local ConListItem scan;

    scan = item.next;
    while (scan != none)
    {
        if ((scan.con != none) && (scan.con.conName == item.con.conName) &&
            (!bNonEmptyOnly || (scan.con.eventList != none)))
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

    prev = none;
    item = ConListItem(a.conListItems);

    while (item != none)
    {
        next = item.next;

        if (item.con == none)
        {
            bKeep = true;
        }
        else
        {
            bThisNonEmpty = (item.con.eventList != none);
            bAnyNonEmpty = ConNameHasNonEmptyCopy(a, item.con.conName);

            if (bAnyNonEmpty)
                bKeep = bThisNonEmpty && IsLastOccurrence(item, true);
            else
                bKeep = IsLastOccurrence(item, false);
        }

        if (!bKeep)
        {
            if (prev == none)
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
// Logs the conversations of the level's key actors, in the order the
// engine checks them, with their flags.
// ----------------------------------------------------------------------

function DumpConversationLists()
{
    local Actor a;

    foreach AllActors(class'Actor', a)
    {
        if ((a.conListItems == none) || (a.BindName == ""))
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

    while (item != none)
    {
        if (item.con != none)
        {
            flagList = "";
            flagRef  = item.con.flagRefList;

            while (flagRef != none)
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
        if (a.conListItems == none)
            continue;

        prev = none;
        item = ConListItem(a.conListItems);

        while (item != none)
        {
            if ((item.con != none) && (item.con.conName == conName))
            {
                // Unlink, keeping the rest of the actor's list intact.
                if (prev == none)
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
// Magdalene must be inside the tube when its glass comes down. The button
// is made to trigger this script, which puts her at MagdalenePoint and
// then fires the map's own MiniGameDispatcher.
// ----------------------------------------------------------------------

function RouteTubeButton()
{
    local Actor a;

    // after a load the button is rerouted already; the Tag is still needed
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
    if ((mag == none) || (mag.Health <= 0) || mag.IsInState('Dying'))
        return;

    // MagdalenePoint is the tube's centre -- see FixTubeMover().
    foreach AllActors(class'Actor', point, 'MagdalenePoint')
        break;
    if (point == none)
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
// The tube glass is mis-keyed in the map: it closes diagonally beside
// MagdalenePoint and too low. Make it drop straight down over the base,
// stopping on the floor traced under her, and pass through her rather
// than bounce. The open glass stays where the map put it.
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

        if ((point != none) &&
            (Trace(hitLocation, hitNormal, point.Location - vect(0,0,300),
                   point.Location + vect(0,0,40), true) != none))
        {
            tube.BasePos.Z = hitLocation.Z + TUBE_GLASS_BOTTOM;
        }

        tube.KeyPos[1] = openPos - tube.BasePos;
        Log("CNN L2: tube mover " $ tube.Name $ " closes straight down onto " $
            tube.BasePos $ " (floor " $ hitLocation.Z $ "), open key " $ tube.KeyPos[1] $
            ", keyNum=" $ tube.KeyNum $ " loc=" $ tube.Location);
    }
}

// Logs where the tube glass is a few seconds after the button.
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
// Only the end of MeetSoldiers opens the way down to the lower labs. If
// the MJ12 sergeant dies before that talk, do what it would have done.
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

    if ((sergeant != none) && (sergeant.Health > 0) && !sergeant.IsInState('Dying'))
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
// The end of the upload countdown fires a MapExit to "transcendence", a
// map that no longer exists. CheckEndingReached() takes that ending.
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
// CommCenterDispatcher fires MJ12OrdersTrigger twice and never
// AvatarsOrdersTrigger, so the avatars never join the comm centre fight.
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// RestoreSavedState()
//
// Mission scripts are not saved; each load starts a new one. What must
// survive a load is kept in flags and read back here.
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
            bSocialBossStarted $ " fight=" $ bSocialBossFight $ " trooper=" $ (sbTrooper != none));
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

        // find the duplicate rather than assume its slot
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
// MissionScript.Timer() does not call DoLevelStuff().
// ----------------------------------------------------------------------

function Timer()
{
    super.Timer();
    DoLevelStuff();
}

function DoLevelStuff()
{
    if ((flags == none) || (Player == none))
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
// Notes when the player has given Magdalene one of the ArmMagdalene
// weapons; her own coil gun does not count.
// ----------------------------------------------------------------------

function CheckMagdaleneArmed()
{
    local Magdalene mag;

    if (flags.GetBool('MagdaleneArmed') || !flags.GetBool('CanArmMagdalene'))
        return;

    foreach AllActors(class'Magdalene', mag)
        break;
    if (mag == none)
        return;

    if ((mag.FindInventoryType(class'WeaponPlasmaRifle') != none) ||
        (mag.FindInventoryType(class'WeaponAssaultGun') != none) ||
        (mag.FindInventoryType(class'WeaponSnowblind') != none) ||
        (mag.FindInventoryType(class'WeaponMiniCrossbow') != none) ||
        (mag.FindInventoryType(class'WeaponCrowbar') != none))  // the "mini-crossbow" line actually hands over WeaponCrowbar
    {
        flags.SetBool('MagdaleneArmed', true);
    }
}

// ----------------------------------------------------------------------
// CheckUploadStarted()
//
// The tube button starts the upload countdown; nothing else marks it, and
// death during the upload must be told from death before it.
// ----------------------------------------------------------------------

function CheckUploadStarted()
{
    local CNNEventTimer uploadTimer;

    if (!flags.GetBool('TantalusUploadStarted'))
    {
        foreach AllActors(class'CNNEventTimer', uploadTimer)
        {
            if (uploadTimer.timerWin != none)
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
// The tube scenes need Magdalene close, and she falls behind when she
// stops to fight. Once she is far behind and out of the player's sight,
// she is put a few steps behind him and keeps following. Never after the
// button, and only while she is following.
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

    if ((mag == none) || (mag.Health <= 0) || mag.IsInState('Dying') ||
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
    if ((button == none) || (VSize(Player.Location - button.Location) > 1500))
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
// Endings follow flags set on L2 itself. Order is priority: death first.
// ----------------------------------------------------------------------

function CheckEndingReached()
{
    if (bEndingTriggered)
        return;

    // MUTINY (worst) -- Gray Goo consumes LA. Death, before or during the
    // upload, or giving up to Mephistopheles once the scene is over.
    if (flags.GetBool('PlayerDiedOnL2') || flags.GetBool('PlayerDiedDuringUpload') ||
        (flags.GetBool('PlayerGaveUp') && !Player.IsInState('Conversation')))
    {
        TravelToEnding(MAP_MUTINY);
        return;
    }

    // The living endings follow Magdalene's hijack proposal, which opens the
    // bridge and starts the MJ12 countdown.

    // HIJACKING (best) -- Tantalus clears the bridge and takes the ship's
    // wheel before MJ12 arrive, with Magdalene alive. See CheckShipsWheel().
    if (flags.GetBool('TookSteeringWheel'))
    {
        TravelToEnding(MAP_HIJACKING);
        return;
    }

    // TRANSCEND -- the upload in the tube: the minute of the countdown
    // survived. A conversation still playing finishes first.
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
// Once Magdalene proposes the hijack, MJ12 are on their way: the bridge
// door opens and a countdown starts. It stops when the tube upload starts,
// which has a countdown of its own.
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
    if (goal != none)
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

    // the upload has the timer window from here on
    if (flags.GetBool('TantalusUploadStarted'))
    {
        mj12Window = none;
        return;
    }

    // paused while the social boss scene plays
    if (IsSocialBossPlaying())
        return;

    mj12SecondsLeft -= checkTime;
    flags.SetInt('MJ12SecondsLeft', int(mj12SecondsLeft));

    if (mj12Window == none)
    {
        root = DeusExRootWindow(Player.rootWindow);
        if ((root != none) && (root.hud != none))
            mj12Window = class'CNNTimerDisplay'.static.CreateIn(root.hud);
        if (mj12Window != none)
            mj12Window.message = MJ12TimerLabel;
    }
    if (mj12Window != none)
    {
        mj12Window.time = FMax(mj12SecondsLeft, 0);
        mj12Window.bCritical = (mj12SecondsLeft <= 30);
    }

    if (mj12SecondsLeft <= 0)
    {
        flags.SetBool('MJ12Arrived', true);
        if (mj12Window != none)
        {
            mj12Window.bFlash = true;
            mj12Window.Destroy();
            mj12Window = none;
        }
        Player.ClientMessage(MJ12ArrivedMessage);
        Log("CNN L2: MJ12 countdown ran out");
    }
}

// ----------------------------------------------------------------------
// Social Boss (Mephistopheles and Wong at the ship's wheel)
//
// OpheliaL2.con's SocialBoss is written and voiced, but its hostages carry
// other names than the pawns on the bridge, and its executions and shots
// are comments the engine skips. This script names the hostages, arms
// Wong, follows the conversation and acts out the shots, and starts the
// fight. The wheel opens once Mephistopheles and Wong are both dead.
// ----------------------------------------------------------------------

function ScriptedPawn FindPawnByBindName(string bindName)
{
    local ScriptedPawn p;

    foreach AllActors(class'ScriptedPawn', p)
        if (p.BindName == bindName)
            return p;
    return none;
}

function bool IsAlive(ScriptedPawn p)
{
    return (p != none) && (p.Health > 0) && !p.IsInState('Dying');
}

// The hostages get the conversation's names, and their real names in place
// of "Soldier" or "Surgeon" -- the player meets them only here.
function RebindHostages()
{
    local ScriptedPawn p;

    foreach AllActors(class'ScriptedPawn', p)
    {
        if ((p.Name != 'CorpArmstrong0') && (p.Name != 'DrJohnson0') && (p.Name != 'Female1'))
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

// Dr. Johnson has no conversation of his own on L2; drop the L1 ones.
function DropAllConversations(Actor a)
{
    local ConListItem item;

    for (item = ConListItem(a.conListItems); item != none; item = item.next)
        if (item.con != none)
            Log("CNN L2: dropped " $ item.con.conName $ " from " $ a.Name);
    a.conListItems = none;
}

// The map gives Magdalene 99 coil guns (a weapon Count of 99, meant as
// ammo). Keep the one she holds.
function TrimMagdaleneCoilGuns()
{
    local Magdalene mag;
    local Inventory item, next, keep;
    local int n;

    foreach AllActors(class'Magdalene', mag)
    {
        keep = mag.Weapon;
        if ((keep == none) || (keep.Class != class'CNNWeaponCoilGun'))
            keep = mag.FindInventoryType(class'CNNWeaponCoilGun');

        for (item = mag.Inventory; item != none; item = next)
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

// Their bodies keep the looks the map gives them.
function SetSocialBossCarcasses()
{
    SetCarcass(FindPawnByBindName("DrMephistopheles"), class'MephistophelesCarcass');
    SetCarcass(FindPawnByBindName("MikeWong"), class'MikeWongCarcass');
    SetCarcass(FindPawnByBindName("CorpArmstrongHostage"), class'CArmstrongDeadCarcass');
    SetCarcass(FindPawnByBindName("SamanthaReedHostage"), class'SamanthaReedCarcass');
}

function SetCarcass(ScriptedPawn p, class<Carcass> carcassClass)
{
    if (p != none)
        p.CarcassType = carcassClass;
}

// Everyone in the scene stays alive until it starts. The executions and
// the fight lift this for the pawn concerned.
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
    if (p == none)
        return;
    p.bInvincible = true;
    Log("CNN L2: social boss -- " $ p.Name $ " (" $ p.BindName $ ") protected until the scene");
}

function Conversation FindSocialBossConversation()
{
    local ScriptedPawn meph;
    local ConListItem item;

    meph = FindPawnByBindName("DrMephistopheles");
    if (meph == none)
        return none;
    for (item = ConListItem(meph.conListItems); item != none; item = item.next)
        if ((item.con != none) && (item.con.conName == 'SocialBoss'))
            return item.con;
    return none;
}

function ConEvent SocialBossEvent(Conversation con, int index)
{
    local ConEvent ev;
    local int i;

    for (ev = con.eventList; (ev != none) && (i < index); ev = ev.nextEvent)
        i++;
    return ev;
}

// The event numbers above fit the shipped .con; warn if it ever changes.
function ValidateSocialBoss()
{
    local Conversation con;
    local bool bOk;

    con = FindSocialBossConversation();
    if (con == none)
    {
        Log("CNN L2: social boss conversation not found");
        return;
    }

    bOk = (ConEventTrigger(SocialBossEvent(con, SB_TROOPER_SHOT - 1)) != none) &&
          (ConEventSpeech(SocialBossEvent(con, SB_TROOPER_SHOT)) != none) &&
          (ConEventSpeech(SocialBossEvent(con, SB_ARMSTRONG_SHOT)) != none) &&
          (ConEventSpeech(SocialBossEvent(con, SB_JOHNSON_SHOT)) != none) &&
          (ConEventSpeech(SocialBossEvent(con, SB_SAMANTHA_SHOT)) != none) &&
          (ConEventSpeech(SocialBossEvent(con, SB_MEPH_SHOT_A)) != none) &&
          (ConEventSpeech(SocialBossEvent(con, SB_MEPH_SHOT_B)) != none) &&
          (ConEventSpeech(SocialBossEvent(con, SB_WONG_TURNS_A)) != none) &&
          (ConEventSpeech(SocialBossEvent(con, SB_WONG_TURNS_B)) != none) &&
          (SocialBossEvent(con, 56).label == "AttackMeph") &&
          (SocialBossEvent(con, 58).label == "GiveUp");

    if (bOk)
        Log("CNN L2: social boss event layout as expected");
    else
        Log("CNN L2: WARNING social boss event layout changed -- executions may hit the wrong lines");
}

// The bridge opens: get the scene ready.
function PrepareSocialBoss()
{
    local ScriptedPawn wong, trooper;
    local vector spot;
    local int i;

    // normally set by Daedalus's infolink, which can be missed
    flags.SetBool('ReadyForSocialBoss', true);

    wong = FindPawnByBindName("MikeWong");
    if (wong != none)
        GiveWeapon(wong, class'WeaponPistol');

    // the opening execution needs an MJ12 hostage
    if (wong != none)
    {
        spot = wong.Location + vect(-70, 70, 0);
        trooper = Spawn(class'MJ12Troop',,, spot, wong.Rotation);
        if (trooper == none)
            trooper = Spawn(class'MJ12Troop',,, wong.Location + vect(70, 70, 0), wong.Rotation);
    }
    if (trooper != none)
    {
        for (i = 0; i < ArrayCount(trooper.InitialInventory); i++)
            trooper.InitialInventory[i].Inventory = none;
        trooper.InitializePawn();
        trooper.ChangeAlly('Player', 1, true);
        trooper.SetOrders('Standing', '', true);
        trooper.Tag = 'SocialBossTrooper';   // found again after a load (RestoreSavedState)
        sbTrooper = trooper;
    }
    ProtectSocialBossCast();
    Log("CNN L2: social boss prepared -- Wong armed=" $ (wong != none) $ " MJ12 hostage=" $ (sbTrooper != none));
}

function GiveWeapon(ScriptedPawn p, class<Inventory> weaponClass)
{
    if (p.FindInventoryType(weaponClass) != none)
        return;
    p.InitialInventory[0].Inventory = weaponClass;
    p.InitialInventory[0].Count = 1;
    p.InitializeInventory();
}

// Wong shoots someone during the conversation. The victim is taken out of
// it first; a participant's death would end the scene.
function WongExecutes(ScriptedPawn victim)
{
    local ScriptedPawn wong;
    local int k;

    if (!IsAlive(victim))
        return;

    wong = FindPawnByBindName("MikeWong");
    victim.bInConversation = false;
    victim.bConversationEndedNormally = true;
    if (Player.conPlay != none)
    {
        for (k = 0; k < ArrayCount(Player.conPlay.ConActorsBound); k++)
            if (Player.conPlay.ConActorsBound[k] == victim)
                Player.conPlay.ConActorsBound[k] = none;
        Player.conPlay.IsConActorInList(victim, true);
    }
    victim.bInvincible = false;
    if (wong != none)
        wong.PlaySound(Sound'DeusExSounds.Weapons.PistolFire', SLOT_None, 2.0);
    victim.TakeDamage(1000, wong, victim.Location + vect(0, 0, 30), vect(0, 0, 0), 'Shot');
    Log("CNN L2: social boss -- Wong shot " $ victim.Name);
}

// ----------------------------------------------------------------------
// WatchConversation()
//
// Follows the player's conversation every frame: repairs a new
// conversation's skill gates and item classes, and reports each event
// as it comes up.
// ----------------------------------------------------------------------

function Tick(float deltaTime)
{
    Super.Tick(deltaTime);
    WatchConversation();
}

function WatchConversation()
{
    local ConEvent ev;

    if ((Player == none) || (Player.conPlay == none) || (Player.conPlay.con == none))
    {
        watchedCon = none;
        lastSeenEvent = none;
        return;
    }

    if (Player.conPlay.con != watchedCon)
    {
        watchedCon = Player.conPlay.con;
        lastSeenEvent = none;
        PatchChoiceSkills(watchedCon);
    }
    RepairItemClasses(watchedCon);

    ev = Player.conPlay.currentEvent;
    if ((ev != none) && (ev != lastSeenEvent))
    {
        lastSeenEvent = ev;
        ConversationEventStarted(watchedCon, ev);
    }
}

// ArmMagdalene names WeaponAssaultRifle and WeaponSnowblind, which the
// engine looks up in DeusEx and does not find. Put the right classes back
// every frame, since each conversation lookup clears them again.
function RepairItemClasses(Conversation con)
{
    local ConEvent ev;

    for (ev = con.eventList; ev != none; ev = ev.nextEvent)
    {
        if ((ConEventTransferObject(ev) != none) && (ConEventTransferObject(ev).giveObject == none))
            ConEventTransferObject(ev).giveObject = ResolveItemClass(ConEventTransferObject(ev).objectName);
        else if ((ConEventCheckObject(ev) != none) && (ConEventCheckObject(ev).checkObject == none))
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
    return none;
}

// "(Apologize to Wong)" and "(Manipulate Wong)" ask for a skill named
// "Chinese", which does not resolve, so anyone could pick them. Gate them
// on AiSkillChinese at Trained.
function PatchChoiceSkills(Conversation con)
{
    local ConEvent ev;
    local ConChoice choice;

    for (ev = con.eventList; ev != none; ev = ev.nextEvent)
    {
        if (ConEventChoice(ev) == none)
            continue;
        for (choice = ConEventChoice(ev).ChoiceList; choice != none; choice = choice.nextChoice)
        {
            if ((choice.skillNeeded == none) &&
                ((choice.choiceLabel == "ApologizetoWong") || (choice.choiceLabel == "ManipulateWong")))
            {
                choice.skillNeeded = class'AiSkillChinese';
                choice.skillLevelNeeded = 1;
            }
        }
    }
}

// Called for every event of a conversation as it comes up.
function ConversationEventStarted(Conversation con, ConEvent ev)
{
    local ConEvent scan;
    local int i;

    if ((con == none) || (con.conName != 'SocialBoss'))
        return;

    for (scan = con.eventList; (scan != none) && (scan != ev); scan = scan.nextEvent)
        i++;
    if (scan == none)
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
        // Wong turns on the player right after
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
    return (Player.conPlay != none) && (Player.conPlay.con != none) &&
           (Player.conPlay.con.conName == 'SocialBoss');
}

// After ATTACK, or once Wong turns, whoever of the two is alive fights.
// Both are civilians and would run, so keep them attacking.
function CheckSocialBossFight()
{
    local ScriptedPawn wong, meph;

    // if the scene is cut short, the two must not stay immortal
    if (bSocialBossStarted && !bSocialBossReleased && !IsSocialBossPlaying())
    {
        bSocialBossReleased = true;
        wong = FindPawnByBindName("MikeWong");
        meph = FindPawnByBindName("DrMephistopheles");
        if (wong != none)
            wong.bInvincible = false;
        if (meph != none)
            meph.bInvincible = false;
    }

    if (!bSocialBossFight || Player.IsInState('Conversation') || (Player.conPlay != none))
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

// Mephistopheles stands in front of the wheel and blocks it. Put him
// beside Wong, facing the same way.
function MoveMephistophelesNextToWong()
{
    local ScriptedPawn meph, wong;
    local vector offset[4];
    local rotator facing;
    local int i;

    wong = FindPawnByBindName("MikeWong");
    if (wong == none)
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

// The wheel stands in the line of fire, and without it there is no
// Hijacking.
function ProtectShipsWheel()
{
    local ShipsWheel wheel;

    foreach AllActors(class'ShipsWheel', wheel)
    {
        wheel.bInvincible = true;
        Log("CNN L2: ship's wheel " $ wheel.Name $ " made indestructible");
    }
}

// The wheel opens once Mephistopheles and Wong are both dead.
function bool IsBridgeClear()
{
    return !IsAlive(FindPawnByBindName("DrMephistopheles")) && !IsAlive(FindPawnByBindName("MikeWong"));
}

// ----------------------------------------------------------------------
// CheckShipsWheel()
//
// Spinning the wheel takes the ship, while the MJ12 countdown runs, with
// Mephistopheles and Wong dead and Magdalene alive. Otherwise the player
// is told why, once per spin.
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
    if (wheel == none)
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

    // she only has to be alive; she cannot reach the helm platform
    foreach AllActors(class'Magdalene', mag)
        break;

    if ((mag != none) && (mag.Health > 0) && !mag.IsInState('Dying'))
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
// Snap()
//
// L2's part of the bridge's SNAP: what a save and a load must carry over.
// ----------------------------------------------------------------------

function Snap(TantalusDenton p)
{
    local MJ12Troop troop;
    local DeusExCarcass carc;
    local Mover tube;
    local ShipsWheel wheel;
    local string list;
    local int i, n;

    if (flags == none)
    {
        p.AgentOut("l2.init=0 (mission script not started yet)");
        return;
    }
    p.AgentOut("l2.init=" $ initCount $ " mj12=" $ int(mj12SecondsLeft) $ " window=" $ (mj12Window != none));
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

    if (sp == none)
        return;
    for (item = sp.Inventory; item != none; item = item.Inventory)
        n++;
    p.AgentOut("pawn." $ sp.BindName $ "=" $ sp.Name $ " alive=" $ IsAlive(sp) $ " health=" $ sp.Health $
               " state=" $ sp.GetStateName() $ " orders=" $ sp.Orders $ " invincible=" $ sp.bInvincible $
               " weapon=" $ sp.Weapon $ " items=" $ n $ " carcass=" $ sp.CarcassType $
               " name=" $ sp.UnfamiliarName $ " cons=" $ (sp.conListItems != none) $
               " loc=" $ int(sp.Location.X) $ "," $ int(sp.Location.Y));
}

function TravelToEnding(string endMapName)
{
    local DeusExRootWindow root;

    // The level is saved on the way out, and a dead aug icon in the HUD can
    // crash that save. The HUD is not shown again, so clear its icons.
    root = DeusExRootWindow(Player.rootWindow);
    if ((root != none) && (root.hud != none) && (IwHUDActiveItemsDisplay(root.hud.activeItems) != none))
        IwHUDActiveItemsDisplay(root.hud.activeItems).ClearAugmentationDisplay();

    // don't carry the MJ12 countdown onto the ending map
    if (mj12Window != none)
    {
        mj12Window.Destroy();
        mj12Window = none;
    }

    bEndingTriggered = true;
    flags.SetBool('IsGameCompleted', true);
    Log("CNN L2: ending reached after " $ int(levelSeconds) $ "s -> " $ endMapName);
    Level.Game.SendPlayer(Player, endMapName);
}

// ----------------------------------------------------------------------
// LogChangedFlags()
//
// Logs a tracked flag the first time it is seen and whenever it changes.
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
// Logs Magdalene's orders, enemy and alliance when they change.
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

        if (watchedMagdalene == none)
        {
            Log("CNN L2 magdalene: no Magdalene actor in this level");
            return;
        }
    }

    if (watchedMagdalene == none)
        return;

    if (watchedMagdalene.Enemy != none)
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

    // The flags OpheliaL2.con uses, and the ones this script sets.
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
