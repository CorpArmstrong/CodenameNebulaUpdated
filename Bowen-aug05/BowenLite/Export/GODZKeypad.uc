//================================================================================
// GODZKeypad.
//================================================================================
class GODZKeypad extends Keypad;

var config string GODZCodes[64];
var config string GODZNames[64];
var config int CodeLength;
var() name TargetTurret;

replication
{
	un?reliable if ( Role == 4 )
		GODZCodes,GODZNames,CodeLength;
}

function HackAction (Actor Hacker, bool bHacked)
{
	local DeusExPlayer Player;

	if ( keypadwindow != None )
	{
		return;
	}
	Player=DeusExPlayer(Hacker);
	if ( Player != None )
	{
		Player.ActivateKeypadWindow(self,bHacked);
	}
}

simulated function ActivateKeypadWindow (DeusExPlayer Hacker, bool bHacked)
{
	local DeusExRootWindow Root;

	Root=DeusExRootWindow(Hacker.RootWindow);
	if ( Root != None )
	{
		keypadwindow=GODZKeypadWindow(Root.InvokeUIScreen(Class'GODZKeypadWindow',True));
		Root.MaskBackground(True);
		if ( keypadwindow != None )
		{
			GODZKeypadWindow(keypadwindow).keypadOwner=self;
			keypadwindow.Player=Hacker;
			keypadwindow.bInstantSuccess=bHacked;
			keypadwindow.InitData();
		}
	}
}

function RunEvents (DeusExPlayer Player, bool bSuccess)
{
	local Actor A;

	if ( Role == 4 )
	{
		if ( bSuccess )
		{
			OnTurrets(Player);
			if ( Event != 'None' )
			{
				foreach AllActors(Class'Actor',A,Event)
				{
					A.Trigger(self,Player);
					continue;
				}
			}
		}
		else
		{
			PunishHacker(Player);
			if ( FailEvent != 'None' )
			{
				foreach AllActors(Class'Actor',A,FailEvent)
				{
					A.Trigger(self,Player);
					continue;
				}
			}
		}
	}
}

function PunishHacker (DeusExPlayer Player)
{
	Player.Alliance=Player.Default.Alliance;
}

function OnTurrets (DeusExPlayer Player)
{
}

defaultproperties
{
    RemoteRole=2
    Mesh=LodMesh'DeusExDeco.Keypad1'
    CollisionRadius=4.00
    CollisionHeight=6.00
}