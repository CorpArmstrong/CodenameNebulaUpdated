//=============================================================================
// ApocalypseInsideMenuUIWindow
//
// Base class for the Menu windows
//=============================================================================

class ApocalypseInsideMenuUIWindow extends MenuUIWindow
	abstract;

// ----------------------------------------------------------------------
// StartNewGame()
// ----------------------------------------------------------------------

function StartNewGame()
{
	// Check to see if the player has already ran the training mission
	// or been prompted
	if (player.bAskedToTrain == False)
	{
		messageBoxMode = MB_AskToTrain;
		player.bAskedToTrain = True;		// Only prompt ONCE!
		player.SaveConfig();
		root.MessageBox(AskToTrainTitle, AskToTrainMessage, 0, False, Self);
	}
	else
	{
		//root.InvokeMenuScreen(Class'MenuSelectDifficulty');
		root.InvokeMenuScreen(Class'ApocalypseInsideMenuSelectDifficulty');
	}
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------

event bool BoxOptionSelected(Window button, int buttonNumber)
{
	// Destroy the msgbox!
	root.PopWindow();

	switch(messageBoxMode)
	{
		case MB_Exit:
			if ( buttonNumber == 0 )
			{
				/* TODO: This is what Unreal Does,
				player.SaveConfig();
				if ( Level.Game != None )
					Level.Game.SaveConfig();
				*/

				root.ExitGame();
			}
			break;

		case MB_AskToTrain:
			if (buttonNumber == 0)
				player.StartTrainingMission();
			else
				//root.InvokeMenuScreen(Class'MenuSelectDifficulty');
			    root.InvokeMenuScreen(Class'ApocalypseInsideMenuSelectDifficulty');
			break;

		case MB_Training:
			if (buttonNumber == 0)
				player.StartTrainingMission();
			break;

		case MB_Intro:
			if (buttonNumber == 0)
				player.ShowIntro();
			break;

		case MB_JoinGameWarning:
			if (buttonNumber == 0)
			{
			/*
				if (Self.IsA('MenuScreenJoinGame'))
					MenuScreenJoinGame(Self).RefreshServerList();
			*/ // Commented! 15.08.2015
			}

			break;
	}

	return true;
}


defaultproperties
{
    ExitMessage="There is no wrong choice. Are you sure you want to exit |nApocalypse Inside?"
}
