//=============================================================================
// AiHUDInfoLinkDisplay
//=============================================================================
class AiHUDInfoLinkDisplay expands HUDInfoLinkDisplay
	transient;

// this seems to have to be here to load the damn DefaultPortrait texture
//#exec OBJ LOAD FILE=InfoPortraits
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

	winName.SetText(displayName);

	// Default portrait name based on bind naem

	portraitStringName = "AiInfoPortraits." $ Left(bindName, 19);//16



	// Get a pointer to the portrait
	speakerPortrait = Texture(DynamicLoadObject(portraitStringName, class'Texture'));
}
