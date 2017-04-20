//=============================================================================
// RPT. (c) 2003 JimBowen
//=============================================================================
class RPT expands BowenPickup;

var(Bowen) int NumRockets, MaxPods;
var int Health;
var bool bSecondHand;

replication
{
	reliable if (Role == ROLE_Authority)
		Health;
}

state Activated
{

	function Activate()
	{
	}
	simulated function BeginState()
	{
		local vector loc;
		local RocketPod RPT, aPod;
		local rotator rot;
		local int numPods;
			
			foreach allactors (class'RocketPod', aPod)
				if ((aPod != None) && aPod.Owner == Owner)
					numPods ++;
	
			if (NumPods >= MaxPods)
			{
				if (Role == ROLE_Authority)
					Pawn(Owner).ClientMessage("You may only place" @ MaxPods @ "RocketPods.");
				Return;
			}

			if (Pawn(Owner) != None)
			{
				loc = Owner.location;
				rot.yaw = Pawn(Owner).ViewRotation.Yaw;
				loc += Owner.collisionRadius*1.5*vector(Pawn(Owner).ViewRotation);
				RPT = Spawn (class'RocketPod', Owner,,Loc,rot);
				RPT.NumRockets = NumRockets;
				if(bSecondHand)
				{
					RPT.Health = Health;
					RPT.SetUp(False);
				}
				else
					RPT.SetUp(True);
					
				Super.BeginState();
				UseOnce();
			}
	}
	
}
//---END-CLASS---

defaultproperties
{
     MaxPods=4
     InventoryGroup=72
     bActivatable=True
     ItemName="Rocket Pod"
     RespawnTime=120.000000
     PlayerViewOffset=(Y=-10.000000,Z=-48.000000)
     PlayerViewMesh=LodMesh'DeusExItems.AssaultShotgun'
     PlayerViewScale=0.500000
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
     CollisionRadius=15.000000
     CollisionHeight=8.000000
     Mass=30.000000
}
