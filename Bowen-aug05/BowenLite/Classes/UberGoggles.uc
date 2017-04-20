//=============================================================================
// UberGoggles.
//=============================================================================
class UberGoggles extends BowenChargedPickup;

var int mpNumLockpicks, VisionLevel, VisionLevelValue;
var DeusExPlayer OrigOwner;

replication
{
	reliable if (Role == ROLE_Authority)
		UpdateHUDDisplay, KillDisplay, VisionLevel, VisionLevelValue;
}

// ----------------------------------------------------------------------
// ChargedPickupBegin()
// ----------------------------------------------------------------------

simulated function ChargedPickupBegin(DeusExPlayer Player)
{
	Super.ChargedPickupBegin(Player);
	if (Level.NetMode == NM_DedicatedServer)
		return;
	/*
	* begin new code
	*
	* Instead of vision aug, just set all to bUnlit
	*/
/*		local Pawn p;
		if (bActive && Owner != None && Level.NetMode == NM_Client)
		{
			foreach allactors (class'Pawn', p)
				p.bUnlit = True;
		}
*/


	DeusExRootWindow(Player.rootWindow).hud.augDisplay.activeCount++;
	UpdateHUDDisplay(Player);
	if(Level.NetMode != NM_StandAlone)
	{
		VisionLevel = 1;
		VisionLevelValue = 0;
	}
	
}

// ----------------------------------------------------------------------
// UpdateHUDDisplay()
// ----------------------------------------------------------------------

simulated function UpdateHUDDisplay(DeusExPlayer Player)
{
	if (Level.NetMode != NM_Standalone)
	{	
		DeusExRootWindow(Player.RootWindow).HUD.AugDisplay.bVisionActive = True;
		DeusExRootWindow(Player.RootWindow).HUD.AugDisplay.VisionLevel = VisionLevel;
		DeusExRootWindow(Player.RootWindow).HUD.AugDisplay.VisionLevelValue = VisionLevelValue;
	}
	
	//Player.RelevantRadius = 8192;
}

// ----------------------------------------------------------------------
// ChargedPickupEnd()
// ----------------------------------------------------------------------

simulated function ChargedPickupEnd(DeusExPlayer Player)
{
	KillDisplay(Player);

	Super.ChargedPickupEnd(Player);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------


simulated function Destroyed()
{
	ChargedPickupEnd(OrigOwner);
	Super.Destroyed();
}

simulated function DropFrom(vector loc)
{
	ChargedPickupEnd(OrigOwner);
	Super.DropFrom(loc);
}

simulated function tick (float deltatime)
{
	/*
	* begin new code
	*
	* Instead of vision aug, just set all to bUnlit
	*/
		local Pawn p;
	/*	if (bActive && Owner != None && Level.NetMode != NM_DedicatedServer)
		{
			foreach allactors (class'Pawn', p)
				p.bUnlit = True;
		}*/
	if (OrigOwner == None && DeusExPlayer(Owner) != None)
		OrigOwner = DeusExPlayer(Owner);
	else if (Owner != None && OrigOwner != Owner)
		Destroy();
	if(bActive && Owner != None)
	{
		SetLocation(Owner.Location);
		class'LocatorBeacon'.Static.UpdateLocatorDisplay(DeusExPlayer(Owner));
	}

	Super.Tick(DeltaTime);
}

simulated function KillDisplay(DeusExPlayer Player)
{
	local Pawn p;
	if (Owner != None && Level.NetMode == NM_Client)
	{
		foreach allactors (class'Pawn', p)
			p.bUnlit = p.default.bUnlit;
	}

	DeusExRootWindow(Player.RootWindow).hud.augDisplay.activeCount --;
	DeusExRootWindow(Player.RootWindow).hud.augDisplay.bVisionActive = False;
	DeusExRootWindow(Player.RootWindow).HUD.AugDisplay.VisionLevel = 0;
	DeusExRootWindow(Player.RootWindow).HUD.AugDisplay.VisionLevelValue = 0;
	if(LocatorWindow(DeusExRootWindow(Player.RootWindow).actorDisplay) != None)
	{
		LocatorWindow(DeusExRootWindow(Player.RootWindow).actorDisplay).RemoveClass('ProxDisc');
		LocatorWindow(DeusExRootWindow(Player.RootWindow).actorDisplay).RemoveClass('RocketPod');
		LocatorWindow(DeusExRootWindow(Player.RootWindow).actorDisplay).RemoveClass('AutoTurret');
		LocatorWindow(DeusExRootWindow(Player.RootWindow).actorDisplay).RemoveClass('DeusExPlayer');
		LocatorWindow(DeusExRootWindow(Player.RootWindow).actorDisplay).RemoveClass('ScriptedPawn');
		LocatorWindow(DeusExRootWindow(Player.RootWindow).actorDisplay).RemoveClass('ThrownProjectile');
	}
	//Player.RelevantRadius = Player.Default.RelevantRadius;
}
/*
simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 7);
}

function Frob(Actor Frobber, Inventory frobWith)
{
    local Inventory l;
	if(DeusExPlayer(Frobber) != None && Level.NetMode != NM_StandAlone)
		l = Pawn(Frobber).FindInventoryType(class'lockpick');
	if(l != None)
		l.DropFrom(Frobber.Location);

		super.Frob(Frobber, FrobWith);
}*/
/*
simulated function makeWindow()
{
	
	if (DeusExPlayer(Owner) != None && !DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay.IsA('LocatorWindow'))
	{
		if (role == ROLE_Authority)
			Pawn(Owner).ClientMessage("Replacing old" @ DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay @ "with new locatorwindow serverside");
		else Pawn(Owner).ClientMessage("Replacing old" @ DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay @ "with new locatorwindow clientside");
		DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay = ActorDisplayWindow(DeusExRootWindow(DeusExPlayer(Owner).rootWindow).NewChild(Class'LocatorWindow'));
		DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
		
		
		
		if (Level.NetMode != NM_DedicatedServer)
		{
			LocatorWindow(DeusExRootWindow(DeusExPlayer(Owner).RootWindow).actorDisplay).AddClass('ProxDisc');
			LocatorWindow(DeusExRootWindow(DeusExPlayer(Owner).RootWindow).actorDisplay).AddClass('DeusExPlayer');
			LocatorWindow(DeusExRootWindow(DeusExPlayer(Owner).RootWindow).actorDisplay).AddClass('ScriptedPawn');
			LocatorWindow(DeusExRootWindow(DeusExPlayer(Owner).RootWindow).actorDisplay).AddClass('ThrownProjectile');
			LocatorWindow(DeusExRootWindow(DeusExPlayer(Owner).RootWindow).actorDisplay).AddClass('LocatorBeacon');
		}
	}
}*/


defaultproperties
{
     LoopSound=None
     ChargedIcon=Texture'DeusExUI.Icons.ChargedIconGoggles'
     ExpireMessage="UberGoggles power supply used up"
     ItemName="Uber Goggles"
     ItemArticle="a pair of"
     PlayerViewOffset=(X=20.000000,Z=-6.000000)
     PlayerViewMesh=LodMesh'DeusExItems.GogglesIR'
     PickupViewMesh=LodMesh'DeusExItems.GogglesIR'
     ThirdPersonMesh=LodMesh'DeusExItems.GogglesIR'
     Charge=8000
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconTechGoggles'
     largeIcon=Texture'DeusExUI.Icons.LargeIconTechGoggles'
     largeIconWidth=49
     largeIconHeight=36
     Description="The BowenCo \'Uber\' tech goggles provide an extended battery life and enhanced features compared with the basic tech goggles from Page Industries. \nThe goggles now also provide a passive ultrasonic detector facility to locate enemy proximity grenades."
     beltDescription="GOGGLES"
     Mesh=LodMesh'DeusExItems.GogglesIR'
     CollisionRadius=8.000000
     CollisionHeight=2.800000
     Mass=10.000000
     Buoyancy=5.000000
	 RespawnTime=40.00000
}
