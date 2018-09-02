//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ConfuseDeviceTrigger extends CNNSimpleTrigger;

var() name deviceTag;
var() bool isLoopConfusing;
var   bool isLoopConfusingNow;
var() float confusionDuration;

var Actor device;

singular function ActivatedON()
{
	isLoopConfusingNow = isLoopConfusing;

	if (isLoopConfusingNow)
	{
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
	super.ActivatedOFF();
}

function Timer()
{
	if (isLoopConfusingNow)
	{
		SeekAndConfuse();
		SetTimer(confusionDuration, false);
	}
}

function SeekAndConfuse()
{
	foreach AllActors(class'Actor', device, deviceTag)
	{
		if (device.IsA('HackableDevices') || device.IsA('AutoTurret'))
		{
			device.TakeDamage(0, none, device.Location, vect(0,0,0), 'EMP');
		}
	}
}

defaultproperties
{
	confusionDuration=5.01
}
