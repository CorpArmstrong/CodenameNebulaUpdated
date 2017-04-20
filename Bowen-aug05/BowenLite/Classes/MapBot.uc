//=============================================================================
// MapBot. 	(c) 2003 JimBowen
//=============================================================================
class MapBot expands BowenBasicActor2

config(Bowen);

var config string names[85];
var config vector locs[85];
var config rotator rots[85];
var config string names2[85];
var config vector locs2[85];
var config rotator rots2[85];
var config string names3[85];
var config vector locs3[85];
var config rotator rots3[85];

var config int numMiniBots;
var ModController Controller;
/*
replication
{
	reliable if (Role == ROLE_Authority)
		replacebot;
}*/

function PostBeginPlay()
{
	local actor a;
	local int i, loops;
	local repairbot r, r2;
	local class<actor> spawnclass;
	
		if(Role != ROLE_Authority)
		return;

		if (Controller == None)
			Controller = spawn (class'ModController',,,Location);
		log ("Controller set to:" @ Controller);
		
		// replace normal medbots with disc-removing medbots, and grenades with lambug-proof ones
		foreach allactors(class'Actor', a)
		{
			if(a != None)
			{
				if (a.IsA('MedicalBot') && !a.IsA('BowenMedBot'))
				{
					a.SetCollision(False, False);
					spawn (class'BowenMedbot',,,a.Location,a.Rotation);
					a.Destroy();
				}
				else if (a.IsA('WeaponLAM'))
				{
					spawn (class'BowenLAM',,,a.Location,a.Rotation);
					a.Destroy();
				}
				else if (a.IsA('WeaponEMPGrenade'))
				{
					spawn (class'BowenEMPGrenade',,,a.Location,a.Rotation);
					a.Destroy();
				}
				else if (a.IsA('WeaponGasGrenade'))
				{
					spawn (class'BowenGasGrenade',,,a.Location,a.Rotation);
					a.Destroy();
				}
			}
		}
		
		log ("SummonBot: Beggining job.");
		
		for( i=0; i<85; i++ )
		{
			if (names[i] != "")
			{
				SpawnClass = class<actor>( DynamicLoadObject( names[i], class'Class' ) );
				if (SpawnClass != None)
				{
					a = Spawn(SpawnClass,,, locs[i], rots[i]);
					log("SummonBot - 1 -" @ i @ "- summoned:" @ a @ "at" @ locs[i]);
					if (BowenWeapon(a) != None)
						BowenWeapon(a).Controller = Controller;
					else if (BowenPickup(a) != None)
						BowenPickup(a).Controller = Controller;
				}
			}
		}

		for( i=0; i<85; i++ )
		{
			if (names2[i] != "")
			{
				SpawnClass = class<actor>( DynamicLoadObject( names2[i], class'Class' ) );
				if (SpawnClass != None)
				{
					a = Spawn(SpawnClass,,, locs2[i], rots2[i]);
					log("SummonBot - 2 -" @ i @ "- summoned:" @ a @ "at" @ locs2[i]);
					if (BowenWeapon(a) != None)
						BowenWeapon(a).Controller = Controller;
					else if (BowenPickup(a) != None)
						BowenPickup(a).Controller = Controller;
				}
			}
		}

		for( i=0; i<85; i++ )
		{
			if (names3[i] != "")
			{
				SpawnClass = class<actor>( DynamicLoadObject( names3[i], class'Class' ) );
				if (SpawnClass != None)
				{
					a = Spawn(SpawnClass,,, locs3[i], rots3[i]);
					log("SummonBot - 3 -" @ i @ "- summoned:" @ a @ "at" @ locs3[i]);
					if (BowenWeapon(a) != None)
						BowenWeapon(a).Controller = Controller;
					else if (BowenPickup(a) != None)
						BowenPickup(a).Controller = Controller;
				}
			}
		}
		
		i = 0;
	/*	if (numMiniBots != 0)
		{
			log("SummonBot - - Replacing RepairBots with MiniBots");
			Begin:
				foreach allactors (class'RepairBot', r)
					if (i < numMiniBots)
					{
					 	if (FRand() > 0.97)
						{
							replacebot(r);
							if (string(Level) ~= "DXMP_Cathedral.LevelInfo0") //WHY THE HELL IS THERE THAT BUG IN CATHEDRAL?
								foreach allactors (class'repairbot', r2)		//and ONLY cathedral!
									r2.Destroy();
							i++;
						}
						loops++;
					}
				if (loops >= 1024)
				{
					log("SummonBot - - looped too many times, aborting after" @ loops @ "iterations!");
					Goto'End';
				}
				if (i < numMiniBots)
					Goto'Begin';
			log("SummonBot - - Finished in" @ loops @ "iterations.");
		}*/
		End:
		Destroy();
}
/*
simulated function replacebot(repairbot r)
{	
	local vector loc;
	local rotator rot;
							
		rot = r.Rotation;
		loc = r.Location;
		log("SummonBot - Replaced " $ r); 
		r.LifeSpan = 1;
		r.Destroy();
		Spawn(class'BowenCore.MBDecoration',,,loc,rot);
		loc += vector(rot) * 30;
		Spawn(class'BowenCore.MBController',,,loc,rot);
}
*/
//---END-CLASS---

defaultproperties
{
     LifeSpan=40.000000
}
