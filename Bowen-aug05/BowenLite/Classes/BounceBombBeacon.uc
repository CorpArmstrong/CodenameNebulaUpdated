//=============================================================================
// BounceBomb.	(c) 2003 JimBowen
//=============================================================================
class BounceBombBeacon expands BounceBomb;

var bool bCanHitOwner, bSeeking, bHit;
var (Bowen) Texture ParTex, OnTex;
var int NumHits;
var (Bowen) int MaxBounces, NumGasClouds;
var (Bowen) float ActivateTime, mpActivateTime, mpDamage, GasDamage, HitTime;
var float ActivateTimer, HitTimer;

auto state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		Super(Rocket).Explode(HitLocation, HitNormal);
	}
	
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local LocatorBeacon loc;
		if (Other == Target && !bHit)
		{
			bHit = True;
			if (Role == ROLE_Authority)
				Pawn(Owner).ClientMessage("Drone attached to" @ GetDisplayName(Other));
			if (Role == ROLE_Authority)
			{
				loc = Spawn(class'LocatorBeacon',Owner,,Other.Location);
				loc.setBase(Other);
				Other.SmellClass = class'LocatorSmell';
			}
			SmokeGen.Destroy();
			Destroy();
		}
	}
}

function String GetDisplayName(Actor actor)
{
	if (DeusExPlayer(actor) != None)
		return DeusExPlayer(actor).PlayerReplicationInfo.PlayerName;
	
	if (ScriptedPawn(actor) != None)
		return ScriptedPawn(actor).UnfamiliarName;

	return "a target";
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Super(Rocket).Explode(HitLocation, HitNormal);
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode != NM_Standalone)
	{
		MaxBounces = 10;
		Damage = mpDamage;
		LifeSpan = 100;
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Level.NetMode != NM_Standalone)
	{
		MaxBounces = 10;
		LifeSpan = 100;
	}
}

simulated function Expired()
{
	Explode(Location, vect(0,0,1));
	Super.Expired();
}

//---END-CLASS---

defaultproperties
{

}
