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
        foreach player.AllActors(class'CNNConversTrigger', _conTrig, conTrigTag)
        {
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
    }

    super.OnLoginAction();
}

function PlayBark()
{
    if (player != none && conTrig != none)
    {
        conTrig.Trigger(none, player);
    }
}

defaultproperties
{
    conTrigTag=CnnConversTriggerSeesUberAlles
}
