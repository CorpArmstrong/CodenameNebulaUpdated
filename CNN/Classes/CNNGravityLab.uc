//-----------------------------------------------------------------------
// Class:    CNNGravityLab
//-----------------------------------------------------------------------
// Samantha Reed and Wong in Hawking's gravity lab on L2. President Mead's
// holocomm message and Page's infolink send the player to Page's daughter
// there, and OpheliaL2.con's MeetSamanthaReed and SamGivesQuest are
// written for it, but the two stood in a sealed room. This actor puts them
// in the lab and sends them off after the meeting -- Wong alone when the
// player sided with Samantha, both otherwise -- and closes the goals that
// lead to them. Spawned by Chapter06L2; being a level actor, it is saved
// with the game.
//-----------------------------------------------------------------------
class CNNGravityLab extends Info;

// Where they walk off to: the lab's south doorway, towards the Command
// Center. The lab has no path nodes, so it is a spawned spot.
const EXIT_TAG = 'CNNGravityLabExit';
// Where the meeting's closing trigger points instead -- see PatchMeeting().
const MEETING_TRIGGER_TAG = 'CNNGravityLabMeeting';

var DeusExPlayer Player;
var ScriptedPawn samantha;
var ScriptedPawn wong;
var bool bPlaced;
var bool bMeetingDone;
var bool bSamanthaLeaving;
var bool bWongLeaving;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(1.0, true);
}

// ----------------------------------------------------------------------
// LevelStart()
//
// Called by the mission script each time the level starts, a load
// included.
// ----------------------------------------------------------------------

function LevelStart(DeusExPlayer p)
{
    Player = p;
    samantha = FindPawn("SamanthaReed");   // the bridge hostage is renamed by CNNSocialBoss
    wong = FindPawn("MikeWong1");

    DisableOldTrigger();
    SpawnExit();
    PatchMeeting();
    if (!bPlaced)
        PlaceInLab();

    // the conversation lists are rebuilt on load
    if (bMeetingDone)
        DropConversation(samantha, 'MeetSamanthaReed');
    if (bSamanthaLeaving)
        DropConversation(samantha, 'SamGivesQuest');
}

function ScriptedPawn FindPawn(string bindName)
{
    local ScriptedPawn p;

    foreach AllActors(class'ScriptedPawn', p)
        if (p.BindName == bindName)
            return p;
    return none;
}

function Conversation FindConversation(Actor a, name conName)
{
    local ConListItem item;

    if (a == none)
        return none;
    for (item = ConListItem(a.conListItems); item != none; item = item.next)
        if ((item.con != none) && (item.con.conName == conName))
            return item.con;
    return none;
}

// The map's MeetSamanthaReed trigger stands by the Command Center, far
// from her; the conversation starts on approach instead.
function DisableOldTrigger()
{
    local ConversationTrigger t;

    foreach AllActors(class'ConversationTrigger', t)
    {
        if (t.conversationTag == 'MeetSamanthaReed')
        {
            t.conversationTag = '';
            t.SetCollision(false, false, false);
        }
    }
}

function SpawnExit()
{
    local CNNWaypoint w;

    foreach AllActors(class'CNNWaypoint', w, EXIT_TAG)
        return;
    Spawn(class'CNNWaypoint',, EXIT_TAG, vect(900, -500, 16));
}

// The meeting ends by triggering MagdaleneMandatoryMovementTriger, which
// would move Magdalene; point it at a tag nothing carries. Not at this
// actor's Tag: a spawned actor's is None, and a trigger on None fires
// every actor in the level. Its second choice also misspells Wong.
function PatchMeeting()
{
    local Conversation con;
    local ConEvent ev;
    local ConChoice choice;

    con = FindConversation(samantha, 'MeetSamanthaReed');
    if (con == none)
        return;

    for (ev = con.eventList; ev != none; ev = ev.nextEvent)
    {
        if ((ConEventTrigger(ev) != none) && (ConEventTrigger(ev).triggerTag == 'MagdaleneMandatoryMovementTriger'))
            ConEventTrigger(ev).triggerTag = MEETING_TRIGGER_TAG;
        else if (ConEventChoice(ev) != none)
            for (choice = ConEventChoice(ev).ChoiceList; choice != none; choice = choice.nextChoice)
                if (choice.choiceText == "[Support Wang]")
                    choice.choiceText = "[Support Wong]";
    }
}

// They stood in a sealed room at Y ~3800. Put them west of the gravity
// well, in view of the player coming in from the south.
function PlaceInLab()
{
    if ((samantha == none) || (wong == none))
        return;

    bPlaced = true;
    samantha.SetLocation(vect(700, -400, 16));
    wong.SetLocation(vect(775, -450, 16));
    samantha.SetRotation(rotator(wong.Location - samantha.Location));
    samantha.DesiredRotation = samantha.Rotation;
    wong.SetRotation(rotator(samantha.Location - wong.Location));
    wong.DesiredRotation = wong.Rotation;
    wong.bInvincible = true;   // the meeting needs him
    samantha.UnfamiliarName = samantha.FamiliarName;   // was "Surgeon"
    Log("CNN L2: Samantha Reed and Wong placed in the gravity lab");
}

// The meeting is not played twice: frob and radius would both start it
// again, ahead of her request for help. That request goes with her when
// she leaves.
function DropConversation(ScriptedPawn p, name conName)
{
    local ConListItem item, prev;

    if (p == none)
        return;

    for (item = ConListItem(p.conListItems); item != none; item = item.next)
    {
        if ((item.con != none) && (item.con.conName == conName))
        {
            if (prev == none)
                p.conListItems = item.next;
            else
                prev.next = item.next;
            return;
        }
        prev = item;
    }
}

function Timer()
{
    if (Player == none)
        return;

    CheckGoals();

    if (Player.IsInState('Conversation') || (Player.conPlay != none))
        return;

    if (!bMeetingDone && Player.flagBase.GetBool('MetReedAndWong'))
        MeetingOver();

    // MJ12 are coming: the two are taken to the bridge as hostages
    if (Player.flagBase.GetBool('MJ12TimerStarted'))
    {
        if (!bSamanthaLeaving)
            SendOff(samantha);
        if (!bWongLeaving)
            SendOff(wong);
    }

    LeaveWhenUnseen(samantha, bSamanthaLeaving);
    LeaveWhenUnseen(wong, bWongLeaving);
}

// ----------------------------------------------------------------------
// MeetingOver()
//
// Siding with Samantha exposes Wong, who storms off; otherwise she
// follows him to the Command Center.
// ----------------------------------------------------------------------

function MeetingOver()
{
    bMeetingDone = true;
    Player.GoalCompleted('MeetDrReed');
    DropConversation(samantha, 'MeetSamanthaReed');
    SendOff(wong);
    if (!Player.flagBase.GetBool('MikeWongExposed'))
    {
        DropConversation(samantha, 'SamGivesQuest');
        SendOff(samantha);
    }
    Log("CNN L2: Samantha Reed meeting over, Wong exposed=" $ Player.flagBase.GetBool('MikeWongExposed'));
}

function SendOff(ScriptedPawn p)
{
    if (p == none)
        return;
    if (p == samantha)
        bSamanthaLeaving = true;
    else
        bWongLeaving = true;
    p.SetOrders('GoingTo', EXIT_TAG, true);
}

// They are gone once the player does not see them -- out of sight, or out
// of the way he looks: they get no further than the doorway.
function LeaveWhenUnseen(out ScriptedPawn p, bool bLeaving)
{
    if (!bLeaving || (p == none))
        return;
    if (Player.LineOfSightTo(p) && ((Normal(p.Location - Player.Location) dot vector(Player.ViewRotation)) > 0.5))
        return;
    Log("CNN L2: " $ p.BindName $ " left the gravity lab");
    p.Destroy();
    p = none;
}

// Mead's holocomm message is what Page's infolink sends the player to;
// Dr Reed's archive answers what happened to Megan Reed.
function CheckGoals()
{
    CompleteGoal('TalkToPage', 'HideMeadHolo');
    CompleteGoal('FindMeganReed', 'PlayerSawWongVideo');
}

function CompleteGoal(name goalName, name flagName)
{
    local DeusExGoal goal;

    goal = Player.FindGoal(goalName);
    if ((goal != none) && !goal.IsCompleted() && Player.flagBase.GetBool(flagName))
        Player.GoalCompleted(goalName);
}

defaultproperties
{
}
