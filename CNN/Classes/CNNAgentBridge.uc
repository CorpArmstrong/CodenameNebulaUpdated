//-----------------------------------------------------------------------
// Class:    CNNAgentBridge
//-----------------------------------------------------------------------
// Developer tool: drives the player for automated tests. Once a second it
// execs CNNAgentCmd.txt, written by tools/cnn_bridge.ps1, whose one line
// "CNNAgentRun <seq> <command>" reaches TantalusDenton.CNNAgentRun and from
// there Run(). By hand: "CNNDev <command>" at the console.
//
// Results go to the log and to CNNAgent.ini, which reaches disk at once.
// GOTO landmarks are 06_OpheliaL2's. On that map it also logs, in any
// game, what the endings depend on (WatchL2).
//-----------------------------------------------------------------------
class CNNAgentBridge extends Actor config(CNNAgent);

var() float pollInterval;
var TantalusDenton Player;

var config int    ackSeq;
var config string ackCmd;
var config int    outCount;
var config string out[160];

// WAITFLAG
var bool bWaitPending;
var name waitFlagName;
var bool waitExpectedValue;
var float waitDeadline;

// CONRUN
var bool bConRun;
var string conPicks;

var bool bSkipSelfHeal;     // CONVERSE leaves a stuck bark alone

// L2 watch (WatchL2): the flags to log as they change. A fixed list, as
// FlagBase's iterator needs an enum the CNN package cannot name; bytes, as
// UE1 has no bool arrays.
var() bool bWatchL2;
var() name trackedFlag[32];
var byte   trackedValue[32];
var int    trackedCount;
var bool   bTrackingPrimed;
var bool   bL2Primed;
var float  l2Seconds;
var name   lastMagOrders;
var string lastMagEnemy;
var bool   bTubeLogged;
var float  tubeLogDelay;

function PostBeginPlay()
{
    SetTimer(pollInterval, true);
    super.PostBeginPlay();
}

function SetTarget(TantalusDenton p)
{
    Player = p;
}

function Timer()
{
    if (Player == none)
        return;

    Player.ConsoleCommand("exec CNNAgentCmd.txt");
    ConStep();
    CheckWait();
    if (bWatchL2)
        WatchL2();
}

// ----------------------------------------------------------------------
// Run()
//
// One command. seq is 0 when typed at the console; only the external
// writer's commands are acknowledged.
// ----------------------------------------------------------------------

function Run(string command, optional int seq)
{
    local string cmd, arg;

    SplitFirstWord(command, cmd, arg);
    cmd = Caps(cmd);
    Log("CNN agent: seq=" $ seq $ " cmd=" $ cmd $ " arg=" $ arg);
    BeginOut();

    if (cmd == "GOTO")
        GotoLandmark(arg);
    else if (cmd == "GOTOVEC")
        GotoVec(arg);
    else if (cmd == "FIRE")
        FireTag(Player.rootWindow.StringToName(arg));
    else if (cmd == "FROB")
        FrobNearest(Player.rootWindow.StringToName(arg));
    else if (cmd == "DAMAGE")
        DamagePlayer(int(arg));
    else if (cmd == "OPEN")
        OpenMap(arg);
    else if (cmd == "CONVERSE")
        Converse(Player.rootWindow.StringToName(arg));
    else if (cmd == "ADVANCE")
        Advance();
    else if (cmd == "STATUS")
        Status();
    else if (cmd == "MAGSTATE")
        MagState(arg);
    else if (cmd == "CONDUMP")
        ConDump(arg);
    else if (cmd == "CONEVENTS")
        ConEvents(arg);
    else if (cmd == "TALK")
        Talk(arg);
    else if (cmd == "CONSTATE")
        ConState();
    else if (cmd == "CHOOSE")
        Choose(int(arg));
    else if (cmd == "CONRUN")
        ConRun(arg);
    else if (cmd == "SETFLAG")
        SetFlag(arg);
    else if (cmd == "WAITFLAG")
        WaitFlag(arg);
    else if (cmd == "NEWGAME")
    {
        // what the menu's Begin button does
        Log("CNN L2 newgame: calling ShowIntro(True) -- strStartMap=" $ Player.strStartMap);
        Player.ShowIntro(True);
    }
    else if (cmd == "GIVE")
        Give(arg);
    else if (cmd == "TAKE")
        Take(arg);
    else if (cmd == "INV")
        Inv(arg);
    else if (cmd == "KILL")
        KillPawn(arg);
    else if (cmd == "BODIES")
        Bodies();
    else if (cmd == "CONLIST")
        ConList(arg);
    else if (cmd == "SAVE")
        SaveSlot(arg);
    else if (cmd == "LOAD")
        LoadSlot(int(arg));
    else if (cmd == "QSAVE")
        QuickSaveGame();
    else if (cmd == "QLOAD")
        LoadSlot(-1);
    else if (cmd == "SNAP")
        Snap(arg);
    else if (cmd == "RAW")
        Player.ConsoleCommand(arg);
    else if (cmd == "WHERE")
        Where();
    else if (cmd == "FLAGS")
        DumpFlags();
    else if (cmd == "PROBE")
        Probe();
    else if (cmd == "TESTENDING")
        TestEnding(arg);
    else if (cmd == "SHOT")
        Player.ConsoleCommand("shot");
    else if (cmd == "QUIT")
        Player.ConsoleCommand("exit");  // a killed process leaves Recovery Mode for the next launch
    else
        Player.ClientMessage("unknown command " $ cmd $
            " -- use GOTO/GOTOVEC/FIRE/FROB/DAMAGE/OPEN/CONVERSE/ADVANCE/STATUS/MAGSTATE/CONDUMP/CONEVENTS/TALK/CONSTATE/CHOOSE/CONRUN/SETFLAG/WAITFLAG/NEWGAME/GIVE/TAKE/INV/KILL/BODIES/SAVE/LOAD/QSAVE/QLOAD/SNAP/RAW/WHERE/FLAGS/PROBE/TESTENDING/SHOT/QUIT");

    // a travel (OPEN, LOAD) happens at the end of the tick, after this
    if (seq > 0)
        Ack(seq, cmd $ " " $ arg);
}

// ----------------------------------------------------------------------
// Output: the log, plus out[] in CNNAgent.ini for the external side
// ----------------------------------------------------------------------

function BeginOut()
{
    local int i;

    for (i = 0; i < outCount; i++)
        out[i] = "";
    outCount = 0;
}

function Report(string line)
{
    Log("CNN agent: " $ line);
    if (outCount < ArrayCount(out))
        out[outCount++] = line;
}

function Ack(int seq, string cmd)
{
    ackSeq = seq;
    ackCmd = cmd;
    SaveConfig();
}

function SplitFirstWord(string s, out string first, out string rest)
{
    local int i;

    i = InStr(s, " ");
    if (i < 0)
    {
        first = s;
        rest = "";
        return;
    }
    first = Left(s, i);
    rest = Right(s, Len(s) - i - 1);
}

// ----------------------------------------------------------------------
// TestEnding()
//
// Sets the one flag Chapter06L2.CheckEndingReached() looks for, so an
// ending can be reached without playing to it.
// ----------------------------------------------------------------------

function TestEnding(string which)
{
    local FlagBase flags;

    which = Caps(which);
    flags = Player.FlagBase;

    // cleared first, so an earlier call cannot win
    flags.SetBool('PlayerDiedOnL2', false);
    flags.SetBool('PlayerDiedDuringUpload', false);
    flags.SetBool('TookSteeringWheel', false);
    flags.SetBool('FinalGoodbyePlayed', false);
    flags.SetBool('TimerExpired', false);
    flags.SetBool('MJ12Arrived', false);

    if (which == "MUTINY")
        flags.SetBool('PlayerDiedOnL2', true);
    else if (which == "HIJACK")
        flags.SetBool('TookSteeringWheel', true);
    else if (which == "TRANSCEND")
        flags.SetBool('TimerExpired', true);
    else if (which == "CONSPIRACY")
        flags.SetBool('MJ12Arrived', true);
    else
    {
        Player.ClientMessage("TESTENDING: use hijack, transcend, conspiracy or mutiny");
        return;
    }

    Player.ClientMessage("TESTENDING: " $ which $ " -- traveling on next mission tick");
}

// ----------------------------------------------------------------------
// Probe()
//
// What stands in front of the player: world BSP (needs UnrealEd) or an
// actor (fixable from script). The box trace is roughly the player's
// cylinder, which is what blocks walking.
// ----------------------------------------------------------------------

function Probe()
{
    local vector start, endPoint, hitLoc, hitNorm;
    local Actor hit;

    start    = Player.Location;
    endPoint = start + (vector(Player.Rotation) * 500.0);

    hit = Player.Trace(hitLoc, hitNorm, endPoint, start, true);
    ReportProbeHit("ray", hit, hitLoc, hitNorm, start);

    hit = Player.Trace(hitLoc, hitNorm, endPoint, start, true, vect(20, 20, 40));
    ReportProbeHit("box", hit, hitLoc, hitNorm, start);
}

function ReportProbeHit(string label, Actor hit, vector hitLoc, vector hitNorm, vector start)
{
    local string what;
    local int dist;

    if (hit == none)
    {
        Player.ClientMessage("PROBE " $ label $ ": nothing within 500");
        Log("CNN L2 probe: " $ label $ " -> nothing within 500");
        return;
    }

    dist = int(VSize(hitLoc - start));

    if (hit == Level)
        what = "WORLD BSP (needs UnrealEd -- script cannot change it)";
    else
        what = "ACTOR " $ string(hit.Class.Name) $ " name=" $ string(hit.Name) $
               " tag=" $ string(hit.Tag) $ " (fixable from script)";

    Player.ClientMessage("PROBE " $ label $ ": " $ what $ " at " $ dist);
    Log("CNN L2 probe: " $ label $ " -> " $ what $
        " dist=" $ dist $
        " hitLoc=(" $ int(hitLoc.X) $ ", " $ int(hitLoc.Y) $ ", " $ int(hitLoc.Z) $ ")" $
        " normal=(" $ hitNorm.X $ ", " $ hitNorm.Y $ ", " $ hitNorm.Z $ ")");
}

// ----------------------------------------------------------------------
// Fire()
//
// Triggers every actor with this Tag, as a dispatcher would. Several L2
// beats are fired that way, e.g. MiniGameDispatcher (the tube sequence).
// ----------------------------------------------------------------------

function FireTag(name eventTag)
{
    local Actor a;
    local int count;

    if (eventTag == '')
    {
        Player.ClientMessage("FIRE <tag> -- e.g. MiniGameDispatcher, CommCenterDispatcher, OpenLabs");
        return;
    }

    foreach AllActors(class'Actor', a, eventTag)
    {
        a.Trigger(Player, Player);
        count++;
        Log("CNN L2 fire: triggered " $ string(a.Class.Name) $ " tag=" $ string(eventTag));
    }

    Player.ClientMessage("FIRE: " $ string(eventTag) $ " -> " $ count $ " actor(s)");
    Log("CNN L2 fire: " $ string(eventTag) $ " matched " $ count $ " actor(s)");
}

// ----------------------------------------------------------------------
// FrobNearest()
//
// Frobs the nearest actor with this Tag or BindName, as the frob key
// would. Spawned actors such as holograms have only a BindName.
// ----------------------------------------------------------------------

function FrobNearest(name targetTag)
{
    local Actor a, best;
    local int count;

    if (targetTag == '')
    {
        Player.ClientMessage("FROB <tag|BindName> -- frobs the nearest actor with this Tag or BindName");
        return;
    }

    foreach AllActors(class'Actor', a)
    {
        if ((a.Tag != targetTag) && (a.BindName != string(targetTag)))
            continue;
        count++;
        if ((best == none) || (VSize(Player.Location - a.Location) < VSize(Player.Location - best.Location)))
            best = a;
    }

    if (best != none)
    {
        Log("CNN L2 frob: frobbed " $ string(best.Class.Name) $ " " $ string(targetTag) $
            " dist=" $ int(VSize(Player.Location - best.Location)));
        best.Frob(Player, none);
    }

    Player.ClientMessage("FROB: " $ string(targetTag) $ " -> " $ count $ " actor(s)");
    Log("CNN L2 frob: " $ string(targetTag) $ " matched " $ count $ " actor(s)");
}

function DamagePlayer(int amount)
{
    if (amount <= 0)
    {
        Player.ClientMessage("DAMAGE <amount> -- e.g. DAMAGE 999 to test death-gated flags");
        return;
    }

    Player.TakeDamage(amount, none, Player.Location, vect(0, 0, 0), 'Shot');
    Log("CNN L2 damage: applied " $ amount $ " -- health now " $ Player.Health);
    Player.ClientMessage("DAMAGE: " $ amount $ " -> health=" $ Player.Health);
}

// ----------------------------------------------------------------------
// OpenMap()
//
// "open" respawns the player, and the command file still holds this line,
// so on the target map it is skipped. GetURLMap, not mapName: L2 has none.
// ----------------------------------------------------------------------

function OpenMap(string targetMap)
{
    local string currentMap;

    currentMap = Caps(Level.Game.GetURLMap());

    if ((currentMap != "") && (currentMap == Caps(targetMap)))
    {
        Log("CNN L2 open: already on " $ targetMap $ " -- skipping redundant open");
        return;
    }

    Player.ConsoleCommand("open " $ targetMap);
}

// ----------------------------------------------------------------------
// Converse()
//
// Starts one of Magdalene's conversations by name. A greeting bark left
// running after a teleport blocks StartConversationByName, so it is
// cleared first (unless bSkipSelfHeal). TALK does the same for anyone.
// ----------------------------------------------------------------------

function Converse(name conName)
{
    local Magdalene mag;
    local bool bStarted;
    local ConListItem item;
    local Conversation con;

    foreach AllActors(class'Magdalene', mag)
        break;

    if (mag == none)
    {
        Player.ClientMessage("CONVERSE: no Magdalene on this map");
        Log("CNN L2 converse: " $ conName $ " -- no Magdalene found");
        return;
    }

    if (bSkipSelfHeal)
    {
        Log("CNN L2 converse: bSkipSelfHeal is True -- self-heal skipped, calling StartConversationByName as-is");
    }
    else
    {
        if (mag.GetStateName() == 'Conversation')
        {
            mag.EndConversation();
            Log("CNN L2 converse: Magdalene was stuck in 'Conversation' state -- called EndConversation() first");
        }

        // TerminateConversation leaves the reference set, which alone
        // makes CanStartConversation refuse
        if (Player.conPlay != none)
        {
            Player.conPlay.InterruptConversation();
            Player.conPlay.TerminateConversation();
            Player.conPlay = none;
            Log("CNN L2 converse: player conPlay was stale -- interrupted+terminated+cleared");
        }
    }

    for (item = ConListItem(mag.conListItems); item != none; item = item.next)
    {
        if (item.con.conName == conName)
        {
            con = item.con;
            break;
        }
    }

    if (con == none)
        Log("CNN L2 converse: " $ conName $ " not found in Magdalene's conListItems");
    else
        Log("CNN L2 converse: " $ conName $ " lookup -- bFirstPerson=" $ con.bFirstPerson $
            " bNonInteractive=" $ con.bNonInteractive $
            " bCannotBeInterrupted=" $ con.bCannotBeInterrupted $
            " radiusDistance=" $ con.radiusDistance);

    bStarted = Player.StartConversationByName(conName, mag, false, false);

    Player.ClientMessage("CONVERSE: " $ conName $ " -> " $ bStarted);
    Log("CNN L2 converse: " $ conName $ " owner=Magdalene started=" $ bStarted $
        " magPhysics=" $ mag.Physics $ " magCanConverse=" $ mag.bCanConverse $
        " magInterruptState=" $ mag.bInterruptState $
        " magOrders=" $ mag.Orders $ " magState=" $ mag.GetStateName() $
        " dist=" $ int(VSize(Player.Location - mag.Location)) $
        " playerCanStartConv=" $ Player.CanStartConversation() $
        " playerState=" $ Player.GetStateName() $
        " playerConPlayNone=" $ (Player.conPlay == none));

    if (Player.conPlay != none)
    {
        if (Player.conPlay.currentEvent != none)
            Log("CNN L2 converse: currentEvent.EventType=" $ Player.conPlay.currentEvent.EventType);
        else
            Log("CNN L2 converse: currentEvent is None");
    }
}

// Next line of the conversation, as a click or Enter would.
function Advance()
{
    if (Player.conPlay == none)
    {
        Player.ClientMessage("ADVANCE: no active conversation");
        Log("CNN L2 advance: no active conPlay");
        return;
    }

    Player.conPlay.PlayNextEvent();
    Player.ClientMessage("ADVANCE: advanced");
    Log("CNN L2 advance: PlayNextEvent called");
}

function Status()
{
    local bool bConPlayHasCon;

    if (Player.conPlay != none)
        bConPlayHasCon = (Player.conPlay.con != none);

    Log("CNN L2 status: playerState=" $ Player.GetStateName() $
        " conPlayNone=" $ (Player.conPlay == none) $
        " conPlayHasCon=" $ bConPlayHasCon $
        " nextState=" $ Player.NextState $
        " physics=" $ Player.Physics);
}

// ----------------------------------------------------------------------
// ConDump()
//
// Every conversation of every actor with this BindName, what a frob would
// pick, and the gates ConPlayBase.StartConversation applies. CheckActors
// logs any speaker missing from the map.
// ----------------------------------------------------------------------

function ConDump(string bindName)
{
    local Actor a;
    local ConListItem item;
    local Conversation frobCon;
    local string frobName;
    local int count;

    foreach AllActors(class'Actor', a)
    {
        if (a.BindName != bindName)
            continue;

        count++;
        frobCon = Player.GetActiveConversation(a, IM_Frob);
        frobName = "None";
        if (frobCon != none)
            frobName = string(frobCon.conName);
        Log("CNN L2 condump: " $ bindName $ " actor=" $ a.Name $
            " loc=" $ a.Location $ " dist=" $ int(VSize(Player.Location - a.Location)) $
            " frobPicks=" $ frobName);

        for (item = ConListItem(a.conListItems); item != none; item = item.next)
        {
            if (item.con != none)
            {
                Log("CNN L2 condump: " $ bindName $ " con=" $ item.con.conName $
                    " bFirstPerson=" $ item.con.bFirstPerson $
                    " bNonInteractive=" $ item.con.bNonInteractive $
                    " radiusDistance=" $ item.con.radiusDistance $
                    " frob=" $ item.con.bInvokeFrob $
                    " bump=" $ item.con.bInvokeBump $
                    " sight=" $ item.con.bInvokeSight $
                    " radius=" $ item.con.bInvokeRadius $
                    " flagsOK=" $ Player.CheckFlagRefs(item.con.flagRefList) $
                    " actorsOK=" $ item.con.CheckActors(true) $
                    " distancesOK=" $ item.con.CheckActorDistances(Player));
            }
        }
    }

    if (count == 0)
        Log("CNN L2 condump: no actor with BindName " $ bindName);
}

// ----------------------------------------------------------------------
// Conversation driving
//
// CONEVENTS lists a conversation's events as the engine loaded them; TALK
// starts one with any actor; CONSTATE shows where a running one is and
// which choices are open; CHOOSE picks one through ConPlay.PlayChoice, as
// a click does; CONRUN walks the whole scene.
// ----------------------------------------------------------------------

// The actor with this BindName that owns conName (L2 has offstage doubles).
function Actor FindConversationOwner(string bindName, string conName, out Conversation con)
{
    local Actor a;
    local ConListItem item;

    foreach AllActors(class'Actor', a)
    {
        if (a.BindName != bindName)
            continue;
        for (item = ConListItem(a.conListItems); item != none; item = item.next)
        {
            if ((item.con != none) && (Caps(string(item.con.conName)) == Caps(conName)))
            {
                con = item.con;
                return a;
            }
        }
    }
    return none;
}

function string FlagRefsText(ConFlagRef ref)
{
    local string s;

    while (ref != none)
    {
        s = s $ " " $ ref.flagName $ "=" $ ref.value;
        ref = ref.nextFlagRef;
    }
    return s;
}

function string ConEventText(ConEvent ev)
{
    local string s;
    local ConEventSpeech speech;

    if (ev == none)
        return "None";

    speech = ConEventSpeech(ev);
    if (speech != none)
    {
        s = "SPEECH " $ speech.speakerName $ " -> " $ speech.speakingToName;
        if (speech.conSpeech != none)
            s = s $ ": " $ Left(speech.conSpeech.speech, 90);
    }
    else if (ConEventChoice(ev) != none)
        s = "CHOICE";
    else if (ConEventSetFlag(ev) != none)
        s = "SETFLAG" $ FlagRefsText(ConEventSetFlag(ev).flagRef);
    else if (ConEventCheckFlag(ev) != none)
        s = "CHECKFLAG" $ FlagRefsText(ConEventCheckFlag(ev).flagRef) $ " -> " $ ConEventCheckFlag(ev).setLabel;
    else if (ConEventJump(ev) != none)
        s = "JUMP -> " $ ConEventJump(ev).jumpLabel;
    else if (ConEventTrigger(ev) != none)
        s = "TRIGGER " $ ConEventTrigger(ev).triggerTag;
    else if (ConEventComment(ev) != none)
        s = "COMMENT " $ ConEventComment(ev).commentText;
    else if (ConEventEnd(ev) != none)
        s = "END";
    else if (ConEventAddGoal(ev) != none)
        s = "ADDGOAL " $ ConEventAddGoal(ev).goalName $ " completed=" $ ConEventAddGoal(ev).bGoalCompleted;
    else if (ConEventAnimation(ev) != none)
        s = "ANIM " $ ConEventAnimation(ev).eventOwnerName $ " " $ ConEventAnimation(ev).sequence;
    else if (ConEventCheckPersona(ev) != none)
        s = "CHECKPERSONA -> " $ ConEventCheckPersona(ev).jumpLabel;
    else if (ConEventRandomLabel(ev) != none)
        s = "RANDOM (labels are native, not readable from script)";
    else
        s = string(ev.Class.Name);

    if (ev.label != "")
        s = "<" $ ev.label $ "> " $ s;
    return s;
}

function bool ChoiceAvailable(ConChoice choice)
{
    if (!Player.CheckFlagRefs(choice.flagRef))
        return false;
    if (choice.skillNeeded == none)
        return true;
    return Player.SkillSystem.IsSkilled(choice.skillNeeded, choice.skillLevelNeeded);
}

function string ChoiceText(ConChoice choice)
{
    local string s;

    s = "\"" $ choice.choiceText $ "\" -> " $ choice.choiceLabel;
    if (choice.skillNeeded != none)
        s = s $ " skill=" $ choice.skillNeeded.Name $ ":" $ choice.skillLevelNeeded;
    if (choice.flagRef != none)
        s = s $ " flags:" $ FlagRefsText(choice.flagRef);
    return s;
}

function ConEvents(string args)
{
    local string bindName, conName;
    local Conversation con;
    local Actor owner;
    local ConEvent ev;
    local ConChoice choice;
    local int i;

    SplitFirstWord(args, bindName, conName);
    owner = FindConversationOwner(bindName, conName, con);
    if (owner == none)
    {
        Log("CNN L2 conevents: no " $ conName $ " on any actor with BindName " $ bindName);
        return;
    }

    Log("CNN L2 conevents: " $ con.conName $ " owner=" $ owner.Name $ " frob=" $ con.bInvokeFrob $
        " radius=" $ con.bInvokeRadius $ ":" $ con.radiusDistance $ " flags:" $ FlagRefsText(con.flagRefList));
    for (ev = con.eventList; ev != none; ev = ev.nextEvent)
    {
        Log("CNN L2 conevents: [" $ i $ "] " $ ConEventText(ev));
        if (ConEventChoice(ev) != none)
            for (choice = ConEventChoice(ev).ChoiceList; choice != none; choice = choice.nextChoice)
                Log("CNN L2 conevents:      choice " $ ChoiceText(choice));
        i++;
    }
}

// TALK <BindName> <conName> [force]
function Talk(string args)
{
    local string bindName, conName, rest;
    local Conversation con;
    local Actor owner;
    local bool bForce, bStarted;

    SplitFirstWord(args, bindName, rest);
    SplitFirstWord(rest, conName, rest);
    bForce = (Caps(rest) == "FORCE");

    owner = FindConversationOwner(bindName, conName, con);
    if (owner == none)
    {
        Log("CNN L2 talk: no " $ conName $ " on any actor with BindName " $ bindName);
        return;
    }
    if (Player.conPlay != none)
    {
        Log("CNN L2 talk: a conversation is already running");
        return;
    }

    bStarted = Player.StartConversation(owner, IM_Named, con, false, bForce);
    Log("CNN L2 talk: " $ con.conName $ " with " $ owner.Name $ " force=" $ bForce $ " started=" $ bStarted);
}

function ConState()
{
    local ConPlay conPlay;
    local ConEvent ev;
    local ConChoice choice;
    local int i, n;

    conPlay = Player.conPlay;
    if ((conPlay == none) || (conPlay.con == none))
    {
        Log("CNN L2 constate: no conversation");
        return;
    }

    for (ev = conPlay.con.eventList; (ev != none) && (ev != conPlay.currentEvent); ev = ev.nextEvent)
        i++;

    Log("CNN L2 constate: " $ conPlay.con.conName $ " class=" $ conPlay.Class $ " conPlay=" $ conPlay.GetStateName() $
        " event[" $ i $ "] " $ ConEventText(conPlay.currentEvent));

    if (ConEventChoice(conPlay.currentEvent) != none)
    {
        for (choice = ConEventChoice(conPlay.currentEvent).ChoiceList; choice != none; choice = choice.nextChoice)
        {
            if (ChoiceAvailable(choice))
            {
                n++;
                Log("CNN L2 constate:   " $ n $ ") " $ ChoiceText(choice));
            }
            else
                Log("CNN L2 constate:   -) " $ ChoiceText(choice) $ " [locked]");
        }
    }
}

// The n-th choice the player can take (locked ones are not counted).
function Choose(int n)
{
    local ConPlay conPlay;
    local ConChoice choice;
    local int k;

    conPlay = Player.conPlay;
    if ((conPlay == none) || (ConEventChoice(conPlay.currentEvent) == none))
    {
        Log("CNN L2 choose: not at a choice");
        return;
    }
    if (!conPlay.IsInState('WaitForInput'))
    {
        Log("CNN L2 choose: choice not on screen yet (conPlay=" $ conPlay.GetStateName() $ ")");
        return;
    }

    for (choice = ConEventChoice(conPlay.currentEvent).ChoiceList; choice != none; choice = choice.nextChoice)
    {
        if (ChoiceAvailable(choice))
        {
            k++;
            if (k == n)
            {
                Log("CNN L2 choose: " $ n $ ") " $ ChoiceText(choice));
                conPlay.PlayChoice(choice);
                return;
            }
        }
    }
    Log("CNN L2 choose: no available choice " $ n);
}

// ----------------------------------------------------------------------
// ConRun() / ConStep()
//
// Walks the running conversation one step a tick: speech is advanced,
// and at each choice the next number from picks is taken. With no picks
// left it stops at the choice and lists it.
// ----------------------------------------------------------------------

function ConRun(string picks)
{
    bConRun = true;
    conPicks = picks;
    Log("CNN L2 conrun: on, picks=[" $ picks $ "]");
}

function ConStep()
{
    local ConPlay conPlay;
    local string pick;

    if (!bConRun)
        return;

    conPlay = Player.conPlay;
    if ((conPlay == none) || (conPlay.con == none))
    {
        bConRun = false;
        Log("CNN L2 conrun: conversation ended");
        return;
    }

    if (ConEventChoice(conPlay.currentEvent) != none)
    {
        if (!conPlay.IsInState('WaitForInput'))
            return;
        if (conPicks == "")
        {
            bConRun = false;
            Log("CNN L2 conrun: stopped at a choice, no picks left");
            ConState();
            return;
        }
        SplitFirstWord(conPicks, pick, conPicks);
        Choose(int(pick));
        return;
    }

    if (conPlay.IsInState('WaitForInput') || conPlay.IsInState('WaitForSpeech') ||
        conPlay.IsInState('WaitForText'))
    {
        Log("CNN L2 conrun: " $ ConEventText(conPlay.currentEvent));
        conPlay.PlayNextEvent();
    }
}

// MAGSTATE [BindName]: the AI state of an actor, Magdalene by default.
function MagState(string bindName)
{
    local Actor a;
    local ScriptedPawn sp;

    if (bindName == "")
        bindName = "Magdalene";

    foreach AllActors(class'Actor', a)
        if (a.BindName == bindName)
            break;

    if (a == none)
    {
        Log("CNN L2 magstate: no actor with BindName " $ bindName);
        return;
    }

    sp = ScriptedPawn(a);
    if (sp != none)
        Log("CNN L2 magstate: " $ bindName $ " state=" $ sp.GetStateName() $
            " orders=" $ sp.Orders $
            " interruptState=" $ sp.bInterruptState $
            " dist=" $ int(VSize(Player.Location - sp.Location)));
    else
        Log("CNN L2 magstate: " $ bindName $ " state=" $ a.GetStateName() $
            " (not a ScriptedPawn -- orders/interruptState unavailable)" $
            " dist=" $ int(VSize(Player.Location - a.Location)));
}

// ----------------------------------------------------------------------
// Flags
//
//   SETFLAG <flag> <True|False>
//   WAITFLAG <flag> <True|False> [seconds]   logs once the flag matches,
//                                            or the timeout
//   FLAGS                                    the flags L2's endings use
// ----------------------------------------------------------------------

function bool ParseBool(string s)
{
    s = Caps(s);
    return (s == "TRUE") || (s == "1") || (s == "YES") || (s == "ON");
}

function SetFlag(string args)
{
    local string flagName, value;
    local name flag;

    SplitFirstWord(args, flagName, value);
    if (flagName == "")
    {
        Player.ClientMessage("SETFLAG <flagName> <True|False> -- writes one FlagBase bool directly");
        return;
    }

    flag = Player.rootWindow.StringToName(flagName);
    Player.FlagBase.SetBool(flag, ParseBool(value));
    Player.ClientMessage("SETFLAG: " $ flag $ " -> " $ ParseBool(value));
    Log("CNN L2 setflag: " $ flag $ " -> " $ ParseBool(value) $
        " (confirmed=" $ Player.FlagBase.GetBool(flag) $ ")");
}

function WaitFlag(string args)
{
    local string flagName, value, seconds;
    local float timeout;

    SplitFirstWord(args, flagName, value);
    SplitFirstWord(value, value, seconds);
    if (flagName == "")
    {
        Player.ClientMessage("WAITFLAG <flagName> <True|False> <timeoutSeconds> -- polls FlagBase once per bridge tick until it matches or the timeout elapses");
        return;
    }

    timeout = float(seconds);
    if (timeout <= 0)
        timeout = 30.0;

    waitFlagName = Player.rootWindow.StringToName(flagName);
    waitExpectedValue = ParseBool(value);
    waitDeadline = Level.TimeSeconds + timeout;
    bWaitPending = true;

    Log("CNN L2 wait: started, flag=" $ waitFlagName $ " expected=" $ waitExpectedValue $
        " timeout=" $ timeout $ "s current=" $ Player.FlagBase.GetBool(waitFlagName));
    CheckWait();
}

function CheckWait()
{
    local bool current;

    if (!bWaitPending)
        return;

    current = Player.FlagBase.GetBool(waitFlagName);

    if (current == waitExpectedValue)
    {
        bWaitPending = false;
        Log("CNN L2 wait: OK -- " $ waitFlagName $ " reached " $ waitExpectedValue $
            ", " $ (waitDeadline - Level.TimeSeconds) $ "s of timeout left unused");
    }
    else if (Level.TimeSeconds >= waitDeadline)
    {
        bWaitPending = false;
        Log("CNN L2 wait: TIMEOUT -- " $ waitFlagName $ " still " $ current $
            ", wanted " $ waitExpectedValue);
    }
}

function DumpFlags()
{
    local FlagBase flags;

    flags = Player.FlagBase;
    Log("CNN L2 flags: MikeWongExposed=" $ flags.GetBool('MikeWongExposed') $
        " MetReedAndWong=" $ flags.GetBool('MetReedAndWong') $
        " IsArrivalPlayed=" $ flags.GetBool('IsArrivalPlayed') $
        " OnLevel2=" $ flags.GetBool('OnLevel2') $
        " CanArmMagdalene=" $ flags.GetBool('CanArmMagdalene') $
        " MagdaleneArmed=" $ flags.GetBool('MagdaleneArmed') $
        " ReadyForBossFight=" $ flags.GetBool('ReadyForBossFight') $
        " ReadyForSocialBoss=" $ flags.GetBool('ReadyForSocialBoss') $
        " FinalGoodbyePlayed=" $ flags.GetBool('FinalGoodbyePlayed'));
    Log("CNN L2 flags: AllObjectsDestroyed=" $ flags.GetBool('AllObjectsDestroyed') $
        " SeedsOfDoubtPlanted=" $ flags.GetBool('SeedsOfDoubtPlanted') $
        " WongParanoid=" $ flags.GetBool('WongParanoid') $
        " SamUnfriendly=" $ flags.GetBool('SamUnfriendly') $
        " PlayerDied=" $ flags.GetBool('PlayerDied') $
        " PlayerDiedOnL2=" $ flags.GetBool('PlayerDiedOnL2') $
        " PlayerDiedDuringUpload=" $ flags.GetBool('PlayerDiedDuringUpload'));
    Log("CNN L2 flags: TantalusUploadStarted=" $ flags.GetBool('TantalusUploadStarted') $
        " TantalusUploaded=" $ flags.GetBool('TantalusUploaded') $
        " UndockedL2=" $ flags.GetBool('UndockedL2') $
        " StartedBlueFusion=" $ flags.GetBool('StartedBlueFusion') $
        " TookSteeringWheel=" $ flags.GetBool('TookSteeringWheel') $
        " MJ12TimerStarted=" $ flags.GetBool('MJ12TimerStarted') $
        " MJ12Arrived=" $ flags.GetBool('MJ12Arrived') $
        " TimerExpired=" $ flags.GetBool('TimerExpired') $
        " IsGameCompleted=" $ flags.GetBool('IsGameCompleted'));

    Player.ClientMessage("FLAGS: dumped to log");
}

// ----------------------------------------------------------------------
// Where()
//
// The player's exact position and zone, logged so a report of "a wall
// here" can be looked up in the map.
// ----------------------------------------------------------------------

function Where()
{
    local string zoneName, mapName;
    local DeusExLevelInfo info;

    if (Player.Region.Zone != none)
        zoneName = string(Player.Region.Zone.Name);
    else
        zoneName = "none";

    info = Player.GetLevelInfo();
    if (info != none)
        mapName = info.mapName;
    else
        mapName = "unknown";

    Player.ClientMessage("WHERE: " $ int(Player.Location.X) $ " " $ int(Player.Location.Y) $ " " $
                         int(Player.Location.Z) $ "  yaw=" $ Player.Rotation.Yaw $ "  zone=" $ zoneName);

    Log("CNN L2 where: map=" $ mapName $
        " loc=(" $ int(Player.Location.X) $ ", " $ int(Player.Location.Y) $ ", " $ int(Player.Location.Z) $ ")" $
        " yaw=" $ Player.Rotation.Yaw $ " pitch=" $ Player.Rotation.Pitch $
        " zone=" $ zoneName $
        " headRegionZone=" $ string(Player.HeadRegion.Zone.Name));
}

// ----------------------------------------------------------------------
// GotoLandmark() / GotoVec()
//
// Teleports to a named L2 spot (coordinates from the map, see
// CNNDocs/L2_WalkthroughMap.md) or to "x y z".
// ----------------------------------------------------------------------

function GotoLandmark(string where)
{
    local vector dest;
    local DeusExLevelInfo info;
    local bool bKnown;

    where = Caps(where);
    bKnown = true;

    if      (where == "START")     dest = vect(-1044, -1900,   891);  // arrival
    else if (where == "SAM")       dest = vect(  841, -2031,     8);  // MeetSamanthaReed trigger
    else if (where == "SAMANTHA")  dest = vect(  971, -3991, -1284);  // Samantha Reed herself
    else if (where == "MAGDALENE") dest = vect( 1083, -2133, -1335);  // Magdalene, level start
    else if (where == "MAGLAB")    dest = vect(  878, -1682,     0);  // where OpenLabs moves her
    else if (where == "SOLDIERS")  dest = vect(  908, -1587,    24);  // MJ12Sergeant -- starts MeetSoldiers
    else if (where == "BATTLE")    dest = vect(  874, -1850,    -3);  // CommCenterBattleSpawnPoint
    else if (where == "IOT")       dest = vect(  701, -2861, -1348);  // clearance terminal
    else if (where == "WONG")      dest = vect(  782, -4058, -1301);
    else if (where == "MEPH")      dest = vect(  866, -4480, -1233);
    else if (where == "JC")        dest = vect(  894, -2315, -1303);  // JC Avatar
    else if (where == "WALL")      dest = vect(  918, -5686,    15);  // reported invisible wall / render artifact spot
    else if (where == "TUBE")      dest = vect(  843, -6084,     8);  // LoadingInTube trigger
    else if (where == "FINAL")     dest = vect( 1487, -6294,     4);  // tube area (medbot) -- the trigger itself is outside walkable space; use FIRE MiniGameDispatcher
    else bKnown = false;

    if (!bKnown)
    {
        Player.ClientMessage("GOTO: start sam samantha magdalene maglab soldiers battle iot wong meph jc tube final wall");
        return;
    }

    if (TryLandNear(dest, where))
        return;

    // an empty mapName (L2 has none) is not a wrong map
    info = Player.GetLevelInfo();
    if ((info != none) && (info.mapName != "") &&
        (Caps(info.mapName) != "06_OPHELIAL2"))
    {
        Player.ClientMessage("GOTO: these are 06_OpheliaL2 landmarks -- you are on " $ info.mapName);
        Log("CNN L2 goto: " $ where $ " refused, wrong map (" $ info.mapName $ ")");
        return;
    }

    Player.ClientMessage("GOTO: " $ where $ " is blocked -- type ghost first, then retry");
    Log("CNN L2 goto: " $ where $ " BLOCKED at " $ dest);
}

function GotoVec(string args)
{
    local string x, y, z;
    local vector dest;

    SplitFirstWord(args, x, y);
    SplitFirstWord(y, y, z);
    if (z == "")
    {
        Log("CNN L2 goto: GOTOVEC malformed arg (expected \"x y z\"): " $ args);
        return;
    }

    dest.X = float(x);
    dest.Y = float(y);
    dest.Z = float(z);

    if (!TryLandNear(dest, "vec"))
    {
        Player.ClientMessage("GOTOVEC: blocked at " $ dest);
        Log("CNN L2 goto: vec " $ dest $ " BLOCKED");
    }
}

// Landmarks are at floor level: lift clear of it and fan out until the
// player's cylinder fits.
function bool TryLandNear(vector dest, string label)
{
    local vector tryLoc;
    local int attempt, ring;

    Player.Velocity = vect(0, 0, 0);
    Player.Acceleration = vect(0, 0, 0);

    for (attempt = 0; attempt < 20; attempt++)
    {
        tryLoc = dest;
        tryLoc.Z += 50 + ((attempt / 5) * 60);

        ring = attempt % 5;
        if (ring == 1)      tryLoc.X += 80;
        else if (ring == 2) tryLoc.X -= 80;
        else if (ring == 3) tryLoc.Y += 80;
        else if (ring == 4) tryLoc.Y -= 80;

        if (Player.SetLocation(tryLoc))
        {
            Player.ClientMessage("GOTO: " $ label $ " " $ tryLoc);
            Log("CNN L2 goto: " $ label $ " -> " $ tryLoc);
            BringFollowers(tryLoc);
            return true;
        }
    }

    return false;
}

// A following Magdalene comes along: her conversations refuse to start
// beyond 800 units, so a teleport alone would break them.
function BringFollowers(vector playerLoc)
{
    local Magdalene mag;
    local vector dest;

    foreach AllActors(class'Magdalene', mag)
    {
        if (mag.Orders != 'Following')
            continue;

        dest = playerLoc;
        dest.X += 90;

        if (mag.SetLocation(dest))
            Log("CNN L2 goto: brought Magdalene to " $ dest);
        else
            Log("CNN L2 goto: could not place Magdalene near " $ dest);

        break;
    }
}

// ----------------------------------------------------------------------
// Save / load
//
//   SAVE <slot> [description]   slots 900 and up, never the player's own
//   QSAVE / QLOAD               the F5/F9 path (QLOAD skips the prompt)
//   LOAD <slot>
//   SNAP <name>                 state to compare before a save and after
//                               the load
// ----------------------------------------------------------------------

function SaveSlot(string args)
{
    local string slot, desc;

    SplitFirstWord(args, slot, desc);
    if (desc == "")
        desc = "CNN agent " $ args;
    if (int(slot) < 900)
    {
        Report("SAVE refused: agent saves use slots 900 and up");
        return;
    }
    Report("SAVE slot=" $ int(slot) $ " desc=" $ desc $ " state=" $ Player.GetStateName() $
           " conPlay=" $ (Player.conPlay != none) $ " dataLink=" $ (Player.dataLinkPlay != none));
    Player.SaveGame(int(slot), desc);
}

function QuickSaveGame()
{
    Report("QSAVE state=" $ Player.GetStateName() $ " conPlay=" $ (Player.conPlay != none) $
           " dataLink=" $ (Player.dataLinkPlay != none));
    Player.QuickSave();
}

function LoadSlot(int slot)
{
    Report("LOAD slot=" $ slot);
    Player.LoadGame(slot);
}

function Snap(string snapName)
{
    local Inventory item;
    local DeusExGoal goal;
    local Augmentation aug;
    local Chapter06L2 mission;
    local DeusExLevelInfo info;
    local string list;
    local int n;

    Report("snap=" $ snapName);
    Report("map=" $ Level.Game.GetURLMap());
    info = Player.GetLevelInfo();
    if (info != none)
        Report("mapName=" $ info.mapName $ " mission=" $ info.missionNumber);
    Report("player.loc=" $ int(Player.Location.X) $ "," $ int(Player.Location.Y) $ "," $ int(Player.Location.Z));
    Report("player.state=" $ Player.GetStateName() $ " conPlay=" $ (Player.conPlay != none));
    Report("player.health=" $ Player.Health $ " head=" $ Player.HealthHead $ " torso=" $ Player.HealthTorso $
           " energy=" $ int(Player.Energy) $ " skillpts=" $ Player.SkillPointsAvail);

    for (item = Player.Inventory; item != none; item = item.Inventory)
    {
        n++;
        if (Len(list) < 400)
        {
            list = list $ " " $ item.Class.Name;
            if (Ammo(item) != none)
                list = list $ "(" $ Ammo(item).AmmoAmount $ ")";
        }
    }
    Report("player.inv=" $ n $ ":" $ list);

    list = "";
    if (Player.AugmentationSystem != none)
        for (aug = Player.AugmentationSystem.FirstAug; aug != none; aug = aug.next)
        {
            if (aug.bHasIt)
                list = list $ " " $ aug.Class.Name;
            if (aug.bHasIt && aug.bIsActive)
                list = list $ "*";
        }
    Report("player.augs=" $ list);

    list = "";
    for (goal = Player.FirstGoal; goal != none; goal = goal.next)
    {
        if (Len(list) >= 400)
            break;
        list = list $ " " $ goal.goalName;
        if (goal.bCompleted)
            list = list $ "+";
    }
    Report("player.goals=" $ list);

    foreach AllActors(class'Chapter06L2', mission)
        SnapL2(mission);
}

// L2's part of SNAP: what a save and a load must carry over.
function SnapL2(Chapter06L2 mission)
{
    local CNNSocialBoss sb;
    local MJ12Troop troop;
    local DeusExCarcass carc;
    local Mover tube;
    local ShipsWheel wheel;
    local string list;
    local int i, n;

    if (mission.flags == none)
    {
        Report("l2.init=0 (mission script not started yet)");
        return;
    }
    Report("l2.init=1 mj12=" $ int(mission.mj12SecondsLeft) $ " window=" $ (mission.mj12Window != none));
    sb = mission.socialBoss;
    if (sb != none)
        Report("l2.socialboss=started:" $ sb.bStarted $ " fight:" $ sb.bFight $
               " wong:" $ sb.bWongHostile $ " meph:" $ sb.bMephHostile $ " released:" $ sb.bReleased);

    for (i = 0; i < ArrayCount(trackedFlag); i++)
        if ((trackedFlag[i] != '') && mission.flags.GetBool(trackedFlag[i]))
            list = list $ " " $ trackedFlag[i];
    Report("l2.flags=" $ list);

    SnapPawn(FindPawn("Magdalene"));
    SnapPawn(FindPawn("DrMephistopheles"));
    SnapPawn(FindPawn("MikeWong"));
    SnapPawn(FindPawn("CorpArmstrongHostage"));
    SnapPawn(FindPawn("DrJohnsonHostage"));
    SnapPawn(FindPawn("SamanthaReedHostage"));
    SnapPawn(FindPawn("MJ12Sergeant"));
    if (sb != none)
        SnapPawn(sb.trooper);

    foreach AllActors(class'MJ12Troop', troop)
        n++;
    Report("l2.count mj12troop=" $ n);
    n = 0;
    foreach AllActors(class'DeusExCarcass', carc)
        n++;
    Report("l2.count carcasses=" $ n);

    foreach AllActors(class'Mover', tube, 'CNNMoverTube')
        Report("l2.tube keyNum=" $ tube.KeyNum $ " z=" $ int(tube.Location.Z) $ " base=" $ int(tube.BasePos.Z));
    foreach AllActors(class'ShipsWheel', wheel)
        Report("l2.wheel invincible=" $ wheel.bInvincible);
}

function SnapPawn(ScriptedPawn sp)
{
    local Inventory item;
    local int n;

    if (sp == none)
        return;
    for (item = sp.Inventory; item != none; item = item.Inventory)
        n++;
    Report("pawn." $ sp.BindName $ "=" $ sp.Name $ " alive=" $ IsAlive(sp) $ " health=" $ sp.Health $
           " state=" $ sp.GetStateName() $ " orders=" $ sp.Orders $ " invincible=" $ sp.bInvincible $
           " weapon=" $ sp.Weapon $ " items=" $ n $ " carcass=" $ sp.CarcassType $
           " name=" $ sp.UnfamiliarName $ " cons=" $ (sp.conListItems != none) $
           " loc=" $ int(sp.Location.X) $ "," $ int(sp.Location.Y));
}

function ScriptedPawn FindPawn(string bindName)
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

// ----------------------------------------------------------------------
// WatchL2()
//
// On 06_OpheliaL2, logs what the endings depend on as it changes: the
// tracked flags, Magdalene's orders and enemy, and where the tube glass
// stands after the button. On arrival it lists the key actors'
// conversations in the order the engine checks them.
// ----------------------------------------------------------------------

function WatchL2()
{
    local Chapter06L2 mission;

    foreach AllActors(class'Chapter06L2', mission)
        break;
    if ((mission == none) || (mission.flags == none))
        return;

    l2Seconds += pollInterval;
    if (!bL2Primed)
    {
        bL2Primed = true;
        DumpConversationLists();
    }
    LogChangedFlags(mission.flags);
    LogMagdalene();
    LogTube(mission.flags);
}

function LogChangedFlags(FlagBase flags)
{
    local int i;
    local bool flagValue;
    local byte packedValue;

    if (!bTrackingPrimed)
    {
        bTrackingPrimed = true;
        for (i = 0; i < ArrayCount(trackedFlag); i++)
        {
            if (trackedFlag[i] == '')
                break;
            trackedCount = i + 1;
            trackedValue[i] = 255;      // forces a first-seen log
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
            Log("CNN L2 flag @" $ int(l2Seconds) $ "s: " $ trackedFlag[i] $ " = " $ flagValue);
        }
    }
}

function LogMagdalene()
{
    local Magdalene mag;
    local string enemyName;

    foreach AllActors(class'Magdalene', mag)
        break;
    if (mag == none)
        return;

    if (mag.Enemy != none)
        enemyName = string(mag.Enemy.Name) $ " [" $ string(mag.Enemy.Class.Name) $ "]";
    else
        enemyName = "none";

    if ((mag.Orders != lastMagOrders) || (enemyName != lastMagEnemy))
    {
        lastMagOrders = mag.Orders;
        lastMagEnemy  = enemyName;

        Log("CNN L2 magdalene @" $ int(l2Seconds) $ "s: orders=" $
            string(mag.Orders) $ " enemy=" $ enemyName $
            " alliance=" $ string(mag.Alliance) $
            " health=" $ mag.Health);
    }
}

function LogTube(FlagBase flags)
{
    local Mover tube;

    if (bTubeLogged || !flags.GetBool('TantalusUploadStarted'))
        return;

    tubeLogDelay += pollInterval;
    if (tubeLogDelay < 4.0)
        return;

    bTubeLogged = true;
    foreach AllActors(class'Mover', tube, 'CNNMoverTube')
        Log("CNN L2: tube after button: KeyNum=" $ tube.KeyNum $ " state=" $ tube.GetStateName() $
            " opening=" $ tube.bOpening $ " loc=" $ tube.Location);
}

function DumpConversationLists()
{
    local Actor a;
    local ConListItem item;
    local string flagList;
    local int index;

    foreach AllActors(class'Actor', a)
    {
        if ((a.conListItems == none) || (a.BindName == ""))
            continue;
        if ((a.BindName != "MJ12Sergeant") && (a.BindName != "Magdalene") &&
            (a.BindName != "SamanthaReed") && (a.BindName != "OpheliaUI") &&
            (a.BindName != "MikeWong")     && (a.BindName != "DrMephistopheles"))
            continue;

        index = 0;
        for (item = ConListItem(a.conListItems); item != none; item = item.next)
        {
            if (item.con != none)
            {
                flagList = FlagRefsText(item.con.flagRefList);
                if (flagList == "")
                    flagList = " (no flags)";
                Log("CNN L2 cons: " $ a.BindName $ " [" $ index $ "] " $
                    string(item.con.conName) $ " flags:" $ flagList);
            }
            index++;
        }
    }
}

// ----------------------------------------------------------------------
// Inventory and pawns
//
//   GIVE <class>       spawns the item into the player's inventory
//   TAKE <class>       removes every item of that class from the player
//   INV [BindName]     the player's inventory, or a pawn's
//   KILL <BindName>    1000 damage from the player (the invincible survive)
//   BODIES             every carcass
//   CONLIST <BindName> the actor's conversations in the order the engine
//                      checks them
// A bare class name is looked up in DeusEx, then in CNN.
// ----------------------------------------------------------------------

function class<Inventory> ItemClass(string className)
{
    local class<Inventory> c;

    if (InStr(className, ".") >= 0)
        return class<Inventory>(DynamicLoadObject(className, class'Class', true));
    c = class<Inventory>(DynamicLoadObject("DeusEx." $ className, class'Class', true));
    if (c == none)
        c = class<Inventory>(DynamicLoadObject("CNN." $ className, class'Class', true));
    return c;
}

function Give(string className)
{
    local class<Inventory> c;
    local Inventory item;

    c = ItemClass(className);
    if (c == none)
    {
        Report("GIVE unknown class " $ className);
        return;
    }
    item = Player.Spawn(c,,, Player.Location);
    if (item == none)
    {
        Log("CNN agent: GIVE could not spawn " $ c);
        return;
    }
    item.GiveTo(Player);
    if (Weapon(item) != none)
        Weapon(item).GiveAmmo(Player);
    Report("GIVE " $ c $ " held=" $ (Player.FindInventoryType(c) != none));
}

function Take(string className)
{
    local class<Inventory> c;
    local Inventory item;
    local int n;

    c = ItemClass(className);
    if (c == none)
    {
        Log("CNN agent: TAKE unknown class " $ className);
        return;
    }
    item = Player.FindInventoryType(c);
    while ((item != none) && (n < 10))
    {
        if (Player.inHand == item)
            Player.PutInHand(none);
        Player.DeleteInventory(item);
        item.Destroy();
        n++;
        item = Player.FindInventoryType(c);
    }
    Report("TAKE " $ c $ " removed=" $ n);
}

function Inv(string bindName)
{
    local Pawn p;
    local ScriptedPawn sp;
    local Inventory item;
    local string list;
    local int n;

    p = Player;
    if (bindName != "")
    {
        p = none;
        foreach AllActors(class'ScriptedPawn', sp)
            if (sp.BindName == bindName)
                p = sp;
        if (p == none)
        {
            Report("INV no pawn bound as " $ bindName);
            return;
        }
    }

    // capped: one over-long log line crashes the game
    for (item = p.Inventory; item != none; item = item.Inventory)
    {
        n++;
        if (Len(list) > 600)
            continue;
        list = list $ " " $ item.Class.Name;
        if ((Weapon(item) != none) && (Weapon(item).AmmoType != none))
            list = list $ "(" $ Weapon(item).AmmoType.AmmoAmount $ ")";
    }
    Report("INV " $ p.Name $ " weapon=" $ p.Weapon $ " items=" $ n $ ":" $ list);
}

function KillPawn(string bindName)
{
    local ScriptedPawn sp, victim;

    foreach AllActors(class'ScriptedPawn', sp)
        if (sp.BindName == bindName)
            victim = sp;
    if (victim == none)
    {
        Report("KILL no pawn bound as " $ bindName);
        return;
    }
    victim.TakeDamage(1000, Player, victim.Location + vect(0, 0, 30), vect(0, 0, 0), 'Shot');
    Report("KILL " $ victim.Name $ " invincible=" $ victim.bInvincible $
        " health=" $ victim.Health $ " state=" $ victim.GetStateName());
}

function Bodies()
{
    local DeusExCarcass c;
    local int n;

    foreach AllActors(class'DeusExCarcass', c)
    {
        n++;
        Report("BODY " $ c.Class.Name $ " '" $ c.itemName $ "' mesh=" $ c.Mesh $
            " scale=" $ c.DrawScale $ " skins=" $ c.MultiSkins[0] $ "," $ c.MultiSkins[3] $ "," $ c.MultiSkins[6]);
    }
    Report("BODIES " $ n);
}

function ConList(string bindName)
{
    local Actor a;
    local ConListItem item;

    foreach AllActors(class'Actor', a)
        if (a.BindName == bindName)
            break;
    if (a == none)
    {
        Report("CONLIST no actor bound as " $ bindName);
        return;
    }
    Report("CONLIST " $ a.Name $ " time=" $ int(Level.TimeSeconds) $ " lastConEnd=" $ int(a.LastConEndTime));
    for (item = ConListItem(a.conListItems); item != none; item = item.next)
        if (item.con != none)
            Report("  " $ item.con.conName $ " radius=" $ item.con.bInvokeRadius $ ":" $ item.con.radiusDistance $
                   " frob=" $ item.con.bInvokeFrob $ " once=" $ item.con.bDisplayOnce $
                   " lastPlayed=" $ int(item.con.lastPlayedTime) $
                   " played=" $ Player.FlagBase.GetBool(Player.rootWindow.StringToName(item.con.conName $ "_Played")) $
                   " flags:" $ FlagRefsText(item.con.flagRefList));
}

defaultproperties
{
    pollInterval=1.0
    bWatchL2=true

    // the flags OpheliaL2.con uses, and the ones Chapter06L2 sets
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
    bHidden=true
    RemoteRole=ROLE_None
}
