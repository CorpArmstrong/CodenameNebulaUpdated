//================================================================================
// FlashBangEffect.
//================================================================================
class FlashBangEffect extends Effects;

var float blastRadius;
var float OriginalBlastRadius;
var Pawn PawnOwner;

simulated function Tick (float DeltaTime)
{
	local Pawn A;

	if ( LifeSpan > Default.LifeSpan / 9 )
	{
		A=Level.PawnList;
JL0028:
		if ( A != None )
		{
			if ( A != None )
			{
				if ( FastTrace(Location,A.Location) && (VSize(A.Location - Location) < blastRadius) )
				{
					if ( A.IsA('DeusExPlayer') )
					{
						if ( DeusExPlayer(A).ReducedDamageType == 'All' )
						{
							goto JL010C;
						}
						DeusExPlayer(A).ClientFlash(10.00,vect(1000.00,1000.00,1000.00));
					}
					else
					{
						A.TakeDamage(1,PawnOwner,A.Location,vect(0.00,0.00,0.00),'TearGas');
					}
				}
			}
JL010C:
			A=A.nextPawn;
			goto JL0028;
		}
	}
	LightRadius=Default.LightRadius / Default.LifeSpan * LifeSpan;
	LightBrightness=Default.LightBrightness / Default.LifeSpan * LifeSpan;
	DrawScale=1.00 / Default.LifeSpan * LifeSpan * Default.DrawScale;
	blastRadius=1.00 / Default.LifeSpan * LifeSpan * OriginalBlastRadius;
}

defaultproperties
{
    LifeSpan=10.00
    DrawType=2
    Style=2
    Texture=Texture'Extension.CheckboxOff'
    Skin=Texture'Extension.CheckboxOff'
    Mesh=LodMesh'DeusExItems.SphereEffect'
    DrawScale=75.00
    bAlwaysRelevant=True
    LightType=1
    LightBrightness=192
    LightSaturation=192
    LightRadius=192
    LightPeriod=32
    LightCone=128
}