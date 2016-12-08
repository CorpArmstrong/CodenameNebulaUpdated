//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ConfuseDeviceTrigger extends CNNSimpleTrigger;

var() name deviceTag;
var() bool isLoopConfusing;
var   bool isLoopConfusingNow;
var() float confusionDuration;

//var bool isAlreadyRunning;
var Actor device;

singular function ActivatedON()
{
	isLoopConfusingNow = isLoopConfusing;


		if (isLoopConfusingNow)
		{
//			isAlreadyRunning = true;
			SetTimer(0.01, false);
		}
		else
		{
			SeekAndConfuse();
		}


	super.ActivatedON();
}

singular function ActivatedOFF()
{
    isLoopConfusingNow = false;
//    isAlreadyRunning = false;
    DebugInfo("+TimerConfuse inside ActivatedOFF.");
	super.ActivatedOFF();
}

function Timer()
{
	DebugInfo("+TimerConfuse inside timer.");
	if (isLoopConfusingNow)
	{
		SeekAndConfuse();
		SetTimer(confusionDuration, false);
		DebugInfo("+TimerConfuse inside loopconfusing.");
	}
}

function SeekAndConfuse()
{
	foreach AllActors(class'Actor', device, deviceTag)
	{
		if (device.IsA('HackableDevices') || device.IsA('AutoTurret'))
		{
			device.TakeDamage(0, none, device.Location, vect(0,0,0), 'EMP');
			DebugInfo("+TimerConfuse inside confuse.");
		}
	}
}

DefaultProperties
{
	confusionDuration=5.01
}
