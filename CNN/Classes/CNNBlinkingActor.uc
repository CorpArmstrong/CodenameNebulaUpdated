class CNNBlinkingActor extends Male1;

var () bool bUseBlinking;

function Tick(float deltaTime)
{
    super.Tick(deltaTime);
	BlinkActor();
}

function BlinkActor()
{
	local float blinkValue;
	
	if (bUseBlinking)
	{
		blinkValue = FRand();
		
		if (blinkValue > 0.5)
		{
			DrawType = DT_None;
		}
		else
		{
			DrawType = DT_Mesh;
		}
	}
}

DefaultProperties
{
	bUseBlinking=true
}
