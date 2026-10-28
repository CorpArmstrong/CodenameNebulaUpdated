//=============================================================================
// CNNCreditsWindow
//=============================================================================
class CNNCreditsWindow extends CreditsWindow;

var string textPackage;
var bool bLeaving;

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
        parser = new(none) Class'DeusExTextParser';

        // Attempt to find the text object
        if (parser.OpenText(textName, textPackage))
        {
            while(parser.ProcessText())
            {
                ProcessTextTag(parser);
            }

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

// ----------------------------------------------------------------------
// FinishedScrolling()
//
// The credits stay on screen while the menu map loads. Closing them first
// (root.PopWindow) turns rendering back on, and the map they ran over --
// the endgame -- showed for the second or two the load takes.
// TantalusDenton.Possess closes them on the menu map. A click and ESC end
// the credits the same way.
// ----------------------------------------------------------------------

function FinishedScrolling()
{
    LeaveToMenuMap();
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
    if (key == IK_Escape)
    {
        LeaveToMenuMap();
        return true;
    }
    return Super.VirtualKeyPressed(key, bRepeat);
}

function LeaveToMenuMap()
{
    if (bLeaving)
        return;
    bLeaving = true;
    bScrolling = false;
    bTickEnabled = false;
    player.Level.Game.SendPlayer(player, "cnnentry");
}

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

event DestroyWindow()
{
    bLoadIntro = false;
    // closed some other way than the above
    if (!bLeaving)
    {
        bLeaving = true;
        player.Level.Game.SendPlayer(player, "cnnentry");
    }
    super.DestroyWindow();
}

defaultproperties
{
    CreditsBannerTextures(0)=Texture'CNN.codenamenebula_credits'
    TeamPhotoTextures(0)=Texture'CNN.Photos.ChesterBennington'
    creditsEndSoundLength=4.000000
    ScrollMusicString="" // Don't use vanilla music in credits
    textName=CNNCredits
    textPackage="CNN"
}
