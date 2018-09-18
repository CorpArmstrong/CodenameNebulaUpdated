//-----------------------------------------------------------
// CNNNetworkTerminalSecurity
//-----------------------------------------------------------
class CNNNetworkTerminalSecurity extends CNNNetworkTerminalSecurityBase;

var() name conTrigTag;

var DeusExPlayer player;
var CNNConversTrigger conTrig;

var() name conversationTag;

event InitWindow()
{
    local CNNConversTrigger _conTrig;
    super.InitWindow();

    player = DeusExPlayer(GetPlayerPawn());

    if (player != none)
    {
        player.BroadcastMessage("Player found!");

        foreach player.AllActors(class'CNNConversTrigger', _conTrig, conTrigTag)
        {
            player.BroadcastMessage("ConTrig found!");
            conTrig = _conTrig;
            break;
        }
    }
}

function OnLoginAction()
{
    if (!AreSpecialOptionsAvailable(true))
    {
        PlayBark();
        player.BroadcastMessage("After triggering conversation!");
    }

    super.OnLoginAction();
}

function PlayBark()
{
    if (player != none && conTrig != none)
    {
        player.BroadcastMessage("Triggering conversation!");
        conTrig.Trigger(none, player);
    }
}

defaultproperties
{
    conTrigTag=CnnConversTriggerSeesUberAlles
}
