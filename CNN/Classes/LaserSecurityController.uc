//-----------------------------------------------------------
// LaserSecurityController
//-----------------------------------------------------------
class LaserSecurityController extends Trigger;

var private FlagBase fBase;
var private bool isSecurityActive;

var LaserSecurityDispatcher laserDispatcher;
var SecurityCamera sCam;
var() name CamTag;

function PostBeginPlay()
{
    local LaserSecurityDispatcher LSD;	// Lucy in the Sky with Diamonds :)
	local SecurityCamera cam;

    fBase = DeusExPlayer(GetPlayerPawn()).flagBase;
    isSecurityActive = fBase.GetBool('laserSecurityWorks');
    
    foreach AllActors(class'LaserSecurityDispatcher', LSD)
	{
		laserDispatcher = LSD;
	}
	
	foreach AllActors(class'SecurityCamera', Cam, CamTag)
	{
		sCam = cam;
	}

	if (!fBase.GetBool('Meet1InspRoom_Played'))
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
		A.Trigger(None, None);
	}

	if (laserDispatcher != None)
	{
		laserDispatcher.ToggleOn();
	}

	fBase.SetBool('laserSecurityWorks', true);
    isSecurityActive = true;

    SetSecurityCamera_bNoAlarm(false);
}

function TurnOffLasers()
{
	local DamageLaserTrigger A;
	
	foreach AllActors(class'DamageLaserTrigger', A)
	{
		A.UnTrigger(None, None);
	}

	if (laserDispatcher != None)
	{
		laserDispatcher.ToggleOff();
	}

	fBase.SetBool('laserSecurityWorks', false);
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