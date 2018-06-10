//-----------------------------------------------------------
// LaserSecurityController
//-----------------------------------------------------------
class LaserSecurityController extends Trigger;

function Trigger(Actor Other, Pawn Instigator)
{
    local Chapter06L1 mis;
    
    foreach AllActors(class'CNN.Chapter06L1', mis)
	{
		mis.UpdateLasersState();
	}
}