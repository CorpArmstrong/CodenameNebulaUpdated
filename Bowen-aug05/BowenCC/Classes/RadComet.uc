//=============================================================================
// RadComet. 	(c) 2003 JimBowen
//=============================================================================
class RadComet expands FireComet;

auto simulated state Flying
{
	simulated function BeginState()
	{
		Velocity = VRand() * 300;
		if(vector(Rotation).Z > 0)
			Velocity.Z = FRand() * 200 + 200;
		DrawScale = (0.3 + FRand())/8;
		SetRotation(Rotator(Velocity));
	}

	simulated function HitWall(vector HitNormal, actor Wall)
	{
		local RadSplat mark;

		mark = spawn(class'RadSplat',,, Location, Rotator(HitNormal));
		if (mark != None)
		{
			mark.DrawScale = (2*FRand()*DrawScale) + DrawScale;
			mark.ReattachDecal();
		}
		Destroy();
	}
}

simulated function Tick(float deltaTime)
{
	local RadSplat mark;
	
		ScaleGlow = Default.ScaleGlow * (LifeSpan / Default.LifeSpan);
		if (Velocity == vect(0,0,0))
		{
			mark = spawn(class'RadSplat',,, Location, rot(16384,0,0));
			if (mark != None)
			{
				mark.DrawScale = (4*FRand()*DrawScale) + DrawScale;
				mark.ReattachDecal();
			}
				Destroy();
		}
		else
			SetRotation(Rotator(Velocity));
}

//---END-CLASS---

defaultproperties
{
     LifeSpan=0.300000
     DrawType=DT_Sprite
     Texture=Texture'BowenCust.Effects.RadSpark'
     DrawScale=0.100000
     ScaleGlow=1.000000
}
