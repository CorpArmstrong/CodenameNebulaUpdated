//=============================================================================
// OsirisPlasmaBall.	(c) 2003 JimBowen
//=============================================================================
class OsirisPlasmaBall expands DeusExProjectile;

var ParticleGenerator pGen1;
var ParticleGenerator pGen2;
var (Bowen) int NumFrags;
var bool bDamageSpawner;

#exec OBJ LOAD FILE=Effects

function PostBeginPlay()
{
	Super.PostBeginPlay();

   if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer))
   {
      SpawnPlasmaEffects();
      SetTimer(((FRand()/5) + 0.1), True);
   }

	if (Level.NetMode == NM_StandAlone) // increased effect in singleplayer.
		BlastRadius *= 2;
	if (DeusExPlayer(Owner) != None && Level.NetMode == NM_StandAlone) // if we are cheating we may as well do it properly.
		if(DeusExPlayer(Owner).bAdmin)
			BlastRadius *= 2;
}

simulated function PostNetBeginPlay()
{
   if (Role < ROLE_Authority)
      SpawnPlasmaEffects();
}

// DEUS_EX AMSD Should not be called as server propagating to clients.
simulated function SpawnPlasmaEffects()
{
	local Rotator rot;
   rot = Rotation;
	rot.Yaw -= 32768;

   pGen2 = Spawn(class'ParticleGenerator', Self,, Location, rot);
	if (pGen2 != None)
	{
      pGen2.RemoteRole = ROLE_None;
		pGen2.particleTexture = Texture'Effects.Fire.Proj_PRifle';
		pGen2.particleDrawScale = 1;
		pGen2.checkTime = 0.01;
		pGen2.riseRate = 0.0;
		pGen2.ejectSpeed = 100.0;
		pGen2.particleLifeSpan = 0.8;
		pGen2.bRandomEject = True;
		pGen2.SetBase(Self);
	}
   
}

simulated function Destroyed()
{
	if (pGen1 != None)
		pGen1.DelayedDestroy();
	if (pGen2 != None)
		pGen2.DelayedDestroy();

	Super.Destroyed();
}


simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local BlastSphere Sph;
	local int i;
	local PlasmaSpark frag;
	
		Sph = Spawn(class'BlastSphere',,,Location);
		Sph.Size = 384;
		Sph.bAlwaysRelevant=True;
		Sph.Skin = Texture'DeusExDeco.Skins.EidoslogoTex1';
		Sph.LifeSpan = 5;

		for (i=0; i<NumFrags; i++)
		{
			frag = Spawn(class'PlasmaSpark',,,Location);
			frag.CalcVelocity(vect(0,0,0), 10000);
			frag.LifeSpan = (25 + FRand()*25);
		} 
}

simulated function Timer()
{
	local PlasmaSpark frag;
		frag = Spawn(class'PlasmaSpark',,,Location);
		frag.CalcVelocity(vect(0,0,0), 300);
		frag.LifeSpan = 30;
}
		
	
state Exploding
{
	ignores ProcessTouch, HitWall, Explode;

   function DamageRing()
   {
		local Pawn apawn;
		local float damageRadius;
		local Vector dist;

		if ( Level.NetMode != NM_Standalone )
		{
			damageRadius = (blastRadius / gradualHurtSteps) * gradualHurtCounter;

			for ( apawn = Level.PawnList; apawn != None; apawn = apawn.nextPawn )
			{
				if ( apawn.IsA('DeusExPlayer') )
				{
					dist = apawn.Location - Location;
					if ( VSize(dist) < damageRadius )
					{
						if ( gradualHurtCounter <= 2 )
						{
							if ( apawn.FastTrace( apawn.Location, Location ))
								DeusExPlayer(apawn).myProjKiller = Self;
						}
						else
							DeusExPlayer(apawn).myProjKiller = Self;
					}
				}
			}
		}
      //DEUS_EX AMSD Ignore Line of Sight on the lowest radius check, only in multiplayer
		HurtRadius
		(
			(2 * Damage) / gradualHurtSteps,
			((blastRadius / gradualHurtSteps) * gradualHurtCounter)/100,
			damageType,
			MomentumTransfer / gradualHurtSteps,
			Location,
         ((gradualHurtCounter <= 2) && (Level.NetMode != NM_Standalone))
		);
		
		HurtRadius
		(
			(0.1 * Damage) / gradualHurtSteps,
			((blastRadius / gradualHurtSteps) * gradualHurtCounter)*2,
			damageType,
			MomentumTransfer / gradualHurtSteps,
			Location,
         	True
		);
		
		if(bDamageSpawner)
			SpawnDamage();
   }

	function Timer()
	{
		gradualHurtCounter++;
      DamageRing();
		if (gradualHurtCounter >= gradualHurtSteps)
			Destroy();
	}

Begin:
	// stagger the HurtRadius outward using Timer()
	// do five separate blast rings increasing in size
	gradualHurtCounter = 1;
	gradualHurtSteps = 5;
	Velocity = vect(0,0,0);
	bHidden = True;
	LightType = LT_None;
	SetCollision(False, False, False);
    DamageRing();
	SetTimer(0.25/float(gradualHurtSteps), True);
}

simulated function SpawnDamage()
{
	local OsirisDamage Damage;
	
		Damage = Spawn(class'OsirisDamage',Owner,,Location + (Vect(0,0,100)));
		if(Damage != None)
		{
			Damage.LifeSpan = 20;
			Damage.BlastRadius = BlastRadius;
		}
}

//---END-CLASS---

defaultproperties
{
     NumFrags=30
     bExplodes=True
     blastRadius=200.000000
     bIgnoresNanoDefense=True
     speed=800.000000
     Skin=FireTexture'Effects.liquid.Virus_SFX'
     Mesh=LodMesh'DeusExItems.FireComet'
     DrawScale=20.000000
     bAlwaysRelevant=True
}
