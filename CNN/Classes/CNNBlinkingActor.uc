class CNNBlinkingActor extends Male1;

var (ActorVisualEffects) bool  bEffects;
var (ActorVisualEffects) float blinkingTime;

var bool bVisible;
var float blinkValue;

function Tick(float deltaTime)
{
    // local...
    super.Tick(deltaTime);

    if (bEffects)
	{
		// current puls period
		// output 0.0 - 1.0
		blinkValue = (level.TimeSeconds % blinkingTime) / BlinkingTime;

		// current puls value
		// input  0.0 - 0.5 - 1.0
		// output 0.0 - 1.0 - 0.0
		if ( blinkValue > 0.5 )
			blinkValue = 1 - blinkValue;
		blinkValue *= 2;

        bHidden = bVisible;
	}
}

DefaultProperties
{
      bEffects=true
}
