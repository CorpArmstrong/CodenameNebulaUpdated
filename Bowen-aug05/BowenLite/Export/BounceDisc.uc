//================================================================================
// BounceDisc.
//================================================================================
class BounceDisc extends ExplosiveDisc;

var bool bCanHitOwner;
var int NumHits;
var(bowen) int MaxBounces;
var(bowen) Sound RicochetSound;

auto state Flying extends Flying
{
	simulated function HitWall (Vector HitNormal, Actor Wall)
	{
		Velocity -= 2 * Velocity Dot HitNormal * HitNormal;
		SetRotation(rotator(Velocity));
		bCanHitOwner=True;
		NumHits++;
		PlayRicochetSound();
		if ( NumHits >= MaxBounces )
		{
			Explode(Location,vect(0.00,0.00,1.00));
		}
	}
	
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( bStuck )
		{
			return;
		}
		if ( ((Other != Instigator) || bCanHitOwner) && (DeusExProjectile(Other) == None) && ((Other != Owner) || bCanHitOwner) )
		{
			damagee=Other;
			Explode(HitLocation,Normal(HitLocation - damagee.Location));
			if ( Role == 4 )
			{
				if ( damagee.IsA('Pawn') &&  !damagee.IsA('Robot') && bBlood )
				{
					SpawnBlood(HitLocation,Normal(HitLocation - damagee.Location));
				}
			}
		}
	}
	
}

function PlayRicochetSound ()
{
	local float rad;

	if ( (Level.NetMode == 0) || (Level.NetMode == 2) || (Level.NetMode == 1) )
	{
		rad=Max(blastRadius * 4,1024);
		PlaySound(RicochetSound,0,2.00,,rad);
	}
}

simulated function SetTexture ()
{
	MultiSkins[1]=Texture'BkgndHi';
}

simulated function Detonate ();

simulated function TakeDamage (int Dam, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType);

defaultproperties
{
    MaxBounces=30
    RicochetSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
    mpDamage=35
    GravMult=0.00
    bStickToWall=False
    DamageType=shot
    speed=2500.00
    MaxSpeed=4000.00
    Damage=40.00
    bBounce=True
}