//=============================================================================
// SummonBot. 	(c) 2003 JimBowen
//=============================================================================
class SummonBot expands BowenBasicActor2
config (Bowen);

var config string AuxMapA, AuxMapB, AuxMapC, AuxMapD, AuxMapE, AuxMapF, AuxMapG, AuxMapH;

simulated function PostBeginPlay()
{
	local string LevelString;
	local ModController Controller;
	local MapBot Bot;
		
		if (Controller == None)
			Controller = spawn (class'ModController',,,Location);
		
		LevelString = String(Level);
		
		if (Level.NetMode != NM_Standalone)
		
			Switch LevelString
			{
				case "DXMP_Area51Bunker.LevelInfo0":
					Bot = Spawn(class'A51Bot',,,Location);
				break;
				
				case "DXMP_Smuggler.LevelInfo0":
					Bot = Spawn(class'SmugglerBot',,,Location);
				break;

				case "DXMP_CMD.LevelInfo0":
					Bot = Spawn(class'CMDBot',,,Location);
				break;

				case "DXMP_Silo.LevelInfo0":
					Bot = Spawn(class'SiloBot',,,Location);
				break;

				case "DXMP_WaterStation.LevelInfo0":
					Bot = Spawn(class'WaterStationBot',,,Location);
				break;
				
				case "DXMP_Cathedral.LevelInfo0":
					Bot = Spawn(class'CathedralBot',,,Location);
				break;

				case "DXMP_Towers.LevelInfo0":
					Bot = Spawn(class'TowersBot',,,Location);
				break;

				case "DXMP_Skyline.LevelInfo0":
					Bot = Spawn(class'SkylineBot',,,Location);
				break;

				case "DXMP_AnotherWorld3.LevelInfo0":
					Bot = Spawn(class'AnotherWorldBot',,,Location);
				break;

//				case "DXMP_LastBattle2.LevelInfo0":
//					Bot = Spawn(class'LastBattleBot',,,Location);
//				break;

				case (AuxMapA $ ".levelinfo0"):
					Bot = Spawn(class'AuxBotA',,,Location);
				break;
				
				case (AuxMapB $ ".levelinfo0"):
					Bot = Spawn(class'AuxBotB',,,Location);
				break;
				
				case (AuxMapC $ ".levelinfo0"):
					Bot = Spawn(class'AuxBotC',,,Location);
				break;
				
				case (AuxMapD $ ".levelinfo0"):
					Bot = Spawn(class'AuxBotD',,,Location);
				break;
				
				case (AuxMapE $ ".levelinfo0"):
					Bot = Spawn(class'AuxBotE',,,Location);
				break;
				
				case (AuxMapF $ ".levelinfo0"):
					Bot = Spawn(class'AuxBotF',,,Location);
				break;
				
				case (AuxMapG $ ".levelinfo0"):
					Bot = Spawn(class'AuxBotG',,,Location);
				break;
				
				case (AuxMapH $ ".levelinfo0"):
					Bot = Spawn(class'AuxBotH',,,Location);
				break;
				
				
		/*		case "DXMP_CMD.LevelInfo0":
					Bot = Spawn(class'CMDBot',,,Location);
				break;	*/
				
				default:
					log("SummonBot - - Map has no bowen weapon info, aborting.");
				break;
			}		
		Bot.Controller = Controller;
		
destroy();
	
}

//---END-CLASS---

defaultproperties
{
}
