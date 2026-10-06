//-----------------------------------------------------------------------
// Class:    CNNSocialBoss
//-----------------------------------------------------------------------
// The Social Boss scene on L2: Mephistopheles and Wong at the ship's
// wheel. OpheliaL2.con's SocialBoss is written and voiced, but its
// hostages carry other names than the pawns on the bridge, and its
// executions and shots are comments the engine skips. This actor names
// the hostages, arms Wong, follows the conversation and acts out the
// shots, and starts the fight. Spawned by Chapter06L2; being a level
// actor, it is saved with the game.
//-----------------------------------------------------------------------
class CNNSocialBoss extends Info;

// The events acted out, by index -- see Validate(). Each is the spoken
// line after the placeholder: lines wait for their audio, so the
// per-frame watch never misses them.
const TROOPER_SHOT   = 7;   // Tantalus "Son of a bitch!" (after TRIGGER MikeExecutesMJ12Troop)
const ARMSTRONG_SHOT = 27;  // Tantalus "Armstrong!", after his groan -- a speaker
                            // killed on his own line aborts the scene
const JOHNSON_SHOT   = 39;  // Tantalus "No!!!", after Johnson's plea
const SAMANTHA_SHOT  = 54;  // Wong "You are NEXT", after "Samantha, your mother..."
const MEPH_SHOT_A    = 66;  // "So mote it be." -- Apologize branch
const MEPH_SHOT_B    = 77;  // "So mote it be." -- Manipulate branch
const WONG_TURNS_A   = 67;  // Wong "Your Chinese sucks heck."
const WONG_TURNS_B   = 78;  // Wong "You still Dontgivafucker!"

var DeusExPlayer Player;
var ScriptedPawn trooper;       // the MJ12 hostage spawned for the opening execution
var bool bStarted;
var bool bFight;
var bool bReleased;
var bool bWongHostile;
var bool bMephHostile;
var Conversation watchedCon;
var ConEvent lastSeenEvent;

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
    RebindHostages();
    SetCarcasses();
    ProtectCast();
    Validate();
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

// Their bodies keep the looks the map gives them.
function SetCarcasses()
{
    SetCarcass(FindPawn("DrMephistopheles"), class'MephistophelesCarcass');
    SetCarcass(FindPawn("MikeWong"), class'MikeWongCarcass');
    SetCarcass(FindPawn("CorpArmstrongHostage"), class'CArmstrongDeadCarcass');
    SetCarcass(FindPawn("SamanthaReedHostage"), class'SamanthaReedCarcass');
}

function SetCarcass(ScriptedPawn p, class<Carcass> carcassClass)
{
    if (p != none)
        p.CarcassType = carcassClass;
}

// Everyone in the scene stays alive until it starts. The executions and
// the fight lift this for the pawn concerned.
function ProtectCast()
{
    if (bStarted)
        return;

    Protect(FindPawn("DrMephistopheles"));
    Protect(FindPawn("MikeWong"));
    Protect(FindPawn("CorpArmstrongHostage"));
    Protect(FindPawn("DrJohnsonHostage"));
    Protect(FindPawn("SamanthaReedHostage"));
    Protect(trooper);
}

function Protect(ScriptedPawn p)
{
    if (p == none)
        return;
    p.bInvincible = true;
    Log("CNN L2: social boss -- " $ p.Name $ " (" $ p.BindName $ ") protected until the scene");
}

function Conversation FindConversation()
{
    local ScriptedPawn meph;
    local ConListItem item;

    meph = FindPawn("DrMephistopheles");
    if (meph == none)
        return none;
    for (item = ConListItem(meph.conListItems); item != none; item = item.next)
        if ((item.con != none) && (item.con.conName == 'SocialBoss'))
            return item.con;
    return none;
}

function ConEvent EventAt(Conversation con, int index)
{
    local ConEvent ev;
    local int i;

    for (ev = con.eventList; (ev != none) && (i < index); ev = ev.nextEvent)
        i++;
    return ev;
}

// The event numbers above fit the shipped .con; warn if it ever changes.
function Validate()
{
    local Conversation con;
    local bool bOk;

    con = FindConversation();
    if (con == none)
    {
        Log("CNN L2: social boss conversation not found");
        return;
    }

    bOk = (ConEventTrigger(EventAt(con, TROOPER_SHOT - 1)) != none) &&
          (ConEventSpeech(EventAt(con, TROOPER_SHOT)) != none) &&
          (ConEventSpeech(EventAt(con, ARMSTRONG_SHOT)) != none) &&
          (ConEventSpeech(EventAt(con, JOHNSON_SHOT)) != none) &&
          (ConEventSpeech(EventAt(con, SAMANTHA_SHOT)) != none) &&
          (ConEventSpeech(EventAt(con, MEPH_SHOT_A)) != none) &&
          (ConEventSpeech(EventAt(con, MEPH_SHOT_B)) != none) &&
          (ConEventSpeech(EventAt(con, WONG_TURNS_A)) != none) &&
          (ConEventSpeech(EventAt(con, WONG_TURNS_B)) != none) &&
          (EventAt(con, 56).label == "AttackMeph") &&
          (EventAt(con, 58).label == "GiveUp");

    if (bOk)
        Log("CNN L2: social boss event layout as expected");
    else
        Log("CNN L2: WARNING social boss event layout changed -- executions may hit the wrong lines");
}

// ----------------------------------------------------------------------
// Prepare()
//
// The bridge opens: arm Wong, bring in the MJ12 hostage, and move
// Mephistopheles off the wheel to stand beside Wong.
// ----------------------------------------------------------------------

function Prepare()
{
    local ScriptedPawn wong, t;
    local vector spot;
    local int i;

    // normally set by Daedalus's infolink, which can be missed
    Player.flagBase.SetBool('ReadyForSocialBoss', true);

    wong = FindPawn("MikeWong");
    if (wong != none)
    {
        GiveWeapon(wong, class'WeaponPistol');

        spot = wong.Location + vect(-70, 70, 0);
        t = Spawn(class'MJ12Troop',,, spot, wong.Rotation);
        if (t == none)
            t = Spawn(class'MJ12Troop',,, wong.Location + vect(70, 70, 0), wong.Rotation);
    }
    if (t != none)
    {
        for (i = 0; i < ArrayCount(t.InitialInventory); i++)
            t.InitialInventory[i].Inventory = none;
        t.InitializePawn();
        t.ChangeAlly('Player', 1, true);
        t.SetOrders('Standing', '', true);
        trooper = t;
    }
    ProtectCast();
    Log("CNN L2: social boss prepared -- Wong armed=" $ (wong != none) $ " MJ12 hostage=" $ (trooper != none));

    MoveMephistophelesNextToWong();
}

function GiveWeapon(ScriptedPawn p, class<Inventory> weaponClass)
{
    if (p.FindInventoryType(weaponClass) != none)
        return;
    p.InitialInventory[0].Inventory = weaponClass;
    p.InitialInventory[0].Count = 1;
    p.InitializeInventory();
}

// Mephistopheles stands in front of the wheel and blocks it. Put him
// beside Wong, facing the same way.
function MoveMephistophelesNextToWong()
{
    local ScriptedPawn meph, wong;
    local vector offset[4];
    local rotator facing;
    local int i;

    wong = FindPawn("MikeWong");
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

// Wong shoots someone during the conversation. The victim is taken out of
// it first; a participant's death would end the scene.
function WongExecutes(ScriptedPawn victim)
{
    local ScriptedPawn wong;
    local int k;

    if (!IsAlive(victim))
        return;

    wong = FindPawn("MikeWong");
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
// Tick()
//
// Follows the player's conversation every frame and acts on the scene's
// events as they come up.
// ----------------------------------------------------------------------

function Tick(float deltaTime)
{
    local ConEvent ev;

    Super.Tick(deltaTime);

    if (!IsPlaying())
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

    ev = Player.conPlay.currentEvent;
    if ((ev != none) && (ev != lastSeenEvent))
    {
        lastSeenEvent = ev;
        EventStarted(watchedCon, ev);
    }
}

function bool IsPlaying()
{
    return (Player != none) && (Player.conPlay != none) && (Player.conPlay.con != none) &&
           (Player.conPlay.con.conName == 'SocialBoss');
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

function EventStarted(Conversation con, ConEvent ev)
{
    local ConEvent scan;
    local int i;

    for (scan = con.eventList; (scan != none) && (scan != ev); scan = scan.nextEvent)
        i++;
    if (scan == none)
        return;

    if (i == 0)
    {
        bStarted = true;
        Player.GoalCompleted('MeetDaedalusInTheCommandCenter');
        Log("CNN L2: social boss started, MJ12 timer at " $ Player.flagBase.GetInt('MJ12SecondsLeft') $ "s");
    }

    if (i == TROOPER_SHOT)
        WongExecutes(trooper);
    else if (i == ARMSTRONG_SHOT)
        WongExecutes(FindPawn("CorpArmstrongHostage"));
    else if (i == JOHNSON_SHOT)
        WongExecutes(FindPawn("DrJohnsonHostage"));
    else if (i == SAMANTHA_SHOT)
        WongExecutes(FindPawn("SamanthaReedHostage"));
    else if ((i == MEPH_SHOT_A) || (i == MEPH_SHOT_B))
    {
        Player.flagBase.SetBool('WongBetrayedMeph', true);
        // Wong turns on the player right after
        bFight = true;
        WongExecutes(FindPawn("DrMephistopheles"));
    }
    else if ((i == WONG_TURNS_A) || (i == WONG_TURNS_B))
        bFight = true;

    if (ev.label == "AttackMeph")
        bFight = true;
    else if (ev.label == "GiveUp")
        Player.flagBase.SetBool('PlayerGaveUp', true);
}

// ----------------------------------------------------------------------
// Timer()
//
// After ATTACK, or once Wong turns, whoever of the two is alive fights.
// Both are civilians and would run, so keep them attacking.
// ----------------------------------------------------------------------

function Timer()
{
    local ScriptedPawn wong, meph;

    if (Player == none)
        return;

    // if the scene is cut short, the two must not stay immortal
    if (bStarted && !bReleased && !IsPlaying())
    {
        bReleased = true;
        wong = FindPawn("MikeWong");
        meph = FindPawn("DrMephistopheles");
        if (wong != none)
            wong.bInvincible = false;
        if (meph != none)
            meph.bInvincible = false;
    }

    if (!bFight || Player.IsInState('Conversation') || (Player.conPlay != none))
        return;

    wong = FindPawn("MikeWong");
    meph = FindPawn("DrMephistopheles");

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
    Log("CNN L2: social boss -- " $ p.Name $ " turns on the player, MJ12 timer at " $ Player.flagBase.GetInt('MJ12SecondsLeft') $ "s");
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

// The wheel opens once Mephistopheles and Wong are both dead.
function bool IsBridgeClear()
{
    return !IsAlive(FindPawn("DrMephistopheles")) && !IsAlive(FindPawn("MikeWong"));
}

defaultproperties
{
}
