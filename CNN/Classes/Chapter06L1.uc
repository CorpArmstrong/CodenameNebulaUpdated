//-----------------------------------------------------------
// Mission01 - Lower level (low level)
//-----------------------------------------------------------
class Chapter06L1 expands MissionScript;

var bool bLasersOn;
var LaserSecurityDispatcher laserDipatcher;
var bool bFirstFrame;

var name scriptedPawnTag;
var () name CamTag;
var int TantalusSkillLevel;

// ----------------------------------------------------------------------
// FirstFrame()
//
// Stuff to check at first frame
// ----------------------------------------------------------------------
function FirstFrame()
{
	local ScriptedPawn pawn;
	Super.FirstFrame();

	foreach AllActors(class 'ScriptedPawn', pawn, scriptedPawnTag)
		pawn.EnterWorld();
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
	local LaserSecurityDispatcher LSD;	// Lucy in the Sky with Diamonds :)   

	if (player != None)
	{
		if (!bFirstFrame)
		{
			bFirstFrame = true;
			
			foreach AllActors(class'LaserSecurityDispatcher', LSD)
			{
				laserDipatcher = LSD;
			}
			
			if (laserDipatcher == None)
			{
				laserDipatcher = Spawn(class'LaserSecurityDispatcher');
			}
			
			TantalusSkillLevel = Player.SkillSystem.GetSkillLevelValue(class'AiSkillFrench');

			if (TantalusSkillLevel == 2.00)
			{
				flags.SetBool('French_Elementary', true);
			}
			
			// State 0: Go to State 1
			if (!flags.GetBool('laserSecurityWorks'))
			{
				flags.SetBool('laserSecurityWorks', false);
				bLasersOn = true;
			}
		}
		
		ProcessLasers();
	}
	
	Super.Timer();
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
					player.ClientMessage("cam+");
				}
			}

			player.ClientMessage("TogleOn âêëþ÷èë");
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
					player.ClientMessage("cam-");
				}
			}

			player.ClientMessage("TogleOff âûêëþ÷èë");
		}

		bLasersOn = false;
	}
}

defaultproperties
{
	CamTag='
	scriptedPawnTag=Secretary
}
