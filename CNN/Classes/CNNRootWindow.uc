class CNNRootWindow extends DeusExRootWindow;

// ----------------------------------------------------------------------
// InvokeMenuScreen()
//
// Invokes a menu Screen
// ----------------------------------------------------------------------

function DeusExBaseWindow InvokeMenuScreen(Class<DeusExBaseWindow> newScreen, optional bool bNoPause)
{
    local DeusExBaseWindow newWindow;

    // Check to see if a menu is visible.  If so, hide it first.
    if (( MenuUIMenuWindow(GetTopWindow()) != None ) || ( MenuUIScreenWindow(GetTopWindow()) != None ))
    {
        newWindow = PushWindow(newScreen, True, bNoPause);
    }
    else
    {
        newWindow = PushWindow(newScreen, False, bNoPause);
    }

    // Pause the game
    //if (!bNoPause)
    //    UIPauseGame();

    return newWindow;
}
