//=============================================================================
// FireBomb. 	(c) 2003 JimBowen
//=============================================================================
class FireBomb expands LAM;

var(Bowen) int FlameDamage, MaxGrenades;
var(Bowen) float SpawnPointCheckRadius;
var bool bDoneMsg;

replication
{
//	reliable if (Role == ROLE_Authority)
//		SpawnDamage;
		
	reliable if (Role == ROLE_Authority)
		bDoneMsg, SpawnSmoke;
}


function PostBeginPlay()
{
	local FireBomb FB, First;
	local bool bFoundFirst;
	local int NumFound;	
	
		foreach allactors (Class'FireBomb',FB)
		{
			if (!bFoundFirst && FB != Self)
				First = FB;
			NumFound ++;
		}
		
		if (NumFound > MaxGrenades)
		{
			First.SpawnSmoke();
			First.Destroy();
		}	
		Super.PostBeginPlay();
}

/*
simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
		SpawnFireEffect(HitLocation);
	Super.SpawnEffects (HitLocation, HitNormal, Other);
}*/

auto simulated state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		SpawnDamage(HitLocation);
		Super.Explode(HitLocation, HitNormal);
	}
}

simulated function timer()
{
		local PlayerStart Spawn;
		local SpawnExtension SpawnExt;
		
			if (Level.NetMode == NM_Standalone)
			{
				Super.Timer();
				return;
			}
			
			foreach RadiusActors (class 'PlayerStart', Spawn, SpawnPointCheckRadius)
			{
				if (FastTrace(Spawn.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
				{
					if (Owner.IsA('DeusExPlayer'))
					{
						DeusExPlayer(Owner).ClientMessage("Incendiary grenades are not allowed in spawn rooms");
						log("FireLam placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
					}
					else log ("FireLam was found in spawn room with no player owner");
					SpawnSmoke();
					bDoneMsg = True;
					Destroy();
					return;
				}
			}
			
			foreach RadiusActors (class 'SpawnExtension', SpawnExt, SpawnPointCheckRadius)



			{
				if (FastTrace(Spawn.Location, Location) && !bDoneMsg)// only do this once, and if we can see the spawn
				{
					if (Owner.IsA('DeusExPlayer'))
					{
						DeusExPlayer(Owner).ClientMessage("Incendiary grenades are not allowed in spawn rooms");
						log("FireLam placed in spawn room by " $ DeusExPlayer(Owner).PlayerReplicationInfo.PlayerName $ "!");
					}
					else log ("FireLam was found in spawn room with no player owner");
					SpawnSmoke();
					bDoneMsg = True;
					Destroy();
					return;
				}
			}
		if(!bDoneMsg)
			Super.Timer();
					
}

simulated function SpawnSmoke()
{
	local ParticleGenerator gen;
	
				gen = Spawn(class'ParticleGenerator', Self,, Location, rot(16384,0,0));
				if (gen != None)
				{
					gen.checkTime = 0.25;
					gen.LifeSpan = 2;
					gen.particleDrawScale = 0.3;
					gen.bRandomEject = True;
					gen.ejectSpeed = 10.0;
					gen.bGravity = False;
					gen.bParticlesUnlit = True;
					gen.frequency = 0.5;
					gen.riseRate = 10.0;
					gen.spawnSound = Sound'Spark2';
					gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
					gen.SetBase(Self);
				}
}



function SpawnDamage(vector HitLocation)
{
	local firedamage damage;		
	
	if(Role == ROLE_Authority)
	{	
		damage = Spawn(class'FireDamage',,,HitLocation);
		if (damage != None)
		{
			damage.EffectRadius = BlastRadius + 10;
			damage.damage = FlameDamage;
			damage.PawnOwner = Pawn(Owner);
		}
	}
}
/*	Now done from FireFamage
simulated function SpawnFireEffect (vector HitLocation)
{
	local FireEffect flames;
	
	if(Role != ROLE_Authority || Level.NetMode == NM_Standalone)
	{	
		flames = Spawn(class'FireEffect',,,HitLocation);
			if (flames != None)
			{
				flames.EffectRadius = BlastRadius;
				flames.RiseRate = 25;
				flames.SpriteLifeSpan = 2;
				flames.FrequencyMultiplier = 1;
			}
	}
}*/

//---END-CLASS---

defaultproperties
{
     FlameDamage=20
     MaxGrenades=3
     SpawnPointCheckRadius=300.000000
     mpBlastRadius=256.000000
     mpProxRadius=200.000000
     mpLAMDamage=0.000000
     mpFuselength=2.000000
     spawnWeaponClass=Class'FireLAM'
     ItemName="Incendiary Grenade"
     ItemArticle="an"
     Damage=0.000000
     bAlwaysRelevant=True
}
