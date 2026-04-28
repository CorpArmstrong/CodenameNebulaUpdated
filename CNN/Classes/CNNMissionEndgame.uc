//=============================================================================
// CNNMissionEndgame.
//=============================================================================
class CNNMissionEndgame extends MissionEndgame;

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
        if (InStr(mapName, "CONSPIRACY") != -1)
            quoteIndex = 0;     // Oblivion / 30 Seconds to Mars
        else if (InStr(mapName, "MUTINY") != -1)
            quoteIndex = 1;     // Figure 09 / Linkin Park
        else if (InStr(mapName, "TRANSCEND") != -1)
            quoteIndex = 2;     // The Fantasy / 30 Seconds to Mars
        else
            quoteIndex = 0;

        PrintEndgameQuote(quoteIndex);
    }

    endgameTimer += checkTime;

	if (endgameTimer > endgameDelays[0])
    {
        FinishCinematic();
    }
}

defaultproperties
{
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
