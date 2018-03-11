class CNNNetworkTerminalSecurity extends CNNNetworkTerminalSecurityBase;

var() name dispatcherTag;

var DeusExPlayer player;
var Dispatcher disp;

var() name conversationTag;

event InitWindow()
{
    local Dispatcher _disp;
    super.InitWindow();

    player = DeusExPlayer(GetPlayerPawn());
    
    if (player != none)
    {
        player.BroadcastMessage("Player found!");
        foreach player.AllActors(class'Dispatcher', _disp, dispatcherTag)
        {
            player.BroadcastMessage("Dispatcher found!");
            disp = _disp;
            break;
        }
    }
}

function OnLoginAction()
{
    if (!AreSpecialOptionsAvailable(true))
    {
        PlayBark();
        player.BroadcastMessage("After triggering dispatcher!");
    }

    super.OnLoginAction();
}

function PlayBark()
{
    if (player != none && disp != none)
    {
        player.BroadcastMessage("Triggering dispatcher!");
        disp.Trigger(none, player);
    }
}

DefaultProperties
{
    dispatcherTag=DispatcherUberAlles
}