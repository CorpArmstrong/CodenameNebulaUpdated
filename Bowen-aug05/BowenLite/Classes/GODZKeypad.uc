//=============================================================================
// GODZKeypad. 	(c) 2003 JimBowen
//=============================================================================
class GODZKeypad expands Keypad;

var config string GODZCodes[64];
var config string GODZNames[64];
var config int CodeLength;
var() name TargetTurret;

replication
{
	reliable if (ROLE == ROLE_Authority)
		CodeLength, GODZNames, GODZCodes;
}

// ----------------------------------------------------------------------
// HackAction()
// ----------------------------------------------------------------------

function HackAction(Actor Hacker, bool bHacked)
{
	local DeusExPlayer Player;

	// if we're already using this keypad, get out
	if (keypadwindow != None)
		return;

	Player = DeusExPlayer(Hacker);

	if (Player != None)
	{
      // DEUS_EX AMSD if we are in multiplayer, just act based on bHacked
      // if you want keypad windows to work in multiplayer, just get rid of this
      // if statement.  I've already got the windows working, they're just disabled.
     /* if (Level.NetMode != NM_Standalone)
      {
         if (bHacked)
         {
            ToggleLocks(Player);
            RunEvents(Player,True);
            RunUntriggers(Player);
         }
         return;
      }*/
      
      //DEUS_EX AMSD Must call in player for replication to work.
      Player.ActivateKeypadWindow(Self, bHacked);
	}
}





// ----------------------------------------------------------------------
// ActivateKeypadWindow
// DEUS_EX AMSD Bounce back call from player so function rep works right.
// ----------------------------------------------------------------------
simulated function ActivateKeypadWindow(DeusExPlayer Hacker, bool bHacked)
{
	local DeusExRootWindow root;


   root = DeusExRootWindow(Hacker.rootWindow);
   if (root != None)
   {
      keypadwindow = GODZKeypadWindow(root.InvokeUIScreen(Class'GODZKeypadWindow', True));
      root.MaskBackground(True);
      
      // copy the tag data to the actual class
      if (keypadwindow != None)
      {
         GODZKeypadWindow(keypadwindow).keypadOwner = Self;
         keypadwindow.player = Hacker;
         keypadwindow.bInstantSuccess = bHacked;
         keypadwindow.InitData();
      }
   }
}


// ----------------------------------------------------------------------
// RunEvents()
// ----------------------------------------------------------------------
function RunEvents(DeusExPlayer Player, bool bSuccess)
{
   local Actor A;
	if (Role == Role_Authority)
	{
   		if (bSuccess)
   		{
		//	AllySentinels(Player);
			OnTurrets(Player);
			if(Event != '')
    			foreach AllActors(class 'Actor', A, Event)
        			A.Trigger(Self, Player);
   		}
   		else   		{
			PunishHacker(Player);
			if(FailEvent != '')
    			foreach AllActors(class 'Actor', A, FailEvent)
      				A.Trigger(Self, Player);
   		}
   	}
}


// ----------------------------------------------------------------------
// PunishHacker()
// ----------------------------------------------------------------------
function PunishHacker(DeusExPlayer Player)
{
	Player.Alliance = Player.Default.Alliance;
}


// ----------------------------------------------------------------------
// AllySentinels()
// ----------------------------------------------------------------------
/*function AllySentinels(DeusExPlayer Player)
{
//	Player.SmellClass = class'BowenLite.BowenSmell';
	Player.Alliance = 'GODZ';
	Player.ClientMessage ("Access granted. The GODZ turrets will no longer target you");  
}*/


// ----------------------------------------------------------------------
// OnTurrets()
// ----------------------------------------------------------------------
function OnTurrets(DeusExPlayer Player)
{
/*	local String str;
	local GODZTurret turret;
	
	if (TargetTurret == '')
		return;

	foreach allactors (class'GODZTurret', turret, TargetTurret)
	{
		if (turret.SafeTarget == Player)
		{
			Turret.bDisabled = True;
			Player.BroadcastMessage (Player.PlayerReplicationInfo.PlayerName $ " Turned off the " $ turret.TitleString);
			return;
		}
		
	 	turret.bTrackPlayersOnly = False;
  		turret.bTrackPawnsOnly   = True;
		turret.bComputerReset = False;
	
		turret.bDisabled = False;
		turret.bActive = True;

		Player.BroadcastMessage (Player.PlayerReplicationInfo.PlayerName $ " Now owns the " $ turret.TitleString);

   		//in multiplayer, behave differently
  		 //set the safe target to ourself.
   		if (Level.NetMode != NM_Standalone)
   		{
			turret.SetSafeTarget( Player );

			if (Role == ROLE_Authority)
			{
					turret.team = Player.PlayerReplicationInfo.PlayerID;
		
			}
   		}
	}
*/
}

//---END-CLASS---

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     Mesh=LodMesh'DeusExDeco.Keypad1'
     CollisionRadius=4.000000
     CollisionHeight=6.000000
}
