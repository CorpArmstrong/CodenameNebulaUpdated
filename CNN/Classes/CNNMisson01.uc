//-----------------------------------------------------------
// Mission01 - Lower level (low level)
//-----------------------------------------------------------
class CNNMisson01 expands CNNBaseIngameCutscene;

var bool bLasersOn, bLasersOff;
var LaserSecurityDispatcher laserDipatcher;
var bool bFirstFrame;

var() name CamTag;

function InitLaserSystem()
{
    laserDipatcher = Spawn(class'LaserSecurityDispatcher');
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

	if (/*!bFirstFrame && */!flags.GetBool('isIntroPlayed'))
	{
		InitLaserSystem();
		bFirstFrame = true;
		flags.SetBool('laserSetUp', true, true, 0);
	}

	if (player != None /*&& flags.GetBool('isIntroPlayed')*/)
	{
		if(flags.GetBool('laserSecurityWorks') == true)
        {
			if (!bLasersOn)
			{
				foreach AllActors(class'DamageLaserTrigger', A)
					A.Trigger(None, None);

				if (laserDipatcher != None)
				{
					laserDipatcher.ToggleOn();

					foreach AllActors(class'SecurityCamera', Cam)
					{
						if (Cam.Tag == 'SCam1' && !Cam.bActive)
						{
							player.ToggleCameraState(cam, None);
							player.ClientMessage("cam+");
						}
					}

					player.ClientMessage("TogleOn включил");
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
					A.UnTrigger(None, None);

				if (laserDipatcher != None)
				{
					laserDipatcher.ToggleOff();

					foreach AllActors(class'SecurityCamera', Cam)
					{
						if (Cam.Tag == 'SCam1' && Cam.bActive)
						{
                            player.ToggleCameraState(cam, None);
			   	   	   		player.ClientMessage("cam-");
			       		}
			       }

               	   player.ClientMessage("TogleOff выключил");
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
	CamTag=''
	//sendToLocation="50_OpheliaL1_Burning_Cutscene#loc2"
	sendToLocation="50_OpheliaL1-v25"
	conversationName=OpheliaUICutscene
	actorTag=Secretary
}
