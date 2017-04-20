//======================================================
// LocatorBeacon -- Idea contributed by Batch_File
//======================================================

class LocatorBeacon extends BowenBasicActor2;

var vector ServerPosition;
var String info;
/*
enum EIFF
{
	IFF_Hostile,
	IFF_Friendly,
	IFF_Neutral,
	IFF_None,
};*/

Replication
{
	unreliable if (Role == ROLE_Authority)
		ServerPosition, info;
}

simulated function string PrintDetails()
{
	return info;
}

function String makeDetails()
{
	local string out;
	local bool bHaveLOS;
	local int iff;
	
	if (Base == None || DeusExPlayer(Owner) == None)
	{
		if (Lifespan == Default.Lifespan && Role == ROLE_Authority)
			Lifespan = 1;
		return "Error! Unattached beacon!";
	}
		
	if (Base == Level || Base.IsA('DeusExMover'))
	{
		if (Lifespan == Default.Lifespan)
			Lifespan = 1;
		return "Missed..";
	}
	
	bHaveLOS = FastTrace(Owner.Location, ServerPosition);
	iff = class'LocatorWindow'.Static.DoIff(Base, DeusExPlayer(Owner));
	
	switch IFF
	{
		case 1:
			if(bHaveLOS) out = "|c00FF00"; //colr(0,255,0);
			else out = "|c20D020"; //colr(64,255,64);
			break;
		case 0:
			if(bHaveLOS) out = "|cFF0000"; // colr(255,0,0);
			else out = "|cD02020"; // colr(255,64,64);
			break;
		case 2:
			if(bHaveLOS) out = "|cFFFFFF"; // colr(255,255,255);
			else out = "|cD0D0D0"; // colr(64,64,64);
			break;
		case 3:
			out = "|c000000"; // colr(0,0,0);
			break;
	}	
	
	out = out $ class'LocatorWindow'.Static.GetDisplayName(Base);
	
	return out;
}

simulated function tick (float DeltaTime)
{
	UpdateLocatorDisplay(DeusExPlayer(Owner));
	
	if (Base != None && Base.isInState('dying'))
		Destroy();
	if (Base == None && Lifespan == Default.Lifespan)
		LifeSpan=1;
		
	if (Role == ROLE_Authority)
	{
		ServerPosition = Location;
		info = makeDetails();
	}
}
		
simulated function PostBeginPlay()
{
	local LocatorBeacon b;
	foreach allactors (class'LocatorBeacon', b)
		if (b.base == base && b != self)
			b.destroy();
	if(Base != None)
		Base.SmellClass=class'LocatorSmell';
	if(Role != ROLE_Authority)
		SetBase(Owner);
}

simulated function Destroyed()
{
	if (Base != None)
		Base.SmellClass = Base.Default.SmellClass;
}

static simulated function UpdateLocatorDisplay(DeusExPlayer p)
{
	local UberGoggles u;
	
	if (p != None && !DeusExRootWindow(p.RootWindow).actorDisplay.IsA('LocatorWindow'))
	{
		DeusExRootWindow(p.RootWindow).actorDisplay = ActorDisplayWindow(DeusExRootWindow(p.RootWindow).NewChild(Class'LocatorWindow'));
		DeusExRootWindow(p.RootWindow).actorDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
		u = UberGoggles(p.FindInventoryType(class'UberGoggles'));
		LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay).AddClass('LocatorBeacon');
		if (u != None && u.bActive)
		{
			LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay).AddClass('ProxDisc');
			LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay).AddClass('RocketPod');
			LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay).AddClass('AutoTurret');
			LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay).AddClass('DeusExPlayer');
			LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay).AddClass('ScriptedPawn');
			LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay).AddClass('ThrownProjectile');
		}
	}
	else if (LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay) != None)
		LocatorWindow(DeusExRootWindow(p.RootWindow).actorDisplay).AddClass('LocatorBeacon');
}

DefaultProperties
{
	bAlwaysRelevant=True
	DrawType=DT_None
}