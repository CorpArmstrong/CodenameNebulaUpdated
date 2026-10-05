//=============================================================================
// CNNMissionEndgame.
//=============================================================================
class CNNMissionEndgame extends MissionEndgame;

// The inherited quote table holds three endings; Hijacking is the fourth.
var localized string hijackQuote[2];
var float hijackDelay;

// Do nothing!
function ExplosionEffects() {}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
    local string mapName;
    local int quoteIndex;

    super.Timer();

    if (!bQuotePrinted)
    {
        // The quote follows the ending map. The ending maps all carry
        // MapName "MUTINY", so the loaded map's file name is used instead,
        // and the level info is corrected to match.
        mapName = Caps(Level.Game.GetURLMap());

        if (dxInfo != None)
            dxInfo.mapName = mapName;

        if (InStr(mapName, "HIJACK") != -1)
        {
            PrintHijackQuote();
        }
        else
        {
            if (InStr(mapName, "CONSPIRACY") != -1)
                quoteIndex = 0;
            else if (InStr(mapName, "MUTINY") != -1)
                quoteIndex = 1;
            else if (InStr(mapName, "TRANSCEND") != -1)
                quoteIndex = 2;
            else
                quoteIndex = 0;

            PrintEndgameQuote(quoteIndex);
        }
    }

    endgameTimer += checkTime;

	if (endgameTimer > endgameDelays[0])
    {
        FinishCinematic();
    }
}

// ----------------------------------------------------------------------
// PrintHijackQuote()
//
// Same as PrintEndgameQuote(), for the quote that has no slot in the
// inherited table.
// ----------------------------------------------------------------------

function PrintHijackQuote()
{
    local int i;
    local DeusExRootWindow root;

    bQuotePrinted = True;
    flags.SetBool('EndgameExplosions', False);

    root = DeusExRootWindow(Player.rootWindow);
    if (root == None)
        return;

    quoteDisplay = HUDMissionStartTextDisplay(root.NewChild(Class'HUDMissionStartTextDisplay', True));
    if (quoteDisplay == None)
        return;

    quoteDisplay.displayTime = hijackDelay;
    quoteDisplay.SetWindowAlignments(HALIGN_Center, VALIGN_Center);

    for (i = 0; i < 2; i++)
        quoteDisplay.AddMessage(hijackQuote[i]);

    quoteDisplay.StartMessage();
}

defaultproperties
{
    hijackQuote(0)="TO STRIVE, TO SEEK, TO FIND, AND NOT TO YIELD."
    hijackQuote(1)="    -- ULYSSES, ALFRED, LORD TENNYSON"
    hijackDelay=13.000000

    endgameDelays(0)=13.000000
    endgameDelays(1)=13.500000
    endgameDelays(2)=10.500000
    endgameQuote(0)="UNDER THE BURNING SUN I TAKE A LOOK AROUND, IMAGINE IF THIS ALL CAME DOWN, I'M WAITING FOR THE DAY TO COME."
    endgameQuote(1)="    -- OBLIVION, 30 SECONDS TO MARS"
    endgameQuote(2)="AND NOW YOU'VE BECOME A PART OF ME, YOU'LL ALWAYS BE RIGHT HERE, I CAN'T SEPARATE MYSELF FROM WHAT I'VE DONE, GIVING UP A PART OF ME I LET MYSELF BECOME YOU."
    endgameQuote(3)="    --  FIGURE 09, LINKIN PARK"
    endgameQuote(4)="DO YOU LIVE, DO YOU DIE, DO YOU BLEED FOR THE FANTASY? IN YOUR MIND, THROUGH YOUR EYES DO YOU SEE? IT'S A FANTASY, AUTOMATIC, I IMAGINE, I BELIEVE."
    endgameQuote(5)="    -- THE FANTASY, 30 SECONDS TO MARS"
}
