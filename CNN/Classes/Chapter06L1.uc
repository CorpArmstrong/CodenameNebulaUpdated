//-----------------------------------------------------------
// Mission01 - Lower level (low level)
//-----------------------------------------------------------
class Chapter06L1 expands MissionScript;

var bool bLasersOn;
var LaserSecurityDispatcher laserDispatcher;
var SecurityCamera sCam;
var(ChangeLevelOnDeath) string levelName;
var() name CamTag;

// ----------------------------------------------------------------------
// FirstFrame()
//
// Stuff to check at first frame
// ----------------------------------------------------------------------
function FirstFrame()
{
	Super.FirstFrame();
	PrepareFirstFrame();
}

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
}

// ----------------------------------------------------------------------
// PreTravel()
//
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------
function PreTravel()
{
    Super.PreTravel();
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------
function Timer()
{
	Super.Timer();
	
	if (player.IsInState('Dying'))
	{
		Level.Game.SendPlayer(player, levelName);
	}
	
	UpdateLasers();
}

function PrepareFirstFrame()
{
	local int tantalusSkillLevel;
	local LaserSecurityDispatcher LSD;	// Lucy in the Sky with Diamonds :)
	local SecurityCamera cam;
		
	foreach AllActors(class'LaserSecurityDispatcher', LSD)
	{
		laserDispatcher = LSD;
	}
	
	foreach AllActors(class'SecurityCamera', Cam, CamTag)
	{
		sCam = cam;
	}
	
	tantalusSkillLevel = player.SkillSystem.GetSkillLevelValue(class'AiSkillFrench');

	if (tantalusSkillLevel == 2.00)
	{
		flags.SetBool('French_Elementary', true);
	}
	
	// Security System State 0: Go to State 1
	if (!flags.GetBool('laserSecurityWorks'))
	{
		flags.SetBool('laserSecurityWorks', false);
		bLasersOn = true;
		//sCam.bActive = false;
	}
}

function UpdateLasers()
{
	// State 1: Security is active and lasers are off -> Turn on lasers!
	if(flags.GetBool('laserSecurityWorks') && !bLasersOn)
	{
		TurnOnLasers();
	}
	
	// State 2: Security is inactive and lasers are on -> Turn off lasers!
	if(!flags.GetBool('laserSecurityWorks') && bLasersOn)
	{
		TurnOffLasers();
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

	bLasersOn = true;
	TantalusDenton(player).ToggleCameraStateNoDebugMessage(sCam);
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

	bLasersOn = false;
	TantalusDenton(player).ToggleCameraStateNoDebugMessage(sCam);
}

defaultproperties
{
	CamTag=SCam1
	levelName="06_OpheliaL2#HumanServer"
}
