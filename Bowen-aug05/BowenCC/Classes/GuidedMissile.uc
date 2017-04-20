//=============================================================================
// GuidedMissile. 	(c) 2003 JimBowen
//=============================================================================
class GuidedMissile expands Rocket;

var(Bowen) float SpriteWallOut, NearDistance;
var(Bowen) vector FireOffset;
var actor NewTarget;
var vector NewSpriteLocation, NewLocation;
var rotator NewRotation;
var BowenSpriteBeam SPR;

replication
{
	unreliable if (role == ROLE_Authority)
		NewSpriteLocation, NewLocation, NewRotation;
	reliable if (role == ROLE_Authority)
		SPR, NewTarget;
}

	simulated function UpdateLock()
	{	
		local vector TargetLocation, StartTrace, EndTrace, TraceNormal, Direction;
		local actor Other;
		
			if(pawn(Owner) != None)
			{
					StartTrace = Owner.Location + FireOffset;
					EndTrace = Owner.Location + FireOffset;
					EndTrace += vector(Pawn(Owner).ViewRotation)*MaxRange;
					Other = Trace(TargetLocation,TraceNormal,EndTrace,StartTrace,True);
					Direction = Normal (TargetLocation - Location);
					TargetLocation += (TraceNormal * SpriteWallOut);
					if (SPR != None)
						NewSpritelocation = TargetLocation;
					else
						SpawnSprite (TargetLocation);
					
					if(FastTrace(Location, TargetLocation))		
					{	
						if (Pawn(Other) != None)
							NewTarget = Other;
						else
							NewTarget = SPR;
					}
					else
						NewTarget = None;
						
					if (VSize(Location - TargetLocation) < NearDistance)
					{	
							Velocity = Speed * Direction;
							SetRotation(rotator(Direction)); //- too overkill at long ranges, no turning curve
							//log("rotation to set (laser) = " @ rotator(direction));
					}					
					
			}
	}


auto simulated state flying
{
	simulated function tick(float deltatime)
	{
		if(Role == ROLE_Authority || bNetOwner)		// dont do this on clients that didnt fire the rocket																
		{	
			UpdateLock();
			Target = NewTarget;
			NewLocation = Location;
			NewRotation = Rotation;
			SPR.SetLocation(NewSpriteLocation);
		}
		
		if(Role < ROLE_Authority && !bNetOwner)
		{
			Target = NewTarget;
			SetLocation(NewLocation);
			SetRotation(NewRotation);
			SmokeGen.SetLocation(NewLocation);
			FireGen.SetLocation(NewLocation);
			SPR.SetLocation(NewSpriteLocation);
		}
		Super.Tick(deltatime);
		
	}
	
	
	simulated function explode(vector hitlocation, vector hitnormal)
	{
		SPR.Destroy();
		Super.explode(HitLocation, HitNormal);
	}
}

function SpawnSprite(vector DrawLocation)
{
	SPR = Spawn(class'BowenSpriteBeam',,,DrawLocation);
	if (SPR != None)
	{
		SPR.Texture = Texture'DeusExItems.Skins.AlarmLightTex2';
		SPR.DrawScale = 1;
		SPR.LifeSpan = LifeSpan;
	}
}

//---END-CLASS---

defaultproperties
{
     SpriteWallOut=5.000000
     NearDistance=100.000000
     FireOffset=(Z=33.000000)
     mpBlastRadius=500.000000
     blastRadius=750.000000
     ItemName="Laser-Guided Anti-Pillbox missile"
     Damage=400.000000
     Mesh=LodMesh'DeusExItems.RocketLAW'
     DrawScale=1.250000
     bAlwaysRelevant=True
     NetPriority=3.000000
}
