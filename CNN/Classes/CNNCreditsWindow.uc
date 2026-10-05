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
    local bool bGotText;

    PrintPicture(CreditsBannerTextures, 1, 1, 512, 64);
    PrintLn();

    // First check to see if we have a name
    if (textName != '')
    {
        // Create the text parser
        parser = new(none) Class'DeusExTextParser';

        // Attempt to find the text object
        if (parser.OpenText(textName, textPackage))
        {
            bGotText = true;

            while(parser.ProcessText())
            {
                ProcessTextTag(parser);
            }

            parser.CloseText();
        }

        CriticalDelete(parser);
    }

    // ucc sometimes builds CNNText without the credits text; fall back to
    // this short excerpt then. Keep it in step with CNNCredits.txt.
    if (!bGotText)
    {
        PrintHeader("Dev Team:");
        PrintLn();
        PrintText("Artem Tantalus D");
        PrintText("Project director, Lead Writer, Level Designer, Texture Designer, Programmer, Soundtrack");
        PrintLn();
        PrintText("Dmitriy CorpArmstrong Fedykovych");
        PrintText("Assistant director, Lead Programmer, Assistant Writer, Level Designer, Soundtrack");
        PrintLn();
        PrintText("Evgeniy JJoe Bortnik");
        PrintText("Programmer, 3D Modeller, Level Designer");
        PrintLn();
        PrintText("Andrievskaya Veronika");
        PrintText("Level design, consultant");
        PrintLn();
        PrintText("Pavel Marianenko");
        PrintText("Writer, game design, game test");
        PrintLn();
        PrintText("Pavel Mosunov");
        PrintText("Additional 3D modelling");
        PrintLn();
        PrintText("Max Yakimenko");
        PrintText("Sound design");
        PrintLn();
        PrintText("Vladyslav Pr0r0k Martens");
        PrintText("Installer fixes and game test");
        PrintLn();
        PrintText("Artem Dubson");
        PrintText("Additional 3D modelling");
        PrintLn();
        PrintLn();
        PrintText("In memory of Chester Bennington (1976-2017)");
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
    super.DestroyWindow();
}

defaultproperties
{
    CreditsBannerTextures(0)=Texture'CNN.codenamenebula_credits'
    TeamPhotoTextures(0)=Texture'CNN.chester_credits'
    creditsEndSoundLength=4.000000
    ScrollMusicString="" // Don't use vanilla music in credits
    textName=CNNCredits
    textPackage="CNNText"
}
