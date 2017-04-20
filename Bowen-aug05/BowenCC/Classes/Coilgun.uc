//=============================================================================
// Coilgun.
//=============================================================================
class Coilgun expands BowenWeapon;

var(Bowen) float BlastRadius, MaxTotalRange;
var(Bowen) int NumReflections, mpNumReflections;
var CGLaserPoint LaserPoints[16];

replication
{
	unreliable if (Role == ROLE_Authority)
		LaserPoints;
}

/*
simulated function Tick(float DeltaTime)
{
	local int i;
	local CGLaserPoint LastPoint;
	
		if (Role != ROLE_Authority && !bNetOwner && Owner != None)
		{
		//	log("Checking Array");
			if (LaserPoints[7] != None)
			{
				log ("Found first point");
				for (i=7; i>=0; i--)
				{
					log("Checking point number" @ i);
					if (LaserPoints[i] != None)
					{
						if (i == NumReflections)
							LastPoint = LaserPoints[i];
						else if (LastPoint != None)
							LaserPoints[i].SetNextPoint(LastPoint);
						log(i $ ":" @ LaserPoints[i] $ "," @ LastPoint);
						LaserPoints[i] = None;
					}
				}
			}
		}
	
		Super.Tick(DeltaTime);
}*/

simulated function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z, vIn, vOut;
	local Rotator rot;
	local actor Other;
	local float dist, alpha, degrade;
	local int i, numSlugs;
	local float volume, radius, TotalRange, TempTotalRange;
	local CGLaserPoint Point, FirstPoint, LastPoint;

		// make noise if we are not silenced
		if (!bHasSilencer && !bHandToHand)
		{
			GetAIVolume(volume, radius);
			Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius);
			Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius);
			if (!Owner.IsA('PlayerPawn'))
				Owner.AISendEvent('Distress', EAITYPE_Audio, volume, radius);
		}
	
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		StartTrace = ComputeProjectileStart(X, Y, Z);
		AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	
		// check to see if we are a shotgun-type weapon


		if (AreaOfEffect == AOE_Cone)
			numSlugs = 5;
		else

			numSlugs = 1;
	
		// if there is a scope, but the player isn't using it, decrease the accuracy
		// so there is an advantage to using the scope
		if (bHasScope && !bZoomed)
			Accuracy += 0.2;
		// if the laser sight is on, make this shot dead on
		// also, if the scope is on, zero the accuracy so the shake makes the shot inaccurate
		else if (bLasing || bZoomed)
			Accuracy = 0.0;
	
	

		for (i=0; i<numSlugs; i++)
		{
	      // If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
	      if ((i > 0) && (Level.NetMode != NM_Standalone) && !(bHandToHand))
	         if (Accuracy < MinSpreadAcc)

	            Accuracy = MinSpreadAcc;


	
	      // Let handtohand weapons have a better swing
	      if ((bHandToHand) && (NumSlugs > 1) && (Level.NetMode != NM_Standalone))
	      {
	         StartTrace = ComputeProjectileStart(X,Y,Z);
	         StartTrace = StartTrace + (numSlugs/2 - i) * SwingOffset;
	      }
	
	      EndTrace = StartTrace + Accuracy * (FRand()-0.5)*Y*1000 + Accuracy * (FRand()-0.5)*Z*1000 ;
	      EndTrace += (FMax(1024.0, MaxRange) * vector(AdjustedAim));
	      
	      Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	
			// randomly draw a tracer for relevant ammo types
			// don't draw tracers if we're zoomed in with a scope - looks stupid
	      // DEUS_EX AMSD In multiplayer, draw tracers all the time.
			if ( ((Level.NetMode == NM_Standalone) && (!bZoomed && (numSlugs == 1) && (FRand() < 0.5))) ||
	           ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority) && (numSlugs == 1)) )
			{
				if ((AmmoName == Class'Ammo10mm') || (AmmoName == Class'Ammo3006') ||
					(AmmoName == Class'Ammo762mm'))
				{
					if (VSize(HitLocation - StartTrace) > 250)
					{
						rot = Rotator(EndTrace - StartTrace);
	               if ((Level.NetMode != NM_Standalone) && (Self.IsA('WeaponRifle')))
	                  Spawn(class'SniperTracer',,, StartTrace + 96 * Vector(rot), rot);
	               else
	                  Spawn(class'Tracer',,, StartTrace + 96 * Vector(rot), rot);

					}
				}
			}
	
			// check our range
			dist = Abs(VSize(HitLocation - Owner.Location));
	
			if (dist <= AccurateRange)		// we hit just fine
				ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
			else if (dist <= MaxRange)
			{
				// simulate gravity by lowering the bullet's hit point
				// based on the owner's distance from the ground
				alpha = (dist - AccurateRange) / (MaxRange - AccurateRange);
				degrade = 0.5 * Square(alpha);
				HitLocation.Z += degrade * (Owner.Location.Z - Owner.CollisionHeight);
				ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
			}
		}
	
		// otherwise we don't hit the target at all
		
		/*-----------------------------
		--- now for the clever part ---
		-----------------------------*/
		
		if (Other == None)
			HitLocation = EndTrace;
		
		// draw the first beam:
		if (level.NetMode != NM_DedicatedServer)
		{
		//	DrawBeam(StartTrace, HitLocation);
			Point = Spawn(class'CGLaserPoint',,,HitLocation);
			FirstPoint = Spawn(class'CGLaserPoint',,,StartTrace);
			if (FirstPoint != None && Point != None)
			{
				LastPoint = Point;
				FirstPoint.bFirstPoint = True;
				FirstPoint.SetNextPoint(Point);
				LaserPoints[15] = FirstPoint;
				LaserPoints[14] = Point;
				if(bNetOwner)
					FirstPoint.DrawBeam(FirstPoint.Location, Point.Location);
			}
			DrawSprites (StartTrace, HitLocation);
			SpawnParticles(HitLocation);
			TotalRange += VSize(StartTrace - HitLocation);

		}
		
		if (Other == None)
			return;
		
		// calculate all the reflected hit locations:
		
		for (i=0; i<NumReflections; i++)
		{		
			vIn = normal (HitLocation - StartTrace);
			vOut = normal (vIn - 2 * (vIn dot HitNormal) * HitNormal);
			StartTrace = HitLocation;
			EndTrace = StartTrace + (MaxRange * vOut);
			Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
			if (Other == None)
			{
				HitLocation = EndTrace;
			}
			TempTotalRange = TotalRange;
			TempTotalRange += VSize(StartTrace - HitLocation);
			if (TempTotalRange > MaxTotalRange)
				HitLocation = StartTrace + ((MaxTotalRange - TotalRange) * normal(StartTrace - EndTrace));
			TotalRange += VSize(StartTrace - HitLocation);
			ProcessTraceHit (Other, HitLocation, HitNormal, vOut, Y, Z);
			//if (level.NetMode != NM_DedicatedServer)
			//DrawBeam (StartTrace, HitLocation);
			if (i < 3)
				DrawSprites(StartTrace, HitLocation);
			Point = Spawn(class'CGLaserPoint',,,HitLocation);
			if (Point != None)
			{
				if (LastPoint != None)
					LastPoint.SetNextPoint(Point);
				LaserPoints[(29-i)] = Point;
				if(bNetOwner && LastPoint != None)
					LastPoint.DrawBeam (LastPoint.Location, Point.Location);
				LastPoint = Point;
			}
			SpawnParticles(HitLocation);
			//log("TotalRange:" @ TotalRange);
			if (Other == None || TotalRange >= MaxTotalRange)
				break;
		}	
		if(bNetOwner && LastPoint != None)
			LastPoint.DrawBeam (LastPoint.Location, Point.Location);
}


/*
simulated function DrawBeam(vector A, vector B)
{
	local int i, NumBits;
	local vector line, increment, loc;	
	local float f, Dist;
	local CGBeamProxy BeamBit;
	
		line = A - B;
		
		Dist = VSize(line);
		f = Dist * 0.010000;
		NumBits = int(f);
		
		increment = line / NumBits;
		
		for( i=0; i<NumBits; i++ )
		{	
			loc = A - (increment * i);
			BeamBit = Spawn(class'CGBeamProxy',,, loc);
			if (bNetOwner)
				BeamBit.RemoteRole = Role_None;
			else




				BeamBit.RemoteRole = ROLE_SimulatedProxy;

			BeamBit.SetRotation(Rotator(normal(A - B)));
			BeamBit.LifeSpan = 3.0 + 3*FRand();
		}
}*/

simulated function DrawSprites(vector A, vector B)
{
local int i, NumSprites;
local vector line, increment, loc;	
local float f, Dist;
local BowenSpriteBeam BeamSprite;

	if (!(Role == ROLE_Authority || bNetOwner))
		return;
	
	line = A - B;
	
	Dist = VSize(line);
	f = Dist * 0.010000;
	NumSprites = int(f);

	
	increment = line / NumSprites;
	
	for( i=0; i<NumSprites; i++ )
	{	
		loc = A - (increment * i);
		BeamSprite = Spawn(class'BowenSpriteBeam',,, loc);
	//	BeamSprite.RemoteRole = Role_SimulatedProxy;
		BeamSprite.LifeSpan = 1.0 + FRand();
		BeamSprite.Texture = Texture'DeusExItems.Skins.AlarmLightTex2';
		BeamSprite.bFade = True;
	}
}


simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector loc;
	local ExplosionSmall S;
	local shockring ring;
	
	if (HitLocation == vect(0,0,0))
	{
		super.ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);
		return;
	}
		
/*	if (VSize(Owner.Location - HitLocation) <= MaxRange)
	{	
		Spawn (class'DeusEx.ExplosionSmall',,,HitLocation);
	}
	
	  ring = Spawn(class'ShockRing',,, HitLocation, rot(16384,0,0));
      if (ring != None)
      {
         ring.size = blastRadius / 32.0;
      }
      ring = Spawn(class'ShockRing',,, HitLocation, rot(0,0,0));
      if (ring != None)
      {
         ring.size = blastRadius / 32.0;
      }
      ring = Spawn(class'ShockRing',,, HitLocation, rot(0,16384,0));
      if (ring != None)
      {


         ring.size = blastRadius / 32.0;
      }*/
         
	if (Other != None)
		Other.TakeDamage(HitDamage, Pawn(Owner), Other.Location, vect(0,0,0), 'EMP');
	
	if(Pawn(Other) != None && Pawn(Other).FindInventoryType(class'ShieldGenerator') != None)
		Pawn(Other).FindInventoryType(class'ShieldGenerator').TakeDamage(HitDamage, Pawn(Owner), Other.Location, vect(0,0,0), 'EMP');
	
      DrawExplosionEffects (HitLocation, HitNormal);

			
	Super.ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);
		
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ParticleGenerator gen;



	// create a particle generator shooting out plasma spheres
	gen = Spawn(class'ParticleGenerator',,, HitLocation, Rotator(HitNormal));
	if (gen != None)
	{
      gen.RemoteRole = ROLE_None;
		gen.particleDrawScale = 1.0;
		gen.checkTime = 0.10;
		gen.frequency = 1.0;
		gen.ejectSpeed = 200.0;
		gen.bGravity = True;

		gen.bRandomEject = True;
		gen.particleLifeSpan = 0.75;
		gen.particleTexture = Texture'Effects.Laser.LaserSpot1';
		gen.LifeSpan = 1.3;
	}
}

simulated function SpawnParticles(vector HitLocation)
{
	local PlasmaSpark Spark;
	local int i, n;
	
		n = Rand(4);
		
		for (i=0; i<n; i++)
		{
			Spark = spawn(class'PlasmaSpark',,,HitLocation);
			if (Spark != None)
			{
				Spark.CalcVelocity(vect(0,0,0), 300);
				Spark.LifeSpan = 5 + 5*FRand();
				Spark.DrawScale *= FRand();
				Spark.Texture = Texture'BowenCust.Effects.HotGlow';
			}
		}
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		HitDamage = mpHitDamage;
		BaseAccuracy = mpBaseAccuracy;
		ReloadTime = mpReloadTime;
		AccurateRange = mpAccurateRange;
		MaxRange = mpMaxRange;
		ReloadCount = mpReloadCount;
   		bHasMuzzleFlash = False;
		NumReflections = mpNumReflections;
	}
}

//---END-CLASS---

defaultproperties
{
     blastRadius=30.000000
     MaxTotalRange=100000.000000
     NumReflections=16
     mpNumReflections=4
     LowAmmoWaterMark=6
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=1.500000
     reloadTime=2.000000
     HitDamage=75
     maxRange=500000
     AccurateRange=28800
     bCanHaveScope=True
     bHasScope=True
     bCanHaveLaser=True
     bCanHaveSilencer=True
     bHasSilencer=True
     bHasMuzzleFlash=False
     recoilStrength=0.400000
     bUseWhileCrouched=False
     mpReloadTime=2.000000
     mpHitDamage=30
     mpAccurateRange=28800
     mpMaxRange=28800
     mpReloadCount=6
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'BowenCC.AmmoCoilgun'
     ReloadCount=6
     PickupAmmoCount=6
     bInstantHit=True
     FireOffset=(X=-20.000000,Y=2.000000,Z=30.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.RifleFire'
     AltFireSound=Sound'DeusExSounds.Weapons.RifleReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.RifleReload'
     SelectSound=Sound'DeusExSounds.Weapons.RifleSelect'
     InventoryGroup=101
     ItemName="Coilgun"
     PlayerViewOffset=(X=20.000000,Y=-2.000000,Z=-30.000000)
     PlayerViewMesh=LodMesh'DeusExItems.SniperRifle'
     PickupViewMesh=LodMesh'DeusExItems.SniperRiflePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.SniperRifle3rd'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconRifle'
     largeIcon=Texture'DeusExUI.Icons.LargeIconRifle'
     largeIconWidth=159
     largeIconHeight=47
     invSlotsX=4
     Description="The BowenCo coilgun contains an array of high power electromagnets to acellerate a 5mm wide, iron slug to around a hundred times the speed of sound. the projectile spins extremely fast and will ricochet at any angle on a hard surface. Due to the extreme magnetism in the barrel of the weapon, the iron slugs are magnetised upon firing, causing an electromagnetic pulse effect in any circuitry they fly past at their extreme speeds."
     beltDescription="COILGUN"
     Mesh=LodMesh'DeusExItems.SniperRiflePickup'
     CollisionRadius=26.000000
     CollisionHeight=2.000000
     Mass=30.000000
     NetPriority=3.000000
}
