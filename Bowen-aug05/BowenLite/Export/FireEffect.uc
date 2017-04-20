//================================================================================
// FireEffect.
//================================================================================
class FireEffect extends Effects;

var(bowen) float EffectRadius;
var(bowen) float FireHeight;
var(bowen) float RiseRate;
var(bowen) float SpriteLifeSpan;
var(bowen) int FrequencyMultiplier;

event ZoneChange (ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);
	if ( NewZone.bWaterZone )
	{
		Destroy();
	}
}

simulated function Tick (float DeltaTime)
{
	local Vector Loc;
	local float F;
	local FireSprite flames;
	local int i;

	i=0;
JL0007:
	if ( i < FrequencyMultiplier )
	{
		Loc=Location;
		Loc += VRand() * EffectRadius;
		F=FRand() * FireHeight;
		Loc.Z=Location.Z + F;
		if ( FastTrace(Location,Loc) )
		{
			flames=Spawn(Class'FireSprite',,,Loc);
			if ( flames != None )
			{
				if ( VSize(Loc - Location) > EffectRadius / 2 )
				{
					flames.Velocity.Z=RiseRate;
					flames.LifeSpan=SpriteLifeSpan * 2;
				}
				else
				{
					flames.Velocity.Z=RiseRate / 2;
					flames.LifeSpan=SpriteLifeSpan;
				}
				if ( FRand() > 0.60 )
				{
					flames.Texture=FireTexture'Flame_J';
				}
			}
		}
		Loc=Location;
		Loc += VRand() * EffectRadius / 2;
		F=FRand() * FireHeight;
		Loc.Z=Location.Z + F;
		if ( FastTrace(Location,Loc) )
		{
			flames=Spawn(Class'FireSprite',,,Loc);
			if ( flames != None )
			{
				if ( VSize(Loc - Location) > EffectRadius / 2 )
				{
					flames.Velocity.Z=RiseRate * 2;
					flames.LifeSpan=SpriteLifeSpan * 2;
				}
				else
				{
					flames.Velocity.Z=RiseRate;
					flames.LifeSpan=SpriteLifeSpan;
				}
				if ( FRand() > 0.40 )
				{
					flames.Texture=FireTexture'Flame_J';
				}
			}
		}
		Loc=Location;
		Loc += VRand() * EffectRadius;
		F=FRand() * FireHeight;
		Loc.Z=Location.Z + F;
		if ( FastTrace(Location,Loc) )
		{
			flames=Spawn(Class'FireSprite',,,Loc);
			if ( flames != None )
			{
				if ( VSize(Loc - Location) > EffectRadius / 2 )
				{
					flames.Velocity.Z=RiseRate * 2;
					flames.LifeSpan=SpriteLifeSpan * 4;
				}
				else
				{
					flames.Velocity.Z=RiseRate;
					flames.LifeSpan=SpriteLifeSpan * 2;
				}
				flames.Texture=FireTexture'SmokePuff1';
			}
		}
		Loc=Location;
		Loc += VRand() * EffectRadius / 2;
		F=FRand() * FireHeight;
		Loc.Z=Location.Z + F;
		if ( FastTrace(Location,Loc) )
		{
			flames=Spawn(Class'FireSprite',,,Loc);
			if ( flames != None )
			{
				if ( VSize(Loc - Location) > EffectRadius / 2 )
				{
					flames.Velocity.Z=RiseRate * 4;
					flames.LifeSpan=SpriteLifeSpan * 4;
				}
				else
				{
					flames.Velocity.Z=RiseRate * 2;
					flames.LifeSpan=SpriteLifeSpan * 4;
				}
				flames.Texture=FireTexture'SmokePuff1';
			}
		}
		i++;
		goto JL0007;
	}
}

defaultproperties
{
    EffectRadius=300.00
    FireHeight=50.00
    RiseRate=50.00
    SpriteLifeSpan=3.00
    FrequencyMultiplier=2
    Physics=2
    RemoteRole=0
    LifeSpan=30.00
    SoundRadius=128
    SoundVolume=255
    SoundPitch=96
    AmbientSound=Sound'Ambient.Ambient.FireSmall2'
    bCollideWorld=True
    LightType=1
    LightEffect=2
    LightBrightness=120
    LightHue=20
    LightSaturation=240
    LightRadius=45
    LightPeriod=30
    LightPhase=65
    VolumeBrightness=96
    VolumeRadius=45
}