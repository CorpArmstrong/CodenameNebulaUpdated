class CNNMenuMainTest expands MenuMain;

// ----------------------------------------------------------------------
// StartNewGame()
// ----------------------------------------------------------------------

function StartNewGame()
{
    root.InvokeMenuScreen(Class'CNN.ApocalypseInsideMenuSelectDifficulty');
}

defaultproperties
{
    Title="Welcome to Codename Nebula v1.11"
    buttonDefaults(0)=(Y=13,Action=MA_NewGame,Invoke=Class'CNN.ApocalypseInsideMenuSelectDifficulty')
    buttonDefaults(6)=(Y=229,Action=MA_MenuScreen,Invoke=Class'CNN.CNNCreditsWindow')
    clientTextures(0)=Texture'DeusExUI.MenuMainBackground_1_unscaled'
    clientTextures(1)=Texture'DeusExUI.MenuMainBackground_2_unscaled'
    clientTextures(2)=Texture'DeusExUI.MenuMainBackground_3_unscaled'
}
