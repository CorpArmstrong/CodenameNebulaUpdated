//=============================================================================
// CGLaserPoint.
//=============================================================================
class CGLaserPoint expands Effects;

var CGLaserPoint NextPoint;
var bool bFirstPoint, bDone;

replication
{
	reliable if (Role == ROLE_Authority)
		NextPoint;
	unreliable if (Role == ROLE_Authority)
		bDone;
}
/*
simulated function PostNetBeginPlay()
{
//	log("PNBP:" @ NextPoint @ bNetOwner);
	if(bNetOwner || Role == ROLE_Authority)
		SetTimer(0.01, False);
	else
		SetTimer(1, False);
}
*/
simulated function tick(float deltatime)
{
	if (NextPoint != None && !bDone)
	{	
	//	log ("NextPoint is:" @ NextPoint);
		DrawBeam(Location, NextPoint.Location);
	}
}

simulated function SetNextPoint(CGLaserPoint Point)
{
	NextPoint = Point;
	bDone = False;
//	log("Called with point:" @ Point);
//	Log("NextPoint was set to:" @ NextPoint);
}

/*
simulated function Timer()
{
//	log("Timer:" @ NextPoint @ bNetOwner);
	if(NextPoint != None)
		DrawBeam(Location, NextPoint.Location);
}
*/
simulated function DrawBeam(vector A, vector B)
{
	local int i, NumBits;
	local vector line, increment, loc;	
	local float f, Dist;
	local CGBeamProxy BeamBit;

	if (Level.NetMode == NM_DedicatedServer)
		return;
	
		bDone = True;
	//	log("Drawing Beam:" @ B);
		line = A - B;
		Dist = VSize(line);
		f = Dist * 0.010000;
		NumBits = int(f);
		
		increment = line / NumBits;
		
		for( i=0; i<NumBits; i++ )
		{	
			loc = A - (increment * i);
			BeamBit = Spawn(class'CGBeamProxy',,, loc);
			BeamBit.RemoteRole = Role_None;
			BeamBit.SetRotation(Rotator(normal(A - B)));
			BeamBit.LifeSpan = 3.0 + 3*FRand();
		}
}

//---END-CLASS---

defaultproperties
{
     LifeSpan=10.000000
     NetPriority=3.000000
}
