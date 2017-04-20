//================================================================================
// MapBot.
//================================================================================
class MapBot extends BowenBasicActor2
	config(bowen);

var config string names[85];
var config Vector locs[85];
var config Rotator rots[85];
var config string names2[85];
var config Vector locs2[85];
var config Rotator rots2[85];
var config string names3[85];
var config Vector locs3[85];
var config Rotator rots3[85];
var config int numMiniBots;
var ModController Controller;

function PostBeginPlay ()
{
	local Actor A;
	local int i;
	local int loops;
	local RepairBot R;
	local RepairBot r2;
	local Class<Actor> SpawnClass;

	if ( Role != 4 )
	{
		return;
	}
	if ( Controller == None )
	{
		Controller=Spawn(Class'ModController',,,Location);
	}
	Log("Controller set to:" @ string(Controller));
	foreach AllActors(Class'Actor',A)
	{
		if ( A != None )
		{
			if ( A.IsA('MedicalBot') &&  !A.IsA('BowenMedBot') )
			{
				A.SetCollision(False,False);
				Spawn(Class'BowenMedBot',,,A.Location,A.Rotation);
				A.Destroy();
			}
			else
			{
				if ( A.IsA('WeaponLAM') )
				{
					Spawn(Class'BowenLAM',,,A.Location,A.Rotation);
					A.Destroy();
				}
				else
				{
					if ( A.IsA('WeaponEMPGrenade') )
					{
						Spawn(Class'BowenEMPGrenade',,,A.Location,A.Rotation);
						A.Destroy();
					}
					else
					{
						if ( A.IsA('WeaponGasGrenade') )
						{
							Spawn(Class'BowenGasGrenade',,,A.Location,A.Rotation);
							A.Destroy();
						}
					}
				}
			}
		}
		continue;
	}
	i=0;
JL01B9:
	if ( i < 85 )
	{
		if ( names[i] != "" )
		{
			SpawnClass=Class<Actor>(DynamicLoadObject(names[i],Class'Class'));
			if ( SpawnClass != None )
			{
				A=Spawn(SpawnClass,,,locs[i],rots[i]);
				Log("SummonBot - 1 -" @ string(i) @ "- summoned:" @ string(A) @ "at" @ string(locs[i]));
				if ( BowenWeapon(A) != None )
				{
					BowenWeapon(A).Controller=Controller;
				}
				else
				{
					if ( BowenPickup(A) != None )
					{
						BowenPickup(A).Controller=Controller;
					}
				}
			}
		}
		i++;
		goto JL01B9;
	}
	i=0;
JL02D5:
	if ( i < 85 )
	{
		if ( names2[i] != "" )
		{
			SpawnClass=Class<Actor>(DynamicLoadObject(names2[i],Class'Class'));
			if ( SpawnClass != None )
			{
				A=Spawn(SpawnClass,,,locs2[i],rots2[i]);
				Log("SummonBot - 2 -" @ string(i) @ "- summoned:" @ string(A) @ "at" @ string(locs2[i]));
				if ( BowenWeapon(A) != None )
				{
					BowenWeapon(A).Controller=Controller;
				}
				else
				{
					if ( BowenPickup(A) != None )
					{
						BowenPickup(A).Controller=Controller;
					}
				}
			}
		}
		i++;
		goto JL02D5;
	}
	i=0;
JL03F1:
	if ( i < 85 )
	{
		if ( names3[i] != "" )
		{
			SpawnClass=Class<Actor>(DynamicLoadObject(names3[i],Class'Class'));
			if ( SpawnClass != None )
			{
				A=Spawn(SpawnClass,,,locs3[i],rots3[i]);
				Log("SummonBot - 3 -" @ string(i) @ "- summoned:" @ string(A) @ "at" @ string(locs3[i]));
				if ( BowenWeapon(A) != None )
				{
					BowenWeapon(A).Controller=Controller;
				}
				else
				{
					if ( BowenPickup(A) != None )
					{
						BowenPickup(A).Controller=Controller;
					}
				}
			}
		}
		i++;
		goto JL03F1;
	}
	i=0;
	Destroy();
}

defaultproperties
{
    LifeSpan=40.00
}