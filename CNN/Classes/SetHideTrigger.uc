//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SetHideTrigger expands CNNSimpleTrigger;

var () name ActorTag;
var () bool ActorHideValue;

function ActivatedON()
{
	local Actor A;

	foreach AllActors( class'Actor', A, ActorTag )
		A.bHidden = ActorHideValue;

	super.ActivatedON();
}

DefaultProperties
{
}
