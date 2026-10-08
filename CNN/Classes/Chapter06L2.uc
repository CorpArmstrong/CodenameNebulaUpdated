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
// Dr Reed's stateroom door -- see SetupReedStateroom().
const REED_DOOR_TAG  = 'door_lab1';
const REED_DOOR_CODE = "011235";   // the code Samantha gives

var bool  bEndingTriggered;
var bool  bSoldierFallbackDone;

// MJ12 arrival countdown -- see StartMJ12Countdown().
const MJ12_COUNTDOWN_SECONDS = 240.0;
const MJ12_ARRIVAL_GRACE     = 3.0;

var float        mj12SecondsLeft;
var float        mj12ArrivedSeconds;
var transient TimerDisplay mj12Window;   // never saved -- see CNNEventTimer.timerWin
var bool         bWheelHintShown;
var CNNSocialBoss socialBoss;
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
    StartSocialBoss();
    ProtectShipsWheel();
    DisablePageAndSamantha();
    SetupReedStateroom();
}

// The scene keeps its own state and is saved with the level; after a load
// it is found again.
function StartSocialBoss()
{
    foreach AllActors(class'CNNSocialBoss', socialBoss)
        break;
    if (socialBoss == none)
        socialBoss = Spawn(class'CNNSocialBoss');
    socialBoss.LevelStart(Player);
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
// SetupReedStateroom()
//
// Dr Reed's stateroom, up the Gravity Lab shaft, holds the archive
// recordings of Wong. Its door takes the code Samantha gives and opens
// from inside too, not from the light switch by it. The two placeholder
// voice tapes go, and the archive's Wong stands where its camera sees him.
// ----------------------------------------------------------------------

function SetupReedStateroom()
{
    local DeusExMover door;
    local Keypad pad;
    local LightSwitch lightSwitch;
    local VoiceTape tape;
    local SecurityCamera cam;
    local ScriptedPawn p, wong;
    local vector loc;

    foreach AllActors(class'DeusExMover', door, REED_DOOR_TAG)
        break;
    if (door == none)
        return;

    // the crew quarters have a keypad on the same event, far away
    foreach AllActors(class'Keypad', pad)
    {
        if (VSize(pad.Location - door.Location) > 400)
            continue;
        pad.Event = REED_DOOR_TAG;
        pad.validCode = REED_DOOR_CODE;
        pad.bToggleLock = false;   // the inside one kept the default: it only toggled the lock
    }

    foreach AllActors(class'LightSwitch', lightSwitch)
        if (lightSwitch.Event == REED_DOOR_TAG)
            lightSwitch.Event = '';

    foreach AllActors(class'VoiceTape', tape)
        if ((tape.conversationName == "DL_MeganReedsRoom") || (tape.conversationName == "DL_CaptainTalksWithWong"))
            tape.Destroy();

    // the camera looks straight down; he stood at the edge of its view
    foreach AllActors(class'SecurityCamera', cam, 'ReedRecord')
        break;
    foreach AllActors(class'ScriptedPawn', p)
        if (p.BindName == "MichaelWong")
            wong = p;
    if ((cam != none) && (wong != none))
    {
        loc = cam.Location;
        loc.X += 45;
        loc.Z = wong.Location.Z;
        wong.SetLocation(loc);
    }
}

// ----------------------------------------------------------------------
// CheckWongVideo()
//
// Logging in to the stateroom's security computer shows the archive
// recordings that "(Manipulate Wong)" in the Social Boss scene speaks of
// -- see CNNSocialBoss.PatchVideoFlag().
// ----------------------------------------------------------------------

function CheckWongVideo()
{
    local ComputerSecurity comp;

    if (flags.GetBool('PlayerSawWongVideo'))
        return;

    foreach AllActors(class'ComputerSecurity', comp)
    {
        if ((comp.Views[1].cameraTag == 'ReedRecord') && (comp.termwindow != none) &&
            (ComputerScreenSecurity(comp.termwindow.winComputer) != none))
        {
            flags.SetBool('PlayerSawWongVideo', true);
            Log("CNN L2: player saw Wong's archive recordings");
        }
    }
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
    if (flags.GetBool('MJ12TimerStarted') && !flags.GetBool('MJ12Arrived'))
    {
        mj12SecondsLeft = flags.GetInt('MJ12SecondsLeft');
        if (mj12SecondsLeft <= 0)
            mj12SecondsLeft = MJ12_COUNTDOWN_SECONDS;   // a save from before the flag existed
        Log("CNN L2: restored -- MJ12 " $ int(mj12SecondsLeft) $ "s");
    }
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

    CheckMagdaleneArmed();
    CheckUploadStarted();
    UpdateMJ12Countdown();
    CheckShipsWheel();
    CheckSoldierSoftlock();
    CheckWongVideo();
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

    if (socialBoss != none)
        socialBoss.Prepare();

    goal =Player.AddGoal('L2_HijackBeforeMJ12', true);
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
    if ((socialBoss != none) && socialBoss.IsPlaying())
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

// ----------------------------------------------------------------------
// Tick() / RepairItemClasses()
//
// ArmMagdalene names WeaponAssaultRifle and WeaponSnowblind, which the
// engine looks up in DeusEx and does not find. Put the right classes back
// every frame, since each conversation lookup clears them again.
// ----------------------------------------------------------------------

function Tick(float deltaTime)
{
    Super.Tick(deltaTime);

    if ((Player != none) && (Player.conPlay != none) && (Player.conPlay.con != none))
        RepairItemClasses(Player.conPlay.con);
}

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
    return (socialBoss == none) || socialBoss.IsBridgeClear();
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
    Log("CNN L2: ending reached -> " $ endMapName);
    Level.Game.SendPlayer(Player, endMapName);
}

defaultproperties
{
    levelName="06_OpheliaL2#HumanServer"
    MJ12GoalText="Hijack the station: clear Page's avatars off the bridge and take the ship's wheel with Magdalene before MJ12 arrive. Or upload yourselves in the Avatar Lab tube."
    BridgeNotClearMessage="Mephistopheles and Wong still hold the bridge."
    MJ12StartMessage="MJ12 are on their way. The bridge is open."
    MJ12TimerLabel="MJ12 ARRIVAL"
    MJ12ArrivedMessage="MJ12 have docked with Ophelia."
    WheelNeedsMagdaleneMessage="Without Magdalene there is no one to fly her with."
}
