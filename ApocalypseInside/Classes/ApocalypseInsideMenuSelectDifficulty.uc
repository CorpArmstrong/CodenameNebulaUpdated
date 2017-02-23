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
    ButtonNames(0)="Tell me a story"
    ButtonNames(1)="Give me a challenge"
    ButtonNames(2)="Give me Deus Ex"
    ButtonNames(3)="Give me more Deus Ex"
    ButtonNames(4)="Previous Menu"
    buttonXPos=14
    buttonWidth=490
    buttonDefaults(0)=(Y=26,Action=7,Invoke=None,Key="EASY"),
    buttonDefaults(1)=(Y=98,Action=7,Invoke=None,Key="MEDIUM"),
    buttonDefaults(2)=(Y=170,Action=7,Invoke=None,Key="HARD"),
    buttonDefaults(3)=(Y=242,Action=7,Invoke=None,Key="REALISTIC"),
    buttonDefaults(4)=(Y=358,Action=2,Invoke=None,Key=""),
    Title="Select Combat Difficulty"
    ClientWidth=516
    ClientHeight=442
    clientTextures(0)=Texture'DeusExUI.UserInterface.MenuDifficultyBackground_1'
    clientTextures(1)=Texture'DeusExUI.UserInterface.MenuDifficultyBackground_2'
    textureRows=1
    textureCols=2