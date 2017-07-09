//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ApocalypseInsideMenuSelectDifficulty expands MenuSelectDifficulty;

// ----------------------------------------------------------------------
// InvokeNewGameScreen()
// ----------------------------------------------------------------------

function InvokeNewGameScreen(float difficulty)
{
    local ApocalypseInsideMenuScreenNewGame newGame;
	//local MenuScreenNewGame newGame;

	//newGame = MenuScreenNewGame(root.InvokeMenuScreen(Class'MenuScreenNewGame'));
	newGame = ApocalypseInsideMenuScreenNewGame(
            root.InvokeMenuScreen(Class'ApocalypseInsideMenuScreenNewGame'));

	if (newGame != None)
		newGame.SetDifficulty(difficulty);
}

defaultproperties
{
}