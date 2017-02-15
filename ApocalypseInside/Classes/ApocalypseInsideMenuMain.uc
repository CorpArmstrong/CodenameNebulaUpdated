class ApocalypseInsideMenuMain expands MenuMain;
// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

/*var MenuUIMenuButtonWindow winButtons[8];   // Up to ten buttons

// Array of button text
var localized string ButtonNames[8];      */


event InitWindow()
{
	Super.InitWindow();

	UpdateButtonStatus();
	ShowVersionInfo();
}

// ----------------------------------------------------------------------
// UpdateButtonStatus()
// ----------------------------------------------------------------------

function UpdateButtonStatus()
{
	local DeusExLevelInfo info;

	info = player.GetLevelInfo();

	// Disable the "Save Game" and "Back to Game" menu choices
	// if the player's dead or we're on the logo map.
	//
	// Also don't allow the user to save if a DataLink is playing

   // Don't disable in mp if dead.

	if (((info != None) && (info.MissionNumber < 0)) ||
	   ((player.IsInState('Dying')) || (player.IsInState('Paralyzed')) || (player.IsInState('Interpolating'))))
	{
      if (Player.Level.NetMode == NM_Standalone)
      {
         winButtons[1].SetSensitivity(False);
         winButtons[7].SetSensitivity(False);
      }
   }

   // Disable the "Save Game", "New Game", "Intro", "Training" and "Load Game" menu choices if in multiplayer
   if (player.Level.Netmode != NM_Standalone)
   {
      winButtons[0].SetSensitivity(False);
      winButtons[1].SetSensitivity(False);
      winButtons[2].SetSensitivity(False);
      winButtons[4].SetSensitivity(False);
      winButtons[5].SetSensitivity(False);
   }

	// Don't allow saving if a datalink is playing
	if (player.dataLinkPlay != None)
		winButtons[1].SetSensitivity(False);

	// DEUS_EX_DEMO - Uncomment when building demo
	//
	// Disable the "Play Intro" button for the demo
//	winButtons[5].SetSensitivity(False);
}

// ----------------------------------------------------------------------
// ShowVersionInfo()
// ----------------------------------------------------------------------

function ShowVersionInfo()
{
	local TextWindow version;

	version = TextWindow(NewChild(Class'TextWindow'));
	version.SetTextMargins(0, 0);
	version.SetWindowAlignments(HALIGN_Right, VALIGN_Bottom);
	version.SetTextColorRGB(255, 255, 255);
	version.SetTextAlignments(HALIGN_Right, VALIGN_Bottom);
	version.SetText(player.GetDeusExVersion());
}


// ----------------------------------------------------------------------
// StartNewGame()
// ----------------------------------------------------------------------

function StartNewGame()
{
    root.InvokeMenuScreen(Class'ApocalypseInsideMenuSelectDifficulty');
}
// ----------------------------------------------------------------------

defaultproperties
{
    ButtonNames(0)="New Game"
    ButtonNames(1)="Save Game"
    ButtonNames(2)="Load Game"
    ButtonNames(3)="Settings"
    ButtonNames(4)="Codename Nebula" //was Training
    ButtonNames(5)="Mise En Abyme"  //was play intro
    ButtonNames(6)="Credits"
    ButtonNames(7)="Back to Game"
    ButtonNames(8)="Multiplayer"
    ButtonNames(9)="Exit"
    buttonXPos=7
    buttonWidth=245
    //buttonDefaults(0)=(Y=13,Action=3,Invoke=None,Key=""),
    buttonDefaults(0)=(Y=13,Action=MA_NewGame,Invoke=Class'ApocalypseInsideMenuSelectDifficulty',Key=""),
    buttonDefaults(1)=(Y=49,Action=1,Invoke=Class'MenuScreenSaveGame',Key=""),
    buttonDefaults(2)=(Y=85,Action=1,Invoke=Class'MenuScreenLoadGame',Key=""),
    buttonDefaults(3)=(Y=121,Action=0,Invoke=Class'MenuSettings',Key=""),
    buttonDefaults(4)=(Y=157,Action=1,Invoke=None,Key=""),
    buttonDefaults(5)=(Y=193,Action=1,Invoke=Class'ComputerScreenLogin',Key=""),
    buttonDefaults(6)=(Y=229,Action=1,Invoke=Class'CreditsWindow',Key=""),
    buttonDefaults(7)=(Y=265,Action=2,Invoke=None,Key=""),
    buttonDefaults(8)=(Y=301,Action=1,Invoke=Class'menumpmain',Key=""),
    buttonDefaults(9)=(Y=359,Action=6,Invoke=None,Key=""),
    Title="Welcome to Apocalypse Inside"
    ClientWidth=258
    ClientHeight=400
    verticalOffset=2
    clientTextures(0)=Texture'DeusExUI.MenuMainBackground_1_unscaled'
    clientTextures(1)=Texture'DeusExUI.MenuMainBackground_2_unscaled'
    clientTextures(2)=Texture'DeusExUI.MenuMainBackground_3_unscaled'
    textureCols=2
}
