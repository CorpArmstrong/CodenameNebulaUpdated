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
    super.Timer();

    if (!bQuotePrinted)
    {
        PrintEndgameQuote(0);
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
