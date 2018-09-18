//-----------------------------------------------------------
// CNNRootWindow
//-----------------------------------------------------------
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
    if ((MenuUIMenuWindow(GetTopWindow()) != none ) ||
        (MenuUIScreenWindow(GetTopWindow()) != none ))
    {
        newWindow = PushWindow(newScreen, true, bNoPause);
    }
    else
    {
        newWindow = PushWindow(newScreen, false, bNoPause);
    }

    // Pause the game
    //if (!bNoPause)
    //    UIPauseGame();

    return newWindow;
}
