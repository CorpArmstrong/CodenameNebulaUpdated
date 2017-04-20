//=============================================================================
// FireEffect. 	(c) 2003 JimBowen
//=============================================================================
class FireEffect expands Effects;

var(Bowen) float EffectRadius;
var(Bowen) float FireHeight;
var(Bowen) float RiseRate;
var(Bowen) float SpriteLifeSpan;
var(Bowen) int FrequencyMultiplier;
	
event ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	if (NewZone.bWaterZone)
		Destroy();
}

simulated function tick (float deltatime)
{
	local vector loc;
	local float f;
	local FireSprite flames;
	local int i;

	if (Level.NetMode == NM_DedicatedServer)
		return;
	
	for( i=0; i<FrequencyMultiplier; i++ )
	{
		loc = location;
		loc += VRand() * EffectRadius;
		f = FRand() * FireHeight;
		loc.z = location.z + f;
		if(FastTrace(Location, loc))
		{
			flames = Spawn(class'BowenLite.FireSprite',,,loc); 
			if (flames != None)
			{
				if(VSize(loc - Location) > (EffectRadius / 2))
				{
					flames.velocity.z = RiseRate;
					flames.LifeSpan = SpriteLifeSpan * 2;
				}
				else
				{
					flames.velocity.z = RiseRate / 2;
					flames.LifeSpan = SpriteLifeSpan;
				}
				if(FRand() > 0.6)
					flames.Texture = texture'Effects.Fire.Flame_J';
			}
		}
		
		loc = location;
		loc += VRand() * (EffectRadius / 2);
		f = FRand() * FireHeight;
		loc.z = location.z + f;
		if(FastTrace(Location, loc))
		{
			flames = Spawn(class'BowenLite.FireSprite',,,loc); 
			if (flames != None)
			{
				if(VSize(loc - Location) > (EffectRadius / 2))
				{
					flames.velocity.z = RiseRate * 2;
					flames.LifeSpan = SpriteLifeSpan * 2;
				}
				else
				{
					flames.velocity.z = RiseRate;
					flames.LifeSpan = SpriteLifeSpan;
				}
				if(FRand() > 0.4)
					flames.Texture = texture'Effects.Fire.Flame_J';
			}
		}

		loc = location;
		loc += VRand() * EffectRadius;
		f = FRand() * FireHeight;
		loc.z = location.z + f;
		if(FastTrace(Location, loc))
		{
			flames = Spawn(class'BowenLite.FireSprite',,,loc); 
			if (flames != None)
			{
				if(VSize(loc - Location) > (EffectRadius / 2))
				{
					flames.velocity.z = RiseRate * 2;
					flames.LifeSpan = SpriteLifeSpan * 4;
				}
				else
				{
					flames.velocity.z = RiseRate;
					flames.LifeSpan = SpriteLifeSpan * 2;
				}
			flames.texture = texture'Effects.Smoke.SmokePuff1';
			}
		}
		
		loc = location;
		loc += VRand() * EffectRadius / 2;
		f = FRand() * FireHeight;
		loc.z = location.z + f;
		if(FastTrace(Location, loc))
		{
			flames = Spawn(class'BowenLite.FireSprite',,,loc); 
			if (flames != None)
			{
				if(VSize(loc - Location) > (EffectRadius / 2))
				{
					flames.velocity.z = RiseRate * 4;
					flames.LifeSpan = SpriteLifeSpan * 4;
				}
				else
				{
					flames.velocity.z = RiseRate * 2;
					flames.LifeSpan = SpriteLifeSpan * 4;
				}
			flames.texture = texture'Effects.Smoke.SmokePuff1';
			}
		}
	}
}	


//---END-CLASS---

defaultproperties
{
     EffectRadius=300.000000
     FireHeight=50.000000
     RiseRate=50.000000
     SpriteLifeSpan=3.000000
     FrequencyMultiplier=2
     Physics=PHYS_Falling
     RemoteRole=ROLE_None
     LifeSpan=30.000000
     SoundRadius=128
     SoundVolume=255
     SoundPitch=96
     AmbientSound=Sound'Ambient.Ambient.FireSmall2'
     bCollideWorld=True
     LightType=LT_Steady
     LightEffect=LE_FireWaver
     LightBrightness=120
     LightHue=20
     LightSaturation=240
     LightRadius=45
     LightPeriod=30
     LightPhase=65
     VolumeBrightness=96
     VolumeRadius=45
}
