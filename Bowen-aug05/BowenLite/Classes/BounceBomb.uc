//=============================================================================
// BounceBomb.	(c) 2003 JimBowen
//=============================================================================
class BounceBomb expands HomingMissile;

var bool bCanHitOwner, bSeeking, bHit;
var (Bowen) Texture ParTex, OnTex;
var int NumHits;
var (Bowen) int MaxBounces, NumGasClouds;
var (Bowen) float ActivateTime, mpDamage, GasDamage, HitTime;
var float ActivateTimer, HitTimer;

auto state Flying
{
	simulated function HitWall (Vector HitNormal, Actor Wall)
	{
		//if (!bHit && Level.NetMode == NM_StandAlone)
		//	Return;
		//bHit = False;
		//if (Level.NetMode != NM_StandAlone)
			Velocity -= 2 * (Velocity dot HitNormal) * HitNormal; 
		//else
		//	velocity = speed * VRand();
		if (Target != None)
			Velocity = Speed*normal(Target.Location - Location);
		// add randomness for singleplayer for beter map coverage
		if (Level.NetMode == NM_StandAlone)
			Velocity += (0.5*VSize(Velocity))*VRand();
		SetRotation (Rotator(Velocity));
		bCanHitOwner = True;
		NumHits ++;

		if (NumHits >= MaxBounces)
			Explode(Location, vect(0,0,1));
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		doWarhead(HitLocation);
		Super.Explode(HitLocation, HitNormal);
	}

/*	simulated function tick (float deltatime)
	{
		local float fangle;
		local vector vvect, dvect;
	
			ActivateTimer += DeltaTime;
			HitTimer += DeltaTime;
			
			if (owner == None)
			{
				log ("No owner on BounceBomb, aborting!");	
				Destroy();
				return;
			}
		
			if (HitTimer > HitTime)
			{
				bHit = True;
				HitTimer = 0;
			}
		
// 			if (!Owner.IsA('DeusExPlayer'))
// 				return;
			
			if (ActivateTimer >= ActivateTime)
			{
				bSeeking = True;
				bTracking = True;
				//ParTex = OnTex;
				//if (SmokeGen != None)
				//	smokeGen.DelayedDestroy();
				//if (Level.NetMode == NM_Client || Level.NetMode == NM_Standalone)
				//	SpawnRocketEffects();
				ActivateTimer = 0;
			}


			if (bSeeking)
				Super.Tick (DeltaTime);
	}
	*/
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (bStuck)
			return;

		if (Other.IsA('DeusExDecoration'))
		{
			HitWall (normal(Other.Location - Location), Other);
			return;
		}


		if ((Other != instigator || bCanHitOwner) && (DeusExProjectile(Other) == None) && (Other != Owner || bCanHitOwner))
		{
			damagee = Other;
			Explode(HitLocation, Normal(HitLocation-damagee.Location));
			doWarhead(HitLocation, Other);
			
			// DEUS_EX AMSD Spawn blood server side only
			if (Role == ROLE_Authority)
			{
				if (damagee.IsA('Pawn') && !damagee.IsA('Robot') && bBlood)
					SpawnBlood(HitLocation, Normal(HitLocation-damagee.Location));
			}
		}
	}

}

simulated function doWarhead (vector HitLocation, optional Actor Other)
{
	local Cloud P;
	local int i;
	
	for (i=0; i<NumGasClouds; i++)
	{
		P = Spawn(class'PoisonGas',Owner,,HitLocation + vRand() * BlastRadius); 
		if (P != None)
		{
			P.LifeSpan = 10;
			P.Texture = class'PoisonGas'.Default.Texture;
			if (Other != None)
				P.Velocity =  40*(Other.Location - P.Location);
			else
				P.Velocity =  40*(HitLocation - P.Location);
			P.DamageType='Exploded';
			P.ItemName = ItemName;
		}
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	doWarhead(HitLocation);
	Super.Explode(HitLocation, HitNormal);
}


simulated function SpawnRocketEffects()
{
	smokeGen = Spawn(class'ParticleGenerator', Self);
	if (smokeGen != None)
	{
      smokeGen.RemoteRole = ROLE_None;
		smokeGen.particleTexture = ParTex;
		smokeGen.particleDrawScale = 0.3;
		smokeGen.checkTime = 0.02;
		smokeGen.riseRate = 8.0;
		smokeGen.ejectSpeed = 0.0;
		smokeGen.particleLifeSpan = 0.3;
		smokeGen.bRandomEject = True;
		smokeGen.SetBase(Self);
		smokeGen.LifeSpan = LifeSpan;
	}
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
	ParTex=FireTexture'Effects.Smoke.SmokePuff1'
	OnTex=Texture'DeusExDeco.Skins.AlarmLightTex6'
	MaxBounces=10000
	ActivateTime=0.200000
	SearchRadius=3000
	AquireFOV=2.000000
	MaintainFOV=3.000000
	blastRadius=150.000000
	AccurateRange=800000
	maxRange=960000
	bTracking=True
	bIgnoresNanoDefense=True
	ItemName="BounceBomb hunter-seeker drone"
	speed=3000.000000
	MaxSpeed=6000.000000
	Damage=30.000000
	GasDamage=5
	NumGasClouds=20
	bSeeking=True
	mpDamage=20
	LifeSpan=0.000000
	Mesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
	bBounce=True
	HitTimer=0.1
}
