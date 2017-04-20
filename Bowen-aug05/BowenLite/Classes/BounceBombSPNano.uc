//=============================================================================
// BounceBomb.	(c) 2003 JimBowen
//=============================================================================
class BounceBomb expands HomingMissile;

var bool bCanHitOwner, bSeeking, bHit;
var (Bowen) Texture ParTex, OnTex;
var int NumHits;
var (Bowen) int MaxBounces, NumGasClouds;
var (Bowen) float ActivateTime, mpActivateTime, mpDamage, GasDamage, HitTime;
var float ActivateTimer, HitTimer;

static final function vector CalcIntercept (vector GunLocation, vector TargetLocation, vector TargetVelocity, float UseProjectileSpeed, optional float MaxRange, optional bool bDebug)
{

	local vector z, v, IntDirA, IntdirB, IntDir;
	local float kA, kB, a, b, c;

		if (bDebug)
			log ("Calculation started.");
			Z = TargetLocation - GunLocation;
		if (bDebug)
			log("Z =" @ Z);

		V = TargetVelocity;

		if (bDebug)
			log("V =" @ V);
			a = Z dot Z;	//)/(ProjectileSpeed ** 2);

		if (bDebug)
			log("a =" @ a);
			b = 2*(V dot Z); //)/ProjectileSpeed;

		if (bDebug)
			log("b =" @ b);


		c = (V dot V)-(UseProjectileSpeed ** 2); ///(ProjectileSpeed) - 1;
		if (bDebug)
			log("c =" @ c);

		kA = (-b + ((b**2 - 4*a*c) ** 0.5)) / (2*a);
		if (bDebug)
			log("kA =" @ kA);

		IntDirA = (kA*Z + V)/UseProjectileSpeed;
	
		if (bDebug)
			log("IntDirA =" @ IntDirA);

		kB = (-b - ((b**2 - 4*a*c) ** 0.5)) / (2*a);
		if (bDebug)
			log("kB =" @ kB);

		IntDirB = (kB*Z + V)/UseProjectileSpeed;
	
		if (bDebug)
			log("IntDirB =" @ IntDirB);

		if (bDebug)
			log ("Calculation finished.");

		//if (VSize((IntDirA+GunLocation) - (TargetVelocity+TargetLocation)) < VSize((IntDirB+GunLocation) - (TargetVelocity+TargetLocation)))	
			IntDir = IntDirA;
		//else
		//	IntDir = IntDirB;

		if((VSize(IntDir) == 0) || (VSize(IntDir) > 3*MaxRange && MaxRange != 0))
			return (normal(-Z));
		else
			return (normal(IntDir));

}

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
		SetRotation (Rotator(Velocity));
		bCanHitOwner = True;
		NumHits ++;

		if (NumHits >= MaxBounces)
			Explode(Location, vect(0,0,1));
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		SpawnGas(HitLocation);
		Super.Explode(HitLocation, HitNormal);
	}

	simulated function tick (float deltatime)
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
		
			/*if (!Owner.IsA('DeusExPlayer'))
				return;*/
			
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
			
			if (Level.NetMode != NM_Standalone)
				ActivateTime = mpActivateTime;	


			if (bSeeking)
				Super.Tick (DeltaTime);	
	}
	
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
			SpawnGas(HitLocation, Other);
			
			// DEUS_EX AMSD Spawn blood server side only
			if (Role == ROLE_Authority)
			{
				if (damagee.IsA('Pawn') && !damagee.IsA('Robot') && bBlood)
					SpawnBlood(HitLocation, Normal(HitLocation-damagee.Location));
			}
		}
	}


}

simulated function SpawnGas (vector HitLocation, optional Actor Other)
{
	local Cloud P;
	local int i;
	
	for (i=0; i<NumGasClouds; i++)
	{
		if (Level.NetMode == NM_StandAlone)
		{
			P = Spawn(class'PoisonGas',Owner,,HitLocation + vRand() * BlastRadius); 
			if (P != None)
			{
				P.LifeSpan = 10;
				P.Texture = class'PoisonGas'.Default.Texture;
				if (Other != None)
					P.Velocity =  20*(Other.Location - P.Location);
				else
					P.Velocity =  20*(HitLocation - P.Location);
				P.Damage=GasDamage;
				if (Level.NetMode == NM_StandAlone)
					P.DamageType='Exploded';
				P.ItemName = ItemName;
			}
		}
		else if (Other != None)
		//	P = Spawn(class'TearGas',Owner,,HitLocation + vRand() * BlastRadius); 
			Other.TakeDamage(10, DeusExPlayer(Owner), HitLocation, vect(0,0,0), 'Poisoned');
		Else
			Spawn(class'TearGas',,,HitLocation);
	}
}

simulated function tick (float deltatime)
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

/*		if (!Owner.IsA('DeusExPlayer'))
			return;*/
		
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

		if (Level.NetMode != NM_Standalone)
			ActivateTime = mpActivateTime;	


		if (bSeeking)
			Super.Tick (DeltaTime);	
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	SpawnGas(HitLocation);
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
		MaxBounces = 4;
		Damage = mpDamage;
		LifeSpan = 10;
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Level.NetMode != NM_Standalone)
	{
		MaxBounces = 4;
		LifeSpan = 10;
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
     mpActivateTime=0.400000
     SearchRadius=3000
     AquireFOV=2.000000
     MaintainFOV=3.000000
     blastRadius=150.000000
     AccurateRange=800000
     maxRange=960000
     bTracking=False
     bIgnoresNanoDefense=True
     ItemName="BounceBomb hunter-seeker drone"
     speed=3000.000000
     MaxSpeed=6000.000000
     Damage=30.000000
     GasDamage=5
     NumGasClouds=10
     mpDamage=20
     LifeSpan=0.000000
     Mesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
     bBounce=True
     HitTimer=0.1
}
