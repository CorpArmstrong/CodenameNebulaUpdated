//=============================================================================
// CNNMissionEndgame.
//=============================================================================
class CNNMissionEndgame extends MissionEndgame;

// MissionEndgame declares endgameQuote[6] and endgameDelays[3] -- room for
// exactly three quote pairs, because vanilla has three endings. CNN has four,
// so Hijacking previously fell through to Conspiracy's quote: the triumphant
// escape ending printed the doom-laden one.
//
// UnrealScript 1 has no way to widen an inherited array (redeclaring an
// inherited name is an error), so the fourth pair lives here. The inherited
// table is deliberately left alone rather than being restated locally, so the
// existing three quotes keep their single definition.
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
        // Select quote per ending. Vanilla MissionEndgame keys this on
        // Endgame1_Played/2_Played/3_Played flags; CNN's QuestSystem
        // doesn't set those, so we key on the ending map filename.
        //
        // Why GetURLMap() and not dxInfo.mapName: 06_Conspiracy/Hijacking/
        // Transcend all share dxInfo.mapName="MUTINY" (the per-map
        // DeusExLevelInfo.MapName property was copy-pasted by the original
        // author and never updated). GetURLMap returns the actual loaded
        // map filename (e.g. "06_Conspiracy"), which IS distinct.
        //
        // Earlier this was hardcoded PrintEndgameQuote(0) which made all
        // four endings print the same "30 Seconds to Mars / Oblivion"
        // quote.
        // PrintEndgameQuote(n) takes a PAIR index (0/1/2), not a raw
        // endgameQuote[] index — internally it reads endgameQuote[2*n]
        // (line) and endgameQuote[2*n+1] (author).
        mapName = Caps(Level.Game.GetURLMap());

        // Hijacking has no slot in the inherited table -- see hijackQuote.
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
// Mirrors MissionEndgame.PrintEndgameQuote(), which can only index the
// inherited three-pair table. Same display path, CNN's own text.
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
    // Hijacking: the triumphant escape. Tennyson's "Ulysses" (1842, public
    // domain) -- survivors setting out rather than the impending-doom tone the
    // other three endings share.
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
