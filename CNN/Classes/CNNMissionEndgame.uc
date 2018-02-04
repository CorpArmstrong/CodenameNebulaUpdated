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
    Super.Timer();
    
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
     endgameQuote(0)="YESTERDAY WE OBEYED KINGS AND BENT OUR NECKS BEFORE EMPERORS.  BUT TODAY WE KNEEL ONLY TO TRUTH..."
     endgameQuote(1)="    -- KAHLIL GIBRAN"
     endgameQuote(2)="IF THERE WERE NO GOD, IT WOULD BE NECESSARY TO INVENT HIM."
     endgameQuote(3)="    -- VOLTAIRE"
     endgameQuote(4)="BETTER TO REIGN IN HELL, THAN SERVE IN HEAVEN."
     endgameQuote(5)="    -- PARADISE LOST, JOHN MILTON"
}
