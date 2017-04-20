//=============================================================================
// HunterDroneProj.	(c) 2003 JimBowen
//=============================================================================
class HunterDroneProj expands DeusExProjectile;

function PostBeginPlay()
{
	Spawn(class'HunterDrone',Owner,,Location,Rotation);
	Destroy();
}

//---END-CLASS---

defaultproperties
{
     bIgnoresNanoDefense=True
     ItemName="Locator Drone"
     speed=3000.000000
     MaxSpeed=6000.000000
     Damage=30.000000
     LifeSpan=0.000000
     Mesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
}
