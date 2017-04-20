//================================================================================
// FireDamage.
//================================================================================
class FireDamage extends Effects;

var(bowen) float EffectRadius;
var(bowen) float FireHeight;
var(bowen) int Damage;
var(bowen) int Ticks;
var Pawn PawnOwner;
var int Time;

replication
{
	reliable if ( Role == 4 )
		DoDamage;
}

simulated function PostBeginPlay ()
{
	if ( Level.NetMode == 3 )
	{
		SpawnFireEffect(Location);
	}
	Super.PostBeginPlay();
}

simulated function SpawnFireEffect (Vector HitLocation)
{
	local FireEffect flames;

	if ( (Role != 4) || (Level.NetMode == 0) )
	{
		flames=Spawn(Class'FireEffect',,,HitLocation);
		if ( flames != None )
		{
			flames.EffectRadius=EffectRadius - 10;
			flames.RiseRate=25.00;
			flames.SpriteLifeSpan=2.00;
			flames.FrequencyMultiplier=1;
		}
	}
}

event ZoneChange (ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);
	if ( NewZone.bWaterZone )
	{
		Destroy();
	}
}

simulated function Tick (float DeltaTime)
{
	DoDamage();
}

function DoDamage ()
{
	local Actor A;
	local Vector Loc;
	local float F;

	Time++;
	if ( Level.NetMode == 3 )
	{
		return;
	}
	if ( Time == Ticks )
	{
		foreach VisibleActors(Class'Actor',A,EffectRadius)
		{
			if ( A != None )
			{
				Loc=A.Location;
				F=Loc.Z - Location.Z;
				if ( F <= FireHeight )
				{
					A.TakeDamage(Damage,PawnOwner,A.Location,vect(0.00,0.00,0.00),'Flamed');
				}
			}
			continue;
		}
		foreach VisibleActors(Class'Actor',A,EffectRadius / 2)
		{
			if ( A != None )
			{
				Loc=A.Location;
				F=Loc.Z - Location.Z;
				if ( F <= FireHeight * 2 )
				{
					A.TakeDamage(Damage,PawnOwner,A.Location,vect(0.00,0.00,0.00),'Flamed');
				}
			}
			continue;
		}
		Time=0;
	}
}

defaultproperties
{
    EffectRadius=300.00
    FireHeight=50.00
    Damage=1
    Ticks=2
    Physics=2
    LifeSpan=33.00
    DrawType=1
    Style=2
    Texture=FireTexture'Effects.Fire.flame_b'
    DrawScale=3.00
    bCollideWorld=True
}