//-----------------------------------------------------------
//  LaserSecurityDispatcher
//-----------------------------------------------------------
class LaserSecurityDispatcher expands Actor;

var() float delay;
var() name targetTag[4];
var() bool bIsOn;

// Need for return lazer movers to waiting position
// when lazer system is disabled.
// For preventing player damage by mover
var bool bLazersMoveInsideNow;

function Timer()
{
    if(bIsOn)
	{
		SendMessages();
	}

    bLazersMoveInsideNow = !bLazersMoveInsideNow;
}

function SendMessages()
{
    local Mover m;
    local int i;

	for (i = 0; i < ArrayCount(targetTag); i++)
	{
		foreach AllActors(class 'Mover', m, targetTag[i])
		{
			m.Trigger(Self, None);
		}
	}
}

function ToggleOn()
{
    bIsOn = true;
    bLazersMoveInsideNow = true;
    SendMessages();
    SetTimer(delay, true);
}

function ToggleOff()
{
    bIsOn = false;

	if (bLazersMoveInsideNow)
	{
		// for return on default positions
		SendMessages();
	}

	SetTimer(0.1, false);
}

defaultproperties
{
	bIsOn=false
     Delay=20.000000
     targetTag(0)=LaserEmittersMoverFR
     targetTag(1)=LaserEmittersMoverFL
     targetTag(2)=LaserEmittersMoverBR
     targetTag(3)=LaserEmittersMoverBL
}
