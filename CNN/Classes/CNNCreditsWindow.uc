//=============================================================================
// CNNCreditsWindow
//=============================================================================
class CNNCreditsWindow extends CreditsWindow;
/*
var string textPackage;

// ----------------------------------------------------------------------
// ProcessText()
// ----------------------------------------------------------------------

function ProcessText()
{
    local DeusExTextParser parser;

    PrintPicture(CreditsBannerTextures, 2, 1, 505, 75);
    PrintLn();

    // First check to see if we have a name
    if (textName != '')
    {
        // Create the text parser
        parser = new(None) Class'DeusExTextParser';

        // Attempt to find the text object
        if (parser.OpenText(textName,textPackage))
        {
            while(parser.ProcessText())
                ProcessTextTag(parser);

            parser.CloseText();
        }

    CriticalDelete(parser);
    }

    ProcessFinished();
}
*/

defaultproperties
{ 
	CreditsBannerTextures(0)=Texture'CNN.codenamenebula'
	CreditsBannerTextures(1)=none
    //CreditsBannerTextures(0)=Texture'DeusExUI.UserInterface.CreditsBanner_1'
    //CreditsBannerTextures(1)=Texture'DeusExUI.UserInterface.CreditsBanner_2'
    TeamPhotoTextures(0)=Texture'DeusExUI.UserInterface.TeamFront_1'
    TeamPhotoTextures(1)=Texture'DeusExUI.UserInterface.TeamFront_2'
    TeamPhotoTextures(2)=Texture'DeusExUI.UserInterface.TeamFront_3'
    creditsEndSoundLength=4.000000
    maxRandomPhrases=5
    ScrollMusicString="Credits_Music.Credits_Music"
	textName=CNNCredits
    //textPackage=CNN
} 
