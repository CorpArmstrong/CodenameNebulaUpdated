//=============================================================================
// SteelDisc.	(c) 2003 JimBowen
//=============================================================================
class BounceDisc expands ExplosiveDisc;

var bool bCanHitOwner;
var int NumHits;
var (Bowen) int MaxBounces, mpMaxBounces;
var (Bowen) sound RicochetSound;

auto state Flying
{
	simulated function HitWall (Vector HitNormal, Actor Wall)
	{
		Velocity -= 2 * (Velocity dot HitNormal) * HitNormal; 
		SetRotation (Rotator(Velocity));
		bCanHitOwner = True;
		NumHits ++;

		PlayRicochetSound(None);

		if ((NumHits >= MaxBounces && Level.NetMode == NM_StandAlone) || (NumHits >= mpMaxBounces && Level.NetMode != NM_StandAlone))
			Detonate();
	}
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if (Other == Owner && !bCanHitOwner)
			return;

		PlayRicochetSound(Other);
		if (Pawn(Other) != None && Other != Owner)
			Detonate();
		else
		{
			Velocity = Speed * VRand();
			SetRotation(Rotator(Velocity));
			bCanHitOwner=True;
			NumHits ++;
			if (NumHits >= MaxBounces)
				Detonate();
		}
	}
}

simulated function tick (float deltatime)
{
	if (LifeSpan < 1 && !bDetonated)
		Detonate();

	Super.tick(deltatime);
}

function PlayRicochetSound(Actor HitActor)
{
	local float rnd;
	local sound snd;

	rnd = FRand();

	if (rnd < 0.25)
		snd = sound'Ricochet1';
	else if (rnd < 0.5)
		snd = sound'Ricochet2';
	else if (rnd < 0.75)
		snd = sound'Ricochet3';
	else
		snd = sound'Ricochet4';

	// play a different ricochet sound if the object isn't damaged by normal bullets
	if (hitActor != None) 
	{
		if (hitActor.IsA('DeusExDecoration') && (DeusExDecoration(hitActor).minDamageThreshold > 10))
			snd = sound'ArmorRicochet';
		else if (hitActor.IsA('Robot'))
			snd = sound'ArmorRicochet';
	}

	PlaySound(snd, SLOT_None,,, 1024, 1.1 - 0.2*FRand());
}

function Detonate()
{
	if (bDisabled && !bDestroyedDamage)
	{
		SpawnSparks();
		if (Level.NetMode != NM_Standalone && !bTriedDetonate)
			LifeSpan = 5;
		bTriedDetonate = True;
		return;
	}
	
	bDetonated = True;
	bExplodes = True;
	ImpactSound = ExplodeSound;

	Explode(Location, vect(0,0,0));
	DrawEffects(Location);
}

//---END-CLASS---

defaultproperties
{
     MaxBounces=1000
     mpMaxBounces=10
     RicochetSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
     mpDamage=50
     GravMult=0.000000
     bStickToWall=False
     blastRadius=100.000000
     ItemName="Explosive Polymer Disc"
     speed=4000.000000
     MaxSpeed=4000.000000
     Damage=130.000000
     LifeSpan=30.000000
     MultiSkins(0)=Texture'DeusExDeco.Skins.AlarmLightTex9'
     bBounce=True
}
