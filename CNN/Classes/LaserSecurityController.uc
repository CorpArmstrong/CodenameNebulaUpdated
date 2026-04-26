//-----------------------------------------------------------
// LaserSecurityController
//-----------------------------------------------------------
class LaserSecurityController extends Trigger;

var() name CamTag;

var private LaserSecurityDispatcher laserDispatcher;
var private SecurityCamera sCam;
var private bool isSecurityActive;
var private FlagBase flags;

function PostBeginPlay()
{
    local LaserSecurityDispatcher LSD;  // Lucy in the Sky with Diamonds :)
    local SecurityCamera cam;
    local DeusExPlayer player;
    local bool bMeet1InspRoomPlayed;

    foreach AllActors(class'LaserSecurityDispatcher', LSD)
    {
        laserDispatcher = LSD;
    }

    foreach AllActors(class'SecurityCamera', Cam, CamTag)
    {
        sCam = cam;
    }

    player = DeusExPlayer(GetPlayerPawn());
    if (player != none && player.flagBase != none)
    {
        flags = player.flagBase;
        isSecurityActive = flags.GetBool('laserSecurityWorks');
        bMeet1InspRoomPlayed = flags.GetBool('Meet1InspRoom_Played');
    }
    // else flags stays None and bMeet1InspRoomPlayed stays false (default).
    // We still call TurnOffLasers below: lasers must be off until the
    // scripted sequence has fired, even if we couldn't read the flag.

    if (!bMeet1InspRoomPlayed)
    {
        TurnOffLasers();
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    if (isSecurityActive)
    {
        TurnOffLasers();
    }
    else
    {
        TurnOnLasers();
    }
}

function TurnOnLasers()
{
    local DamageLaserTrigger A;

    foreach AllActors(class'DamageLaserTrigger', A)
    {
        A.Trigger(none, none);
    }

    if (laserDispatcher != none)
    {
        laserDispatcher.ToggleOn();
    }

    if (flags != none)
        flags.SetBool('laserSecurityWorks', true);
    isSecurityActive = true;

    SetSecurityCamera_bNoAlarm(false);
}

function TurnOffLasers()
{
    local DamageLaserTrigger A;

    foreach AllActors(class'DamageLaserTrigger', A)
    {
        A.UnTrigger(none, none);
    }

    if (laserDispatcher != none)
    {
        laserDispatcher.ToggleOff();
    }

    if (flags != none)
        flags.SetBool('laserSecurityWorks', false);
    isSecurityActive = false;

    SetSecurityCamera_bNoAlarm(true);
}

function SetSecurityCamera_bNoAlarm(bool bNoAlarm)
{
    if (sCam != none)
        sCam.bNoAlarm = bNoAlarm;
}

defaultproperties
{
    CamTag=SCam1
}