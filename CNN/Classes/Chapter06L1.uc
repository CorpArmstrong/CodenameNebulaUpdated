//-----------------------------------------------------------
// Chapter06L1 - Ring 1
//-----------------------------------------------------------
class Chapter06L1 expands MissionScript;

var() string levelName;
var() name CamTag;

var private LaserSecurityDispatcher laserDispatcher;
var private SecurityCamera sCam;
var private bool isSecurityActive;

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
}

function FirstFrame()
{
	Super.FirstFrame();
	PrepareFirstFrame();
}

function PrepareFirstFrame()
{
	local int tantalusSkillLevel;
    local LaserSecurityDispatcher LSD;	// Lucy in the Sky with Diamonds :)
	local SecurityCamera cam;
	
	tantalusSkillLevel = player.SkillSystem.GetSkillLevelValue(class'AiSkillFrench');

	if (tantalusSkillLevel == 2.00)
	{
		flags.SetBool('French_Elementary', true);
	}
    
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

function Timer()
{
	Super.Timer();
	
	if (player.IsInState('Dying'))
	{
		Level.Game.SendPlayer(player, levelName);
	}
}

function UpdateLasersState()
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

	flags.SetBool('laserSecurityWorks', true);
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
	levelName="06_OpheliaL2#HumanServer"
    CamTag=SCam1
}