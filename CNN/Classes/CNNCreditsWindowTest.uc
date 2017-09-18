//=============================================================================
// CNNCreditsWindowTest
//=============================================================================
class CNNCreditsWindowTest extends CreditsScrollWindow;

var string textPackage;

var Texture CreditsBannerTextures[6];
var Texture TeamPhotoTextures[6];
var Float   creditsEndSoundLength;

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
		Log("CNN Inside ProcessText!");
        // Create the text parser
        parser = new(None) Class'DeusExTextParser';

        // Attempt to find the text object
        if (parser.OpenText(textName,textPackage))
        {
			Log("CNN Inside Parser.OpenText()!");
            
			while(parser.ProcessText())
			{
				Log("CNN Inside Parser.ProcessText() Iteration!");
                ProcessTextTag(parser);
			}
			
            parser.CloseText();
        }
		else
		{
			Log("Can't open credits text!");
		}

		CriticalDelete(parser);
    }

    ProcessFinished();
}

// ----------------------------------------------------------------------
// ProcessTextTag()
// ----------------------------------------------------------------------

function ProcessTextTag(DeusExTextParser parser)
{
	local String text;
	local byte tag;
	local Name fontName;
	local String textPart;
	local String fileStringName;
	local String fileStringDesc;

	tag  = parser.GetTag();

	Log("CNN Inside ProcessTextTag()! byte = " $ tag);
	
	switch(tag)
	{
		case 0:				// TT_Text:
			text = parser.GetText();

			if (text == "")
			{
				Log("CNN Empty text?");
				PrintLn();
			}
			else
			{
				Log("CNN Processing text: " $ parser.GetText());
				Log("CNN Text 2: " $ text);
				Log("CNN after text!");
				
				if (bBold)
				{
					bBold = False;
					PrintHeader(parser.GetText());
				}
				else
				{
					PrintText(parser.GetText());
				}
			}
			break;

		case 1:				// TT_File (graphic, baby!)
			parser.GetFileInfo(fileStringName, fileStringDesc);
//			PrintGraphic(Texture(DynamicLoadObject(fileStringName, Class'Texture')));
			break;

		// Bold
		case 19:	// header
			bBold = True;
			break;

		case 13:				// TT_LeftJustify:
			break;

		case 12:				// TT_CenterText:
			break;
	}
}

// ----------------------------------------------------------------------
// ProcessFinished()
// ----------------------------------------------------------------------

function ProcessFinished()
{
	PrintLn();
	PrintPicture(TeamPhotoTextures, 3, 1, 600, 236);
	Super.ProcessFinished();
}

// ----------------------------------------------------------------------
// FinishedScrolling()
// ----------------------------------------------------------------------

function FinishedScrolling()
{
	if (player.bQuotesenabled)
	{
		// Shut down the music
//		player.ClientSetMusic(player.Level.Song, savedSongSection, 255, MTRAN_FastFade);
		player.PlaySound(Sound'CreditsEnd');
	}
	else
	{
		Super.FinishedScrolling();
	}
}

// ----------------------------------------------------------------------
// Tick()
// ----------------------------------------------------------------------

function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	if (!bScrolling)
	{
		creditsEndSoundLength -= deltaTime;

		if (creditsEndSoundLength < 0.0)
		{
			bTickEnabled = False;
			//InvokeQuotesWindow();
		}
	}
}

/*
// ----------------------------------------------------------------------
// InvokeQuotesWindow()
// ----------------------------------------------------------------------

function InvokeQuotesWindow()
{
	local QuotesWindow winQuotes;

	// Check to see if the 
	if (player.bQuotesEnabled)
	{
		winQuotes = QuotesWindow(root.InvokeMenuScreen(Class'QuotesWindow'));
		winQuotes.SetLoadIntro(bLoadIntro);
		winQuotes.SetClearStack(True);
	}
}
*/

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

event DestroyWindow()
{
	// Check to see if we need to load the intro
	if (bLoadIntro)
	{
		player.Level.Game.SendPlayer(player, "dxonly");
	}

	Super.DestroyWindow();
}

// ----------------------------------------------------------------------
// KeyPressed() 
// ----------------------------------------------------------------------

event bool KeyPressed(string key)
{
	local bool bKeyHandled;

	if (IsKeyDown(IK_Alt))
		return False;

	if (bKeyHandled)
		return True;
	else
		return Super.KeyPressed(key);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
	CreditsBannerTextures(0)=Texture'CNN.codenamenebula'
    CreditsBannerTextures(1)=Texture'CNN.codenamenebula'
     //CreditsBannerTextures(0)=Texture'DeusExUI.UserInterface.CreditsBanner_1'
     //CreditsBannerTextures(1)=Texture'DeusExUI.UserInterface.CreditsBanner_2'
     TeamPhotoTextures(0)=Texture'CNN.chester'
	 TeamPhotoTextures(1)=Texture'CNN.chester'
	 TeamPhotoTextures(2)=Texture'CNN.chester'
	 //TeamPhotoTextures(0)=Texture'DeusExUI.UserInterface.TeamFront_1'
     //TeamPhotoTextures(1)=Texture'DeusExUI.UserInterface.TeamFront_2'
     //TeamPhotoTextures(2)=Texture'DeusExUI.UserInterface.TeamFront_3'
     creditsEndSoundLength=4.000000
     ScrollMusicString="Credits_Music.Credits_Music"
     textName=CNNCredits
	 textPackage="CNN"
}
