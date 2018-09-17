//=============================================================================
// CNNRandomSounds.
//=============================================================================
class CNNRandomSounds extends RandomSounds;

var() name StopSoundsFlag;
var DeusExPlayer player;

function Tick(float deltaTime)
{
    super.Tick(deltaTime);

    if (player != none && player.flagBase.GetBool(StopSoundsFlag))
    {
        bPlaying = false;
        AmbientSound = none;
        Disable('Tick');
    }
}

function PostBeginPlay()
{
    local DeusExPlayer dp;
    super.PostBeginPlay();
    player = DeusExPlayer(getPlayerPawn());

    foreach AllActors(class'DeusExPlayer', dp)
    {
        player = dp;
    }
}

defaultproperties
{
    StopSoundsFlag=StopFlag;
}
