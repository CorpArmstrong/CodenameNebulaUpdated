//-----------------------------------------------------------
// CNNNetworkTerminalSecurityBase
//-----------------------------------------------------------
class CNNNetworkTerminalSecurityBase extends NetworkTerminal;

function CloseScreen(String action)
{
	super.CloseScreen(action);

    switch(action)
    {
        case "LOGOUT":
            OnLogoutAction();
            break;

        case "LOGIN":
            OnLoginAction();
            break;

        case "RETURN":
            OnReturnAction();
            break;

        case "SPECIAL":
            OnSpecialAction();
            break;
    }
}

function OnLoginAction()
{
    // Check to see if there are any "special options" the player
    // has not yet invoked, in which case we want to jump straight
    // to the special options screen (oh boy, "special" cases!)
    if (AreSpecialOptionsAvailable(true))
    {
        ShowScreen(Class'ComputerScreenSpecialOptions');
    }
    else
    {
        ShowScreen(Class'ComputerScreenSecurity');
    }
}

function OnLogoutAction()
{
    // If we're hacked into the computer, then exit completely.
    if (bHacked)
    {
        CloseScreen("EXIT");
    }
    else
    {
        ShowScreen(FirstScreen);
    }
}

function OnReturnAction()
{
    ShowScreen(Class'ComputerScreenSecurity');
}

function OnSpecialAction()
{
    ShowScreen(Class'ComputerScreenSpecialOptions');
}

defaultproperties
{
    FirstScreen=Class'DeusEx.ComputerScreenLogin'
}
