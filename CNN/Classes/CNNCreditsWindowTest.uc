//=============================================================================
// CNNCreditsWindowTest
//=============================================================================
class CNNCreditsWindowTest extends CreditsScrollWindow;

var string textPackage;

var Texture CreditsBannerTextures[6];
var Texture TeamPhotoTextures[6];
var Float   creditsEndSoundLength;

// Easter egg processing
var String easterStrings[8];
var String foundStrings[8];
var String easterSearch;
var Int    easterPhraseIndex;
var Float  easterEggTimer;
var int    maxRandomPhrases;
var bool   bShowEasterPhrases;
var int    phraseCount;
var int    phraseIndex;

// Easter Egg Sounds
var Sound  EggBadLetterSounds[8];
var Sound  EggGoodLetterSounds[5];
var Sound  EggFoundSounds[3];

#exec DEUSEXTEXT IMPORT FILE=text\CNNCredits.txt

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
			InvokeQuotesWindow();
		}
	}

	if (bShowEasterPhrases)
	{
		easterEggTimer -= deltaTime;

		phraseCount = Rand(maxRandomPhrases);
		// Create a random number of phrases
		for(phraseIndex=0; phraseIndex<phraseCount; phraseIndex++)
			CreateEasterPhrase();

		if (easterEggTimer < 0.0)
		{
			bShowEasterPhrases = False;
			easterEggTimer = Default.easterEggTimer;
		}
	}
}

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

	// Check to see if the key entered is one of the 
	// easter egg phrases
	// 
	// First check to see if this is an alphanum character

	if (player.bCheatsEnabled)
	{
		if (((key >= "A") && (key <= "Z")) ||
		    ((key >= "a") && (key <= "z")) ||
		    ((key >= "0") && (key <= "9")))
		{
			bKeyHandled = True;

			// Convert lower-case to upper
			if ((key >= "a") && (key <= "z"))
				key = Chr(Asc(key) - 32);

			easterSearch = easterSearch $ key;

			// If this egg wasn't found *AND* the string is at 
			// least two characters found, then play a BZZT sound
			if (!ProcessEasterEgg())
			{
				// If the string is > 1 character, play a BZZT 
				// sound.
				if (Len(easterSearch) > 1)
				{
					// Play BZZT
					PlayEggBadLetter();
				}

				// Reset string
				easterSearch = "";
			}
		}
	}

	if (bKeyHandled)
		return True;
	else
		return Super.KeyPressed(key);
}

// ----------------------------------------------------------------------
// ProcessEasterEgg()
// ----------------------------------------------------------------------

function bool ProcessEasterEgg()
{
	local Int eggIndex;
	local bool bPartialPhrase;
	local bool bEggFound;

	bPartialPhrase = False;

	// Loop through all the eggs and see if we have a matching phrase
	for(eggIndex=0; eggIndex<arrayCount(easterStrings); eggIndex++)
	{
		if (easterstrings[eggIndex] == easterSearch)
		{
			EggFound(eggIndex);
			bEggFound = True;
			bPartialPhrase = False;
			break;
		}

		// Do a partial search
		if (InStr(easterStrings[eggIndex], easterSearch) != -1)
		{
			bPartialPhrase = True;
		}
	}

	// If this was a partial match, play a sound
	if (bPartialPhrase)
		PlayEggGoodLetter();

	return (bPartialPhrase || bEggFound);
}

// ----------------------------------------------------------------------
// EggFound()
// ----------------------------------------------------------------------

function EggFound(int eggIndex)
{
	PlayEggFoundSound();

	easterPhraseIndex  = eggIndex;
	bShowEasterPhrases = True;

	// Now act on the phrase
	if (easterSearch == "QUOTES")
	{
	player.PlaySound(sound'RocketIgnite', SLOT_None, 2.0,, 2048);
	}
	else if (easterSearch == "DANCEPARTY")
	{
	player.PlaySound(sound'RocketIgnite', SLOT_None, 2.0,, 2048);
	}
	else if (easterSearch == "THEREISNOSPOON")
	{
	player.PlaySound(sound'RocketIgnite', SLOT_None, 2.0,, 2048);
	}
	else if (easterSearch == "HUTHUT")
	{
	player.PlaySound(sound'RocketIgnite', SLOT_None, 2.0,, 2048);
	}
	else if (easterSearch == "BIGHEAD")
	{
	player.PlaySound(sound'RocketIgnite', SLOT_None, 2.0,, 2048);
	}
	else if (easterSearch == "IAMWARREN")
	{
	player.PlaySound(sound'RocketIgnite', SLOT_None, 2.0,, 2048);
	}
	else if (easterSearch == "UNATCOBORN")
	{
		player.ConsoleCommand("OPEN DXN");
	}

	easterSearch = "";
}

// ----------------------------------------------------------------------
// CreateEasterPhrase()
// ----------------------------------------------------------------------

function CreateEasterPhrase()
{
	local FadeTextWindow winFade;

	winFade = FadeTextWindow(NewChild(Class'FadeTextWindow'));
	winFade.SetText(foundStrings[easterPhraseIndex]);
	winFade.SetPos(Rand(width) - Rand(100), Rand(height));
}

// ----------------------------------------------------------------------
// PlayEggFoundSound()
// ----------------------------------------------------------------------

function PlayEggFoundSound()
{
	// Temporary
	player.PlaySound(EggFoundSounds[Rand(ArrayCount(EggFoundSounds))]);
}

// ----------------------------------------------------------------------
// PlayEggGoodLetter()
// ----------------------------------------------------------------------

function PlayEggGoodLetter()
{
	// Temporary
	player.PlaySound(EggGoodLetterSounds[Rand(ArrayCount(EggGoodLetterSounds))]);
}

// ----------------------------------------------------------------------
// PlayEggBadLetter()
// ----------------------------------------------------------------------

function PlayEggBadLetter()
{
	// Temporary
	player.PlaySound(EggBadLetterSounds[Rand(ArrayCount(EggBadLetterSounds))]);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    TextPackage="CNN"
    CreditsBannerTextures(0)=Texture'UserInterface.DXNBanner1'
    CreditsBannerTextures(1)=Texture'UserInterface.DXNBanner2'
    TeamPhotoTextures(0)=Texture'UserInterface.DXNLowBanner1'
    TeamPhotoTextures(1)=Texture'UserInterface.DXNLowBanner2'
    TeamPhotoTextures(2)=Texture'UserInterface.DXNLowBanner3'
    creditsEndSoundLength=4.00
    easterStrings(0)="QUOTES"
    easterStrings(1)="DANCEPARTY"
    easterStrings(2)="THEREISNOSPOON"
    easterStrings(3)="HUTHUT"
    easterStrings(4)="BIGHEAD"
    easterStrings(5)="IAMWARREN"
    easterStrings(6)="MOREFROGS"
    easterStrings(7)="UNATCOBORN"
    foundStrings(0)="NO!"
    foundStrings(1)="NEIN!"
    foundStrings(2)="NYET!"
    foundStrings(3)="NEJ!"
    foundStrings(4)="EI!"
    foundStrings(5)="IIE!"
    foundStrings(6)="NICE TRY, DODONGO"
    foundStrings(7)="UNATCO BORN"
    easterEggTimer=3.00
    maxRandomPhrases=5
    EggBadLetterSounds(0)=Sound'DeusExSounds.Generic.Buzz1'
    EggBadLetterSounds(1)=Sound'DeusExSounds.Generic.LargeExplosion1'
    EggBadLetterSounds(2)=Sound'DeusExSounds.Generic.GlassBreakLarge'
    EggBadLetterSounds(3)=Sound'DeusExSounds.Generic.SplashLarge'
    EggBadLetterSounds(4)=Sound'DeusExSounds.Animal.CatDie'
    EggBadLetterSounds(5)=Sound'DeusExSounds.NPC.ChildDeath'
    EggBadLetterSounds(6)=Sound'DeusExSounds.Special.FlushToilet'
    EggGoodLetterSounds(0)=Sound'DeusExSounds.Generic.KeyboardClick1'
    EggGoodLetterSounds(1)=Sound'DeusExSounds.Generic.KeyboardClick2'
    EggGoodLetterSounds(2)=Sound'DeusExSounds.Generic.KeyboardClick1'
    EggGoodLetterSounds(3)=Sound'DeusExSounds.Generic.KeyboardClick2'
    EggGoodLetterSounds(4)=Sound'DeusExSounds.Generic.KeyboardClick3'
    EggFoundSounds(0)=Sound'DeusExSounds.Special.Airplane2'
    EggFoundSounds(1)=Sound'DeusExSounds.Generic.Beep2'
    EggFoundSounds(2)=Sound'DeusExSounds.Generic.Foghorn'
	ScrollMusicString="Credits_Music.Credits_Music"
    textName=CNNCredits
}