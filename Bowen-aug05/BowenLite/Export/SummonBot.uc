//================================================================================
// SummonBot.
//================================================================================
class SummonBot extends BowenBasicActor2;

simulated function PostBeginPlay ()
{
	local string LevelString;
	local ModController Controller;
	local MapBot Bot;

	if ( Controller == None )
	{
		Controller=Spawn(Class'ModController',,,Location);
	}
	LevelString=string(Level);
	if ( Level.NetMode != 0 )
	{
		switch (LevelString)
		{
			case "DXMP_Area51Bunker.LevelInfo0":
			Bot=Spawn(Class'A51Bot',,,Location);
			break;
			case "DXMP_Smuggler.LevelInfo0":
			Bot=Spawn(Class'SmugglerBot',,,Location);
			break;
			case "DXMP_CMD.LevelInfo0":
			Bot=Spawn(Class'CMDBot',,,Location);
			break;
			case "DXMP_Silo.LevelInfo0":
			Bot=Spawn(Class'SiloBot',,,Location);
			break;
			case "DXMP_WaterStation.LevelInfo0":
			Bot=Spawn(Class'WaterStationBot',,,Location);
			break;
			case "DXMP_Cathedral.LevelInfo0":
			Bot=Spawn(Class'CathedralBot',,,Location);
			break;
			case "DXMP_Towers.LevelInfo0":
			Bot=Spawn(Class'TowersBot',,,Location);
			break;
			case "DXMP_Skyline.LevelInfo0":
			Bot=Spawn(Class'SkylineBot',,,Location);
			break;
			default:
		}
		Log("SummonBot - - Map has no bowen weapon info, aborting.");
	}
	else
	{
	}
	Bot.Controller=Controller;
	Destroy();
}