//-----------------------------------------------------------
// Mission01 - Lower level (low level)
//-----------------------------------------------------------
class Chapter06L1 expands MissionScript;

var bool bLasersOn, bLasersOff;
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

function InitLaserSystem()
{
    laserDipatcher = Spawn(class'LaserSecurityDispatcher');
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
    local Mover mv;
    local DamageLaserTrigger A;
    local SecurityCamera Cam;

    TantalusSkillLevel = Player.SkillSystem.GetSkillLevelValue(class'AiSkillFrench');

    if (TantalusSkillLevel == 2.00)
    {
		flags.SetBool('French_Elementary',True);
	}

    if (!bFirstFrame)
    {
        InitLaserSystem();
        bFirstFrame = true;

        //flags.SetBool('laserSecurityWorks', true);
    }

    if ((player != None))
    {
        if(flags.GetBool('laserSecurityWorks'))
        {
           if (!bLasersOn)
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

           bLasersOff = false;
        }
        else
        {
           if (!bLasersOff)
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

              bLasersOff = true;
           }

           bLasersOn = false;
        }
    }

	Super.Timer();
}

defaultproperties
{
     CamTag='
     scriptedPawnTag=Secretary
}

