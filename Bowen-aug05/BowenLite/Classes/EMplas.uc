//=============================================================================
// EMplas.	 	(c) 2003 JimBowen
//=============================================================================
class EMplas expands DeusExProjectile;

var (Bowen) float GrowRate, FadeRate, mpBlastRadius;
var (Bowen) int mpDamage;
/*
simulated function PreBeginPlay()
{
	if(level.NetMode != NM_Standalone)
	{
		Damage = mpDamage;
		BlastRadius = mpBlastRadius;
		ScaleGlow = 128;
	}
}

simulated function Tick(float deltaTime)
{
	local float NewCollisionRadius, NewCollisionHeight;

		if (Level.NetMode == NM_Standalone)
		{
			NewCollisionRadius = CollisionRadius;
			NewCollisionHeight = CollisionHeight;
		
			NewCollisionRadius += Default.CollisionRadius*GrowRate*DeltaTime;
			NewCollisionHeight += Default.CollisionHeight*GrowRate*DeltaTime;

			SetCollisionSize (NewCollisionRadius, NewCollisionHeight);
		}

		DrawScale += Default.DrawScale*GrowRate*DeltaTime;
		if (ScaleGlow > 0)
			ScaleGlow -= Default.ScaleGlow*FadeRate*DeltaTime;

		if (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_Standalone)
		{
			if (Damage > 0)
				Damage -= 2 * Default.Damage*FadeRate*DeltaTime;
			else destroy();	
		}
}
*/
state exploding
{
	function DamageRing()
	{
		local actor a;
		local float dam;
			foreach RadiusActors(class'Actor', a, BlastRadius)
			{
				dam = 0.5 * Damage * BlastRadius/(2.5*VSize(Location - a.Location));
				if(Level.NetMode != NM_Standalone)
					dam = FMin (Damage * BlastRadius/(2*VSize(Location - a.Location)), 100);
				if (A.IsA('Pawn'))
					dam *= 4;
				a.TakeDamage(int(dam), Pawn(Owner), Location, vect(0,0,0), 'EMP');
			}
			Super.DamageRing();
	}
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local BlastSphere Sph;
	local int i;
	
		Sph = Spawn(class'BlastSphere',,,HitLocation);
		Sph.Size = 23;
		Sph.Skin = Texture'DeusExDeco.Skins.EidoslogoTex1';
		Sph.LifeSpan = 0.4;
}

//---END-CLASS---

defaultproperties
{
     GrowRate=2.000000
     FadeRate=0.300000
     mpBlastRadius=300.000000
     mpDamage=4
     bExplodes=True
     blastRadius=100.000000
     DamageType=Burned
     bIgnoresNanoDefense=True
     speed=800.000000
     Damage=2.000000
     Style=STY_Translucent
     Skin=FireTexture'Effects.Electricity.Nano_SFX_A'
     Mesh=LodMesh'DeusExDeco.Basketball'
     DrawScale=0.500000
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     bAlwaysRelevant=True
}
