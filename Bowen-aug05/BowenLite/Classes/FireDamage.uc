//=============================================================================
// FireDamage. 	(c) 2003 JimBowen
//=============================================================================
class FireDamage expands Effects;

var(Bowen) float EffectRadius;
var(Bowen) float FireHeight;
var(Bowen) int Damage;
//var(Bowen) int Ticks;
var(Bowen) float DamageTimer;
var Pawn Pawnowner;

//var int time;

replication
{
	reliable if (role == ROLE_Authority)
		DoDamage;
}

simulated function PostBeginPlay()
{
//	if (Level.NetMode != NM_DedicatedServer)
		SpawnFireEffect(Location);
	Super.postBeginPlay();
}

simulated function SpawnFireEffect (vector HitLocation)
{
	local FireEffect flames;
	
	if(Role != ROLE_Authority || Level.NetMode == NM_Standalone)
	{	
		flames = Spawn(class'FireEffect',,,HitLocation);
			if (flames != None)
			{
				flames.EffectRadius = EffectRadius - 10;
				flames.RiseRate = 25;
				flames.SpriteLifeSpan = 2;
				flames.FrequencyMultiplier = 1;
			}
	}
}

/*
function PostBeginPlay()
{  
	local firesprite f;
	local vector loc;
	
		loc = Location;
		loc.z += FireHeight / 2;
   		f = Spawn(class'BowenLite.FireSprite',,,Loc);
   		if (f != None)
   		{
   			f.LifeSpan = LifeSpan;
   			f.Velocity = vect(0,0,0);
   			f.SetBase(Self);
   			f.DrawScale *= 3;
   		}
}*/

event ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	if (NewZone.bWaterZone)
		Destroy();
}

simulated function tick (float deltatime)
{
	if (DamageTimer <= 0)
	{
		DoDamage();
	}
	DamageTimer -= DeltaTime;
	//log("local: " $ Role $ "   remote: " $ RemoteRole); 
}

function DoDamage()
{
	local actor a;
	local vector loc;
	local float f;
	
//		time++;

/* --------GOD DAMN! this wont work on the client side for some stupid reason. it ONLY does damage on the
						client side, no matter what i do. causing shield users to die but not die, and everyone
						else to survive without a scratch. unfourtunately this means that my cylindrical damage
						system is only good for singleplayer. im going to have to revert to a primitive hurtradius
						in multiplayer for the time being.	*/
						
					//	Update:  HAHA - fixed it! =P
	if (Level.NetMode == NM_Client)
		return;

//	if(time == Ticks)
//	{
	//	if (Level.NetMode == NM_Standalone)
	//	{
			foreach VisibleActors (class'Actor', a, EffectRadius)
			{
				if (a != None)
				{
					loc = a.Location;
					f = loc.z - Location.z;
					if (f <= FireHeight)
						a.TakeDamage (Damage*(Default.DamageTimer - DamageTimer), PawnOwner, a.Location, vect(0,0,0), 'Flamed');
				}
			}
			
			foreach VisibleActors (class'Actor', a, EffectRadius / 2)
			{
				if (a != None)
				{
					loc = a.Location;
					f = loc.z - Location.z;
					if (f <= FireHeight * 2)
						a.TakeDamage (Damage*(Default.DamageTimer - DamageTimer), PawnOwner, a.Location, vect(0,0,0), 'Flamed');
				}
			}

	/*	}
		else
		{
			HurtRadius (Damage, EffectRadius, 'Flamed', 0, Location, False);
			HurtRadius (Damage, EffectRadius / 2, 'Flamed', 0, Location, False); // double damage in centre
		}*/
		
	//	time = 0;
	//	log("did some damage");
//	}
	
}
		

//---END-CLASS---

defaultproperties
{
     EffectRadius=300.000000
     FireHeight=50.000000
     Damage=40
     Physics=PHYS_Falling
     LifeSpan=33.000000
     DrawType=DT_Sprite
     Style=STY_Masked
     Texture=FireTexture'Effects.Fire.flame_b'
     DrawScale=3.000000
     bCollideWorld=True
     bAlwaysRelevant=True
     DamageTimer=0.2
}
