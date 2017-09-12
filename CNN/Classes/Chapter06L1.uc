//-----------------------------------------------------------
// Mission01 - Lower level (low level)
//-----------------------------------------------------------
class Chapter06L1 expands MissionScript;

var bool bLasersOn;
var LaserSecurityDispatcher laserDipatcher;
var(ChangeLevelOnDeath) string levelName;

var () name CamTag;
var int TantalusSkillLevel;

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
	if (player != none)
	{
		ProcessLasers();
		
		if (player.IsInState('Dying'))
		{
			Level.Game.SendPlayer(player, levelName);
		}
	}
	
	Super.Timer();
}

function PrepareFirstFrame()
{
	local LaserSecurityDispatcher LSD;	// Lucy in the Sky with Diamonds :)	
		
	foreach AllActors(class'LaserSecurityDispatcher', LSD)
	{
		laserDipatcher = LSD;
	}
	
	TantalusSkillLevel = Player.SkillSystem.GetSkillLevelValue(class'AiSkillFrench');

	if (TantalusSkillLevel == 2.00)
	{
		flags.SetBool('French_Elementary', true);
	}
	
	// Security System State 0: Go to State 1
	if (!flags.GetBool('laserSecurityWorks'))
	{
		flags.SetBool('laserSecurityWorks', false);
		bLasersOn = true;
	}
}

function ProcessLasers()
{
	local Mover mv;
    local DamageLaserTrigger A;
	local SecurityCamera Cam;
	
	// State 1: Security is active and lasers are off -> Turn on lasers!
	if(flags.GetBool('laserSecurityWorks') && !bLasersOn)
	{
		foreach AllActors(class'DamageLaserTrigger', A)
		{
			A.Trigger(None, None);
		}

		if (laserDipatcher != None)
		{
			laserDipatcher.ToggleOn();

			foreach AllActors(class'SecurityCamera', Cam)
			{
				if (Cam.Tag == 'SCam1' && !Cam.bActive)
				{
					player.ToggleCameraState(cam, none);
				}
			}
		}

		bLasersOn = true;
	}
	
	// State 2: Security is inactive and lasers are on -> Turn off lasers!
	if(!flags.GetBool('laserSecurityWorks') && bLasersOn)
	{
		foreach AllActors(class'DamageLaserTrigger', A)
		{
			A.UnTrigger(None, None);
		}

		if (laserDipatcher != None)
		{
			laserDipatcher.ToggleOff();

			foreach AllActors(class'SecurityCamera', Cam)
			{
				if (Cam.Tag == 'SCam1' && Cam.bActive)
				{
					player.ToggleCameraState(cam, none);
				}
			}
		}

		bLasersOn = false;
	}
}

defaultproperties
{
	levelName="06_OpheliaL2#HumanServer"
}
