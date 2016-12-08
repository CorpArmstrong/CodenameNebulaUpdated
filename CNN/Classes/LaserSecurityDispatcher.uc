//-----------------------------------------------------------
//  LaserSecurityDispatcher
//-----------------------------------------------------------
class LaserSecurityDispatcher expands Actor;
var() float delay;
var() name targetTag[4];
var() bool bIsOn;

var bool bLazersMoveInsideNow; // need for return lazer movers to waiting position
                               // when lazer system is disabled.
							   // for preventing damage player by mover

function PostBeginPlay()
{
    DeusExPlayer(GetPlayerPawn()).ClientMessage("!!!!!!!!!!!!!!");
}

function Timer()
{
    if( bIsOn )
		SendMessages();

    bLazersMoveInsideNow = !bLazersMoveInsideNow;

    DeusExPlayer(GetPlayerPawn()).ClientMessage("function Timer()");
}

function SendMessages()
{
    local Mover m;
    local int i;

        for (i = 0; i < 4; i ++ )
            foreach AllActors( class 'Mover', m, targetTag[i] )
        	    m.Trigger( Self, None );

}

function Tick(float fDT)
{


Super.Tick(fDT);
}

function ToggleOn()
{
    bIsOn = true;
    bLazersMoveInsideNow = true;
    SendMessages();
    SetTimer(delay, true);
    DeusExPlayer(GetPlayerPawn()).ClientMessage("function ToggleOn()");
}

function ToggleOff()
{
    bIsOn = false;

	if (bLazersMoveInsideNow)
		SendMessages();// for return on deffault positions

	SetTimer(0.1, false);
    DeusExPlayer(GetPlayerPawn()).ClientMessage("function ToggleOff()");
}

defaultproperties
{
     Delay=20.000000
     targetTag(0)=LaserEmittersMoverFR
     targetTag(1)=LaserEmittersMoverFL
     targetTag(2)=LaserEmittersMoverBR
     targetTag(3)=LaserEmittersMoverBL
}
