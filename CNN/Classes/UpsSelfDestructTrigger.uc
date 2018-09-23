//-----------------------------------------------------------
// UpsSelfDestructTrigger
// For UPS only
//-----------------------------------------------------------
class UpsSelfDestructTrigger extends CNNSimpleTrigger;

var () name PawnTag;

function ActivatedON()
{
    local CNNUPS p;

    foreach AllActors(class'CNNUPS', p)
    {
        if (p.Tag == PawnTag)
        {
            p.SelfDestruction();
        }
    }

    super.ActivatedON();
}
