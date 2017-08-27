//=============================================================================
// AiHUDInfoLinkDisplay
//=============================================================================
class AiHUDInfoLinkDisplay expands HUDInfoLinkDisplay;
    //transient;

// this seems to have to be here to load the damn DefaultPortrait texture
#exec OBJ LOAD FILE=InfoPortraits
#exec OBJ LOAD FILE=AIInfoPortraits

// ----------------------------------------------------------------------
// SetSpeaker()
//
// Sets the speaker's name in the window and also the portrait
// displayed in the window
// ----------------------------------------------------------------------

function SetSpeaker(String bindName, String displayName)
{
    local String portraitStringName;
	local DeusExLevelInfo info;

    winName.SetText(displayName);

    // Default portrait name based on bind name

    // Hack!
    if (displayName == "Ada" || displayName == "Janus")
    {
        portraitStringName = "AiInfoPortraits." $ Left(bindName, 19);//16
    }
    else
    {
        portraitStringName = "InfoPortraits." $ Left(bindName, 19);//16
    }
	
	// Okay, we have a special case for Paul Denton who, like JC, 
	// has five different portraits based on what the player selected
	// when starting the game.  Therefore we have to pick the right
	// portrait.

	if (bindName == "PaulDenton")
		portraitStringName = portraitStringName $ "_" $ Chr(49 + player.PlayerSkin);

	// Another hack for Bob Page, to use a different portrait on Mission15.
	if (bindName == "BobPage")
	{
		info = player.GetLevelInfo();

		if ((info != None) && (info.MissionNumber == 15))
			portraitStringName = "InfoPortraits.BobPageAug";
	}

    // Get a pointer to the portrait
    speakerPortrait = Texture(DynamicLoadObject(portraitStringName, class'Texture'));
}
