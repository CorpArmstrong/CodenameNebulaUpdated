//=============================================================================
// BowenFlare.
//=============================================================================
class BowenFlare extends DeusExProjectile;

#exec OBJ LOAD FILE=Effects

var ParticleGenerator smokeGen;
var (Bowen) float GravMult;
var actor WhackActor;

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

/*
simulated function DrawEffects(vector HitLocation)
{
   local ParticleGenerator FlareGen;

	// Spawn the pretty effects!
	FlareGen = Spawn(class'ParticleGenerator',,,HitLocation + vect(0,0,3));
	if (FlareGen != None)
	{
		FlareGen.particleTexture = Texture'Effects.Corona.Corona_E';
		FlareGen.particleDrawScale = 0.3;
		FlareGen.checkTime = 0.02;
		FlareGen.riseRate = 128.0;
		FlareGen.ejectSpeed = 0.0;
		FlareGen.particleLifeSpan = 0.5;
		FlareGen.bRandomEject = True;
      		FlareGen.RemoteRole = ROLE_None;
	}
	Super.DrawEffects(HitLocation);
}*/


simulated function tick (float deltatime)
{
	local float dist;

	Super.tick(deltatime);

	dist = Abs(VSize(initLoc - Location));

	if (dist > AccurateRange)		// start descent due to "gravity"
		Acceleration = GravMult*Region.Zone.ZoneGravity;		
}

auto state flying
{
	function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if(Other != Owner && Pawn(Other) != None)
		{
			WhackActor = Other;
			//log("BowenFlare - Aquired WhackActor");
		}
		Super.ProcessTouch(Other, HitLocation);
	}

	function Explode (Vector HitLocation, vector HitNormal)
	{	
	   local FlareDamage fd;

		//if(Level.NetMode != Nm_client)
		//{
			fd = Spawn (class'FlareDamage',Owner,,HitLocation + HitNormal*10, rotator(HitNormal));
			if (fd != None && WhackActor != None)
			{
				if(Level.NetMode == NM_Standalone)
					fd.WhackActor = WhackActor;
				fd.SetBase(WhackActor);
				fd.SetRotation(rotator(vect(0,0,1)));
			}
		//}
		Super.Explode(HitLocation, HitNormal);
	}
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
	if(Other != Owner && Other != None)
	{
		WhackActor = Other;
		//log("BowenFlare - Aquired WhackActor");
	}
	Super.ProcessTouch(Other, HitLocation);
}

defaultproperties
{
     bExplodes=True
     bBlood=True
     bDebris=True
     blastRadius=100.000000
     DamageType=flamed
     AccurateRange=0
     maxRange=5000
     ItemName="flare gun"
     ItemArticle="a"
     speed=1750.000000
     MaxSpeed=5000.000000
     Texture=Texture'Effects.Corona.Corona_D'
     Texture=Texture'DeusExDeco.Skins.AlarmLightTex6'
     DrawType=DT_Sprite
     Style=STY_Translucent
     Damage=25.000000
     MomentumTransfer=0
     SpawnSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     ImpactSound=Sound'DeusExSounds.Generic.SmallExplosion'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Mesh=LodMesh'DeusExItems.HECannister20mm'
     GravMult=0.250000
	LightBrightness=128
        LightEffect=LT_NonIncidence
	LightType=LT_Steady
	LightSaturation=255
	LightRadius=16
	bAlwaysRelevant=True
}
