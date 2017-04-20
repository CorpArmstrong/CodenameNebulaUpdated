//=============================================================================
// VortexGrenade.
//=============================================================================
class VortexGrenade extends ThrownProjectile;
var float	mpBlastRadius;
var float	mpProxRadius;
var float	mpLAMDamage;
var float	mpFuselength;
var(Bowen) float SpawnPointCheckRadius;
var bool bDoneMsg;

simulated function Tick(float deltaTime)
{
	local float blinkRate;

	Super.Tick(deltaTime);

	if (bDisabled)
	{
		Skin = Texture'BlackMaskTex';
		return;
	}

	// flash faster as the time expires
	if (fuseLength - time <= 0.75)
		blinkRate = 0.1;
	else if (fuseLength - time <= fuseLength * 0.5)
		blinkRate = 0.3;
	else
		blinkRate = 0.5;

   if ((Level.NetMode == NM_Standalone) || (Role < ROLE_Authority) || (Level.NetMode == NM_ListenServer))
   {
      if (Abs((fuseLength - time)) % blinkRate > blinkRate * 0.5)
         Skin = Texture'BlackMaskTex';
      else
         Skin = Texture'LAM3rdTex1';
   }
}

simulated function SpawnSmoke()
{
	local ParticleGenerator gen;
	
				gen = Spawn(class'ParticleGenerator', Self,, Location, rot(16384,0,0));
				if (gen != None)
				{
					gen.checkTime = 0.25;
					gen.LifeSpan = 2;
					gen.particleDrawScale = 0.3;
					gen.bRandomEject = True;
					gen.ejectSpeed = 10.0;
					gen.bGravity = False;
					gen.bParticlesUnlit = True;
					gen.frequency = 0.5;
					gen.riseRate = 10.0;
					gen.spawnSound = Sound'Spark2';
					gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
					gen.SetBase(Self);
				}
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
	{
		blastRadius=mpBlastRadius;
		proxRadius=mpProxRadius;
		Damage=mpLAMDamage;
		fuseLength=mpFuselength;
		bIgnoresNanoDefense=True;
	}
}

auto simulated state Flying
{
	function Explode(vector HitLocation, vector HitNormal)
	{
		local ShockRing ring;
		local DeusExPlayer player;
		local float dist;

			if (ROLE == ROLE_Authority)
			{
				Spawn(Class'Vortex',Owner,,Location + vect(0,0,100));
				ClientFlashes();
			}

			if ( AISoundLevel > 0.0 )
				AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, AISoundLevel*blastRadius*16);

			Destroy();
	}
}

function ClientFlashes()
{
	local DeusExPlayer P;
		
		foreach AllActors (class'DeusExPlayer', P)
			P.ClientFlash(500, vect(100,1000,10000));
}


simulated function PostBeginPlay()
{

	local PlayerStart Spawn;
	local SpawnExtension SpawnExt;
	
		if (Level.NetMode == NM_Standalone)
		{
			Super.PostBeginPlay();
			return;
		}
			
		foreach RadiusActors (class 'PlayerStart', Spawn, SpawnPointCheckRadius)
		{
			if (FastTrace(Spawn.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
			{
				if (Owner.IsA('DeusExPlayer'))
				{
					DeusExPlayer(Owner).ClientMessage("Vortex Grenades are not allowed in spawn rooms");
					log("VortexGrenade placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
				}
				else log ("VortexGrenade was found in spawn room with no player owner");
				SpawnSmoke();
				bDoneMsg = True;
				Destroy();
				return;
			}
		}
		
		foreach RadiusActors (class 'SpawnExtension', SpawnExt, SpawnPointCheckRadius)
		{
			if (FastTrace(Spawn.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
			{
				if (Owner.IsA('DeusExPlayer'))
				{
					DeusExPlayer(Owner).ClientMessage("Vortex Grenades are not allowed in spawn rooms");
					log("VortexGrenade placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
				}
				else log ("VortexGrenade was found in spawn room with no player owner");
				SpawnSmoke();
				bDoneMsg = True;
				Destroy();
				return;
			}
		}

}


//---END-CLASS---

defaultproperties
{
     mpProxRadius=128.000000
     mpLAMDamage=500.000000
     mpFuselength=2.000000
     SpawnPointCheckRadius=300.000000
     proxRadius=128.000000
     blastRadius=0.000000
     spawnWeaponClass=Class'WVG'
     ItemName="Vortex Grenade"
     speed=1000.000000
     MaxSpeed=1000.000000
     Damage=500.000000
     MomentumTransfer=50000
     ExplosionDecal=Class'DeusEx.ScorchMark'
     LifeSpan=0.000000
     Texture=FireTexture'Effects.Electricity.Nano_SFX_A'
     Mesh=LodMesh'JBVortexGrenade'
     DrawScale=0.100000
     bAlwaysRelevant=True
     CollisionRadius=4.300000
     CollisionHeight=3.800000
     Mass=5.000000
     Buoyancy=2.000000
}
