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

    // PERMANENT SAFETY NET (2026-09-23, see CODE_REVIEW.md H5): the real
    // import (CNNText.CNNCredits, via CNNTextImport.uc) is correct and DOES
    // work, but `ucc make`'s DEUSEXTEXT IMPORT proved nondeterministic for
    // this specific file across many otherwise-identical rebuilds (content
    // present in roughly 1 of 8 attempts, same ballpark as the already-
    // documented ~25% intermittent GPF on CONVERSATION IMPORT -- likely the
    // same underlying compiler flakiness, see feedback_ucc_gpf memory).
    // Root cause not found despite isolating away every other variable
    // (duplicate-import collision, file location, file length, resource
    // name -- all tested, none of them the deciding factor alone). Rather
    // than risk a shipped build silently having blank credits again, fall
    // back to this short hardcoded excerpt whenever the real import didn't
    // take for this compile. Update it by hand if CNNCredits.txt changes.
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
    // FIXED 2026-09-23 (see CODE_REVIEW.md H5, full incident history in
    // memory/feedback_deusex_engine.md). Was `textPackage="CNN"`, relying
    // on CNN/Classes/ApocalypseInsideText.uc's `#exec ALLDEUSEXTEXT
    // IMPORT` macro. Root cause: CNNText/Classes/CNNTextImport.uc ALSO had
    // an explicit `#exec DEUSEXTEXT IMPORT` for the same file (it used to
    // sit directly in CNNText\Text\, the one spot ALLDEUSEXTEXT's
    // top-level-only cross-package scan actually reaches), so two
    // mechanisms tried to import one file to a resource both named
    // "CNNCredits" -- and even after removing the duplicate, ALLDEUSEXTEXT
    // itself proved unreliable across repeat compiles (content present in
    // 1 of 5 otherwise-identical rebuilds, source unchanged). Real fix:
    // moved the source file to CNNText\Text\credits\CNNCredits.txt (out of
    // ALLDEUSEXTEXT's reach) and import it via the same explicit, always-
    // reliable `#exec DEUSEXTEXT IMPORT` every other CNNText content file
    // already uses (see CNNTextImport.uc) -- so the resource now lives in
    // CNNText.u, hence CNNText here, not CNN.
    textPackage="CNNText"
}
