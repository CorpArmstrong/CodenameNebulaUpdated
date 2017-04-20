//=============================================================================
// FlashBangEffect. 	(c) 2003 JimBowen
//=============================================================================
class FlashBangEffect expands Effects;

var float BlastRadius;
var float OriginalBlastRadius;
var pawn PawnOwner;


simulated function tick(float deltatime)
{
	local Pawn A;

		if (LifeSpan > Default.LifeSpan / 9)
			//foreach visibleactors (class'Pawn', A, BlastRadius)
			for (A=Level.PawnList; A!=None; A = A.NextPawn)
			{
				if (A != None)
					if(FastTrace(Location, A.Location) && VSize(A.Location - Location) < BlastRadius)	
						if (A.IsA('DeusExPlayer') && (A != Owner 
						|| (Default.LifeSpan - LifeSpan) > 0.1 ))
						{
							if (DeusExPlayer(A).ReducedDamageType == 'All')
								continue;
							DeusExPlayer(A).ClientFlash(6, vect(1000,1000,1000));
						}
						else
							A.TakeDamage(1, PawnOwner, A.Location, vect(0,0,0), 'TearGas');
			}
		
		if (level.NetMode == NM_Client)
		{			
			LightRadius = (Default.LightRadius / Default.LifeSpan) * LifeSpan;
			LightBrightness = (Default.LightBrightness / Default.LifeSpan) * LifeSpan;
			DrawScale = ((1 / Default.LifeSpan) * LifeSpan) * Default.DrawScale;
			DrawType = DT_Mesh;
			BlastRadius = ((1 / Default.LifeSpan) * LifeSpan) * OriginalBlastRadius;
		}
		else
		{
			LightRadius = 0;
			LightBrightness = 0;
			DrawType = DT_None;
			BlastRadius = ((1 / Default.LifeSpan) * LifeSpan) * OriginalBlastRadius;
		}
}

//---END-CLASS---

defaultproperties
{
     LifeSpan=10.000000
     DrawType=DT_Mesh
     Style=STY_Masked
     Texture=Texture'Extension.CheckboxOff'
     Skin=Texture'Extension.CheckboxOff'
     Mesh=LodMesh'DeusExItems.SphereEffect'
     DrawScale=75.000000
     bAlwaysRelevant=True
     LightType=LT_Steady
     LightBrightness=128
     LightSaturation=192
     LightRadius=64
     LightPeriod=32
     LightCone=128
}
