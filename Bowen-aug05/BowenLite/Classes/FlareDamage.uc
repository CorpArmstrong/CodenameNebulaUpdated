//================================================
// FlareDamage
//================================================

class FlareDamage expands BowenBasicActor2;

#exec OBJ LOAD FILE=Effects

var ParticleGenerator FlareGen;
var float DamageTimer, FireTimer;
Var (Bowen) float DamageTime, FireTime, DamageRadius, Damage, Spewage;
var vector TargetLocation;
var FlareLight Light;
var int maxCopies;
var actor WhackActor;
var bool bHadWhackActor;
var vector RealLocation;

replication
{
	reliable if (Role == ROLE_Authority)
		RealLocation;
}

function SpawnGen()
{
	// Spawn the pretty effects!
	FlareGen = Spawn(class'ParticleGenerator',,,Location);
	if (FlareGen != None)
	{
		if(WhackActor != None)
			FlareGen.SetBase(Base);
		FlareGen.particleTexture = Texture'Effects.Corona.Corona_E';
		FlareGen.particleDrawScale = 0.3;
		FlareGen.checkTime = 0.01;
		FlareGen.riseRate = 0.0;
		FlareGen.ejectSpeed = 1024.0;
		FlareGen.particleLifeSpan = 0.5;
		FlareGen.bRandomEject = True;
		FlareGen.NumPerSpawn = 2;
      		FlareGen.RemoteRole = ROLE_None;
		FlareGen.LifeSpan = 120;
	}
}

Simulated  function Tick (float DeltaTime)
{
   Local Fireball Fire;
	DamageTimer += DeltaTime;
	FireTimer += DeltaTime;

	TargetLocation = location + 200*normal(vector(rotation));

	if (WhackActor != None)
		if ( WhackActor.IsInState('Dying'))
			Destroy();

	if(Level.NetMode != NM_Client)
	{
		if (DamageTimer > DamageTime)
		{
			DamageTimer = 0;
			HurtRadius(Damage, DamageRadius, 'Flamed', 0, Location);
			if(WhackActor != None)
			{
				SetBase(WhackActor);
				SetLocation(WhackActor.Location);
				SetRotation(rotator(vect(0,0,1)));
				FlareGen.SetLocation(Location);
				FlareGen.SetRotation(Rotation);
				Light.SetLocation (Location + vect(0,0,50));
				bHidden = True;
				bHadWhackActor=True;
			}
			else if (bHadWhackActor)
				Destroy();
			else if(RealLocation != vect(0,0,0))
			{
				SetLocation(RealLocation);
				FlareGen.SetLocation(RealLocation);
				Light.SetLocation (RealLocation + vect(0,0,50));
			}		
			if(FlareGen == None && RealLocation != vect(0,0,0))
				SpawnGen();
		}
	}
	else if (Level.NetMode == NM_Client || Level.NetMode == NM_Standalone)
		SetRotation(rotator(normal(TargetLocation + Spewage*VRand() - Location)));
	if(LifeSpan < Default.LightRadius)
		LightRadius = LifeSpan;

	/*if (FireTimer > FireTime)
	{
		FireTimer = 0;
		Fire = Spawn(class'Fireball',Owner,,Location,rotator(normal(TargetLocation - Location)));
		if(Fire != None)
			Fire.bHidden = True;
	}*/
}

simulated function Destroyed()
{
	FlareGen.DelayedDestroy();
	Light.Destroy();
}

simulated function PostBeginPlay()
{
    local FlareDamage fd, ffd;
    local int numfd;
	SpawnGen();
	if (WhackActor != None)
	{
		SetBase(WhackActor);
		SetLocation(WhackActor.Location);
		SetRotation(rotator(vect(0,0,1)));
		bHidden = True;
		//log("We have a WhackActor!");
	}

	if (Level.NetMode == NM_DedicatedServer)
		RealLocation = Location;

	TargetLocation = location + 200*normal(vector(rotation));
	Light = Spawn(class'FlareLight',,,TargetLocation);

	foreach allactors (class'FlareDamage', fd)
	{
		if (ffd == None && fd != None)
			ffd = fd;
		numfd ++;
		if(numfd > maxCopies && ffd != None)
			ffd.Destroy();
	}
	if(Level.NetMode == NM_DedicatedServer)
		bHidden=True;
}

defaultproperties
{
	DamageTime=0.3
	Damage=3
	DamageRadius=50
        AmbientSound=sound'DeusExSounds.Ambient.SteamVent2'
	bHidden=False
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'Effects.Corona.Corona_D'
	Texture=Texture'DeusExDeco.Skins.AlarmLightTex6'
	LifeSpan=60
	SoundRadius=64
	SoundVolume=255
	Spewage=100
	maxCopies=6
	FireTime=0.5
	bAlwaysRelevant=True
}