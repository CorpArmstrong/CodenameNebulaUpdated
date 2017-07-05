//=============================================================================
// PlasmaBolt2.
//=============================================================================
class PlasmaBolt2 extends DeusExProjectile;

var ParticleGenerator pGen1;
var ParticleGenerator pGen2;

var float mpDamage;
var float mpBlastRadius;

#exec OBJ LOAD FILE=Effects

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local PlasmaRing ring;
	local ExplosionLight light;
   	local SphereEffect sphere;

	// draw a ring effect
	ring = Spawn(class'PlasmaRing',,,HitLocation, Rotator(HitNormal));
	if (ring != None)
	ring.RemoteRole = ROLE_None;

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
	if (light != None)
   	{
		light.RemoteRole = ROLE_None;
		light.size = 4;
		light.LightHue = 100;
		light.LightSaturation = 20;
		light.LightEffect = LE_Shell;
   	}

	// draw a cool light sphere
	sphere = Spawn(class'SphereEffect',,, HitLocation);
	if (sphere != None)
	sphere.RemoteRole = ROLE_None;
	sphere.size = blastRadius / 24.0;
	sphere.skin = Texture'Effects.liquid.Ambrosia_SFX';
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

   if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer))
      SpawnPlasmaEffects();
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	Damage = mpDamage;
	blastRadius = mpBlastRadius;
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
		pGen2.particleDrawScale = 0.1;
		pGen2.checkTime = 0.04;
		pGen2.riseRate = 0.0;
		pGen2.ejectSpeed = 100.0;
		pGen2.particleLifeSpan = 0.5;
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

defaultproperties
{
     mpDamage=20.000000
     mpBlastRadius=350.000000
     bExplodes=True
     blastRadius=192.000000
     DamageType=Burned
     AccurateRange=12400
     maxRange=20000
     bIgnoresNanoDefense=True
     ItemName="Plasma Bolt"
     ItemArticle="a"
     speed=1000.000000
     MaxSpeed=1000.000000
     Damage=60.000000
     MomentumTransfer=5000
     ImpactSound=Sound'DeusExSounds.Weapons.PlasmaRifleHit'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Mesh=LodMesh'DeusExItems.PlasmaBolt'
     DrawScale=4.000000
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=200
     LightHue=80
     LightSaturation=128
     LightRadius=3
     bFixedRotationDir=True
}