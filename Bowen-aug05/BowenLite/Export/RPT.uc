//================================================================================
// RPT.
//================================================================================
class RPT extends BowenPickup;

var(bowen) int NumRockets;
var(bowen) int MaxPods;
var int Health;
var bool bSecondHand;

replication
{
	un?reliable if ( Role == 4 )
		Health;
}

state Activated extends Activated
{
	function Activate ()
	{
	}
	
	simulated function BeginState ()
	{
		local Vector Loc;
		local RocketPod RPT;
		local RocketPod aPod;
		local Rotator Rot;
		local int numPods;
	
		foreach AllActors(Class'RocketPod',aPod)
		{
			if ( (aPod != None) && (aPod.Owner == Owner) )
			{
				numPods++;
			}
			continue;
		}
		if ( numPods >= MaxPods )
		{
			if ( Role == 4 )
			{
				Pawn(Owner).ClientMessage("You may only place" @ string(MaxPods) @ "RocketPods.");
			}
			return;
		}
		if ( Pawn(Owner) != None )
		{
			Loc=Owner.Location;
			Rot.Yaw=Pawn(Owner).ViewRotation.Yaw;
			Loc += Owner.CollisionRadius * 1.50 * vector(Pawn(Owner).ViewRotation);
			RPT=Spawn(Class'RocketPod',Owner,,Loc,Rot);
			RPT.NumRockets=NumRockets;
			if ( bSecondHand )
			{
				RPT.Health=Health;
				RPT.Setup(False);
			}
			else
			{
				RPT.Setup(True);
			}
			Super.BeginState();
			UseOnce();
		}
	}
	
}

defaultproperties
{
    MaxPods=4
    InventoryGroup=72
    bActivatable=True
    ItemName="Rocket Pod"
    RespawnTime=120.00
    PlayerViewOffset=(X=0.00, Y=-10.00, Z=-48.00)
    PlayerViewMesh=LodMesh'DeusExItems.AssaultShotgun'
    PlayerViewScale=0.50
    PickupViewMesh=LodMesh'DeusExItems.AssaultShotgunPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.AssaultShotgun3rd'
    LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
    Icon=Texture'DeusExUI.Icons.BeltIconAssaultShotgun'
    largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultShotgun'
    largeIconWidth=99
    largeIconHeight=55
    invSlotsX=2
    invSlotsY=2
    Description="The BowenCo Automated Rocket Pod will guard a location and fire rockets at enemy targets."
    beltDescription="ARP"
    Mesh=LodMesh'DeusExItems.AssaultShotgunPickup'
    CollisionRadius=15.00
    CollisionHeight=8.00
    Mass=30.00
}