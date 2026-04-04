//=============================================================================
// ApocalypseInsideMenuStartNewGame.uc
//=============================================================================

class ApocalypseInsideMenuStartNewGame expands MenuUIMenuWindow;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
}

// ----------------------------------------------------------------------
// WindowReady()
// ----------------------------------------------------------------------

event WindowReady()
{
	// Set focus to the Medium button
	SetFocusWindow(winButtons[1]);
}

// ----------------------------------------------------------------------
// ProcessCustomMenuButton()
// ----------------------------------------------------------------------

function ProcessCustomMenuButton(string key)
{
	switch(key)
	{
		case "STARTCNN":
			ApocalypseInsideGo();
			break;
	}
}

// ----------------------------------------------------------------------
// ApocalypseInsideGo()
// ----------------------------------------------------------------------

function ApocalypseInsideGo()
{
	local DeusExPlayer	localPlayer;
	local String		localStartMap;
	local String		playerName;

	localPlayer = player;
	localPlayer.ShowIntro(True);
}

defaultproperties
{
    ButtonNames(0)="Begin"
    ButtonNames(1)="Previous Menu"
    buttonXPos=7
    buttonWidth=245
    buttonDefaults(0)=(Y=13,Action=MA_Custom,Key="STARTCNN")
    buttonDefaults(1)=(Y=49,Action=MA_Previous)
}
