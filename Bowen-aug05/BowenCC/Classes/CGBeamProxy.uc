//=============================================================================
// CGBeamProxy.
//=============================================================================
class CGBeamProxy expands LaserProxy;

function tick (Float DeltaTime)
{
	if (ScaleGlow > 0)
		ScaleGlow -= Default.ScaleGlow*0.5*DeltaTime;
	Super.Tick(DeltaTime);
}

//---END-CLASS---

defaultproperties
{
     LifeSpan=5.000000
     Skin=FireTexture'Effects.liquid.Virus_SFX'
     DrawScale=6.500000
     bUnlit=True
}
