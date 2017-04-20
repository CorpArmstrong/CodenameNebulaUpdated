//=============================================================================
// RadLight. 	(c) 2003 JimBowen
//=============================================================================
class RadLight expands Light;

var float TimeSeconds;

simulated function Tick(float deltatime)
{
	local float NewBrightness;


		TimeSeconds += DeltaTime;

		NewBrightness = Default.LightBrightness - 10*TimeSeconds;
		
		if (NewBrightness >= 0)
			LightBrightness = int(NewBrightness);
		else
		{
			LightBrightness = 0;
			LightType = LT_None;
			Destroy();
		}


	Super.Tick(DeltaTime);
}

//---END-CLASS---

defaultproperties
{
     bStatic=False
     bNoDelete=False
     bMovable=True
     LightType=LT_SubtlePulse
     LightBrightness=192
     LightHue=59
     LightSaturation=159
     LightRadius=16
     LightPeriod=50
     LightPhase=30
}
