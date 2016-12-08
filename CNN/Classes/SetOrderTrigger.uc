//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SetOrderTrigger expands CNNSimpleTrigger;




var () name PawnTag;
var () name PawnOrder;
var () name PawnOrderTag;

function ActivatedON()
{
local ScriptedPawn A;

	foreach  AllActors(class'ScriptedPawn', A)
	{
		if ( A.Tag == PawnTag )
		{
			A.SetOrders( PawnOrder, PawnOrderTag, true );
			DebugInfo("order+");
		}
	}

	super.ActivatedON();
}

defaultproperties
{
}
