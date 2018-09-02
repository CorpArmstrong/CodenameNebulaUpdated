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
    local LaserSecurityDispatcher LSD;	// Lucy in the Sky with Diamonds :)
	local SecurityCamera cam;

    flags = DeusExPlayer(GetPlayerPawn()).flagBase;
    isSecurityActive = flags.GetBool('laserSecurityWorks');

    foreach AllActors(class'LaserSecurityDispatcher', LSD)
	{
		laserDispatcher = LSD;
	}

	foreach AllActors(class'SecurityCamera', Cam, CamTag)
	{
		sCam = cam;
	}

	if (!flags.GetBool('Meet1InspRoom_Played'))
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

	flags.SetBool('laserSecurityWorks', false);
    isSecurityActive = false;

    SetSecurityCamera_bNoAlarm(true);
}

function SetSecurityCamera_bNoAlarm(bool bNoAlarm)
{
    sCam.bNoAlarm = bNoAlarm;
}

defaultproperties
{
    CamTag=SCam1
}
