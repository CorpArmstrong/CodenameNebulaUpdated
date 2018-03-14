//=============================================================================
// CNNRandomSounds.
//=============================================================================
class CNNRandomSounds expands RandomSounds;

var() name StopSoundsFlag;
var DeusExPlayer player;

function Tick(float deltaTime)
{
	Super.Tick(deltaTime);
	
	if(player != none && player.flagBase.GetBool(StopSoundsFlag)) {
		bPlaying = False;
		AmbientSound = None;
		//BroadcastMessage("Stopped sound...");
		Disable('Tick');
	}
}

function PostBeginPlay()
{
	local DeusExPlayer dp;
	Super.PostBeginPlay();
	player = DeusExPlayer(getPlayerPawn());
	foreach AllActors(class'DeusExPlayer', dp){
		player = dp;
		//BroadcastMessage("Player found");
	}
}

defaultproperties
{
	StopSoundsFlag=StopFlag;
}

