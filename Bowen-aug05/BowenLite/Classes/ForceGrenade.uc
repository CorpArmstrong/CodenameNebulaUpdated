//=============================================================================
// ForceGrenade. 	(c) 2003 JimBowen
//=============================================================================
class ForceGrenade expands DeusExprojectile;

var ParticleGenerator smokeGen;


auto simulated state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local actor a;
		local vector VelocityToSet;
		local float dist;
		
			foreach VisibleActors (class'Actor', a, BlastRadius)
			{
				if (a.IsA('DeusExPlayer') && TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
					if ((DeusExPlayer(a).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team) && a != Owner)
						return;

				dist = VSize(a.Location - HitLocation);
				VelocityToSet = (BlastRadius/Dist**1.1)*normal(a.Location - HitLocation)*5800;
				VelocityToset.z += 30;
				VelocityToSet += ((HitNormal * Blastradius) / dist**1.3) * 1300;
				if (a != None)
				{
					if (a.IsA('PlayerPawn'))
					{
						a.setPhysics(PHYS_Falling);
						a.Velocity += VelocityToSet;
					}
					else if (a.IsA('ScriptedPawn'))
					{
						a.SetPhysics(PHYS_Falling);
						ScriptedPawn(a).ImpartMomentum((VelocityToSet * 6000), Pawn(Owner));
						a.goToState('FallingState');
					}
					else if (a.isA('DeusExDecoration'))
					{
						if (DeusExDecoration(a).bPushable)
						{
							a.SetPhysics(PHYS_Falling);
							a.Velocity += (VelocityToSet * 80)/a.Mass;
						}
					}
					else if (a.IsA('Carcass'))
					{	a.SetPhysics(PHYS_Falling);
						a.Velocity += (VelocityToSet * 80)/a.Mass;
					}
				}
			}
		Super.Explode(HitLocation, HitNormal);
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

   if (Level.NetMode == NM_DedicatedServer)
      return;
   
   SpawnSmokeEffects();
}

simulated function PostNetBeginPlay()
{
   Super.PostNetBeginPlay();
   
   if (Role != ROLE_Authority)
      SpawnSmokeEffects();
}

simulated function SpawnSmokeEffects()
{
	smokeGen = Spawn(class'ParticleGenerator', Self);
	if (smokeGen != None)
	{
		smokeGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
		smokeGen.particleDrawScale = 0.3;
		smokeGen.checkTime = 0.02;
		smokeGen.riseRate = 8.0;
		smokeGen.ejectSpeed = 0.0;
		smokeGen.particleLifeSpan = 2.0;
		smokeGen.bRandomEject = True;
		smokeGen.SetBase(Self);
      smokeGen.RemoteRole = ROLE_None;
	}
}

simulated function Destroyed()
{
	if (smokeGen != None)
		smokeGen.DelayedDestroy();

	Super.Destroyed();
}


simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ShockRing ring;
	local ExplosionLight light;

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
   if (light != None)
      light.RemoteRole = ROLE_None;

	 ring = Spawn(class'ShockRing',,, HitLocation, rotator(HitNormal));
      if (ring != None)
      {
         ring.RemoteRole = ROLE_None;
         ring.size = blastRadius / 32.0;
      }
      
     ring = Spawn(class'ShockRing',,, HitLocation, rotator(HitNormal));
      if (ring != None)
      {
         ring.RemoteRole = ROLE_None;
         ring.size = blastRadius / 64.0;
      }
      
     ring = Spawn(class'ShockRing',,, HitLocation, rotator(HitNormal));
      if (ring != None)
      {
         ring.RemoteRole = ROLE_None;
         ring.size = blastRadius / 128.0;
      }
	 ring = Spawn(class'ShockRing',,, HitLocation, rotator(HitNormal));
      if (ring != None)
      {
         ring.RemoteRole = ROLE_None;
         ring.size = blastRadius / 256.0;
      }
}

//---END-CLASS---

defaultproperties
{
     bExplodes=True
     bBlood=True
     bDebris=True
     blastRadius=512.000000
     DamageType=exploded
     AccurateRange=400
     maxRange=800
     ItemName="Force Grenade"
     ItemArticle="a"
     speed=1000.000000
     MaxSpeed=1000.000000
     Damage=20.000000
     MomentumTransfer=40000
     SpawnSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     ImpactSound=Sound'DeusExSounds.Generic.MediumExplosion2'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Mesh=LodMesh'DeusExItems.HECannister20mm'
}
