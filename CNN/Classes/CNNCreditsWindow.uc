//=============================================================================
// CNNCreditsWindow
//=============================================================================
class CNNCreditsWindow extends CreditsWindow;

var string textPackage;

// ----------------------------------------------------------------------
// ProcessText()
// ----------------------------------------------------------------------

function ProcessText()
{
    local DeusExTextParser parser;

	PrintPicture(CreditsBannerTextures, 1, 1, 512, 64);
    PrintLn();

    // First check to see if we have a name
    if (textName != '')
    {
        // Create the text parser
        parser = new(None) Class'DeusExTextParser';

        // Attempt to find the text object
        if (parser.OpenText(textName, textPackage))
        {
            while(parser.ProcessText())
                ProcessTextTag(parser);

            parser.CloseText();
        }

		CriticalDelete(parser);
	}

    ProcessFinished();
}

// ----------------------------------------------------------------------
// ProcessFinished()
// ----------------------------------------------------------------------

function ProcessFinished()
{
	PrintLn();
	PrintPicture(TeamPhotoTextures, 1, 1, 256, 256);
}

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

event DestroyWindow()
{
    bLoadIntro = false;
    player.Level.Game.SendPlayer(player, "cnnentry");
    
	Super.DestroyWindow();
}

defaultproperties
{
	CreditsBannerTextures(0)=Texture'CNN.codenamenebula_credits'
	TeamPhotoTextures(0)=Texture'CNN.chester_credits'
	creditsEndSoundLength=4.000000
    ScrollMusicString=""
    // Don't use vanilla music in credits
    //ScrollMusicString="Credits_Music.Credits_Music"
	textName=CNNCredits
	textPackage="CNN"
}
