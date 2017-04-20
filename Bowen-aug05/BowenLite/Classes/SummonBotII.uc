//=============================================================================
// SummonBot II. 	(c) 2003 JimBowen
//=============================================================================
class SummonBotII expands mutator
config (Bowen);


struct Item
{
	var class <Inventory> Cl;
	var vector Pos;
	var rotator Rot;
};

struct MapList
{
	var string MapName;
	var Item List[4096];
};

var config MapList MapsList[32];
/*

simulated function PostBeginPlay()
{
	local string LevelString;
	local ModController Controller;
	local int MapNum, i, n;
	local Inventory A;

		log("SummonBotII: Came into existance.");
		
		if (Controller == None)
		{	
			log("SummonBotII: No Controller - Adding self to mutators list.");
			Controller = spawn (class'ModController',,,Location);
			Level.Game.BaseMutator.AddMutator(Self);
		}
		
		LevelString = String(Level);
		
		if (Level.NetMode != NM_Standalone)
		{
		
		/*	// replace normal medbots with disc-removing medbots, and grenades with lambug-proof ones
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
			}	*/
		
			for (i=0;i<32;i++)
			{
				if (LevelString = MapsList[i][MapName])
				{
					MapNum = i;
					break;
				}
				else
				{
					log ("SummonBot II: No Bowen info for this map! Aborting.");
					return;
				}
			}
		}
		else
			return;
		
		foreach allactors (class'Inventory', A)
			A.Destroy();
		
		for (i=0;i<4096;i++)
			if (MapsList[MapNum].Item[i].Cl != None)
			{
				Inv = spawn (MapsList[MapNum][Item][i][Cl],,, MapsList[MapNum][Item][i][Pos], MapsList[MapNum][Item][i][Rot]);
				if (Inv != None)
				{
					if (Inv.IsA('BowenWeapon')
						BowenWeapon(Inv).Controller = Controller;
					n++;
				}
				else
					log ("SummonBot II: Error spawning" @ MapsList[MapNum][Item][i][Cl] @ ". No actor spawned.");
			}
		log("SummonBot II: Spawned" @ n @ "objects successfully.");
		
}


function Mutate(string MutateString, PlayerPawn Sender)
{
	local Inventory Inv;
	local int MapNum, i;
	local string LevelString, ListMap;
	local object TempObj;

		LevelString = String(Level);

		if (MutateString ~= "ScanMap" && Sender.bAdmin)
		{
			Log("SummonBotII: Begin scanning map.");
			for (i=0;i<32;i++)
			{
				TempObj = MapsList[i];
				ListMap = MapList(TempObj).MapName;
				if (LevelString == ListMap)
				{
					MapNum = i;
					break;
				}
				else if (MapsList[i].MapName == "")
				{
					MapNum = i;
					MapsList[i].MapName = LevelString;
					break;
				}
			}

				
			foreach AllActors(class'Inventory', Inv)
				if ((Inv != None) && Inv.Owner == None)
				{
					MapsList[i].Item[i].Cl = Inv.Class;
					MapsList[i].Item[i].Pos = Inv.Location;
					MapsList[i].Item[i].Rot = Inv.Rotation;
					i++;
					log ("SummonBot II: Saved item" @ MapsList[i].Item[i].Cl);
				}

			SaveConfig();
		}
				
}*/

//---END-CLASS---

defaultproperties
{
}
