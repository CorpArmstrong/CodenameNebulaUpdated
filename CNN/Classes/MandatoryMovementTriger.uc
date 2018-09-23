//-----------------------------------------------------------
// MandatoryMovementTriger
//-----------------------------------------------------------
class MandatoryMovementTriger extends CNNTrigger;

var() enum EMovingType
{
    MT_MovePlayer,
    MT_MovePawn,
} MovingType;

var () name MovedPawnTag;
var () name SpawnPointTag;

function Trigger(Actor Other, Pawn Instigator)
{
    MovePawn();
    super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        MovePawn();
        super.Touch(Other);
    }
}

function MovePawn()
{
    local SpawnPoint NewPosPlace;
    local Pawn MovedPawn;

    NewPosPlace = none;

    foreach AllActors(class 'SpawnPoint', NewPosPlace, SpawnPointTag)
    {
        if (NewPosPlace != none)
        {
        	break;
        }
    }

    if (NewPosPlace != none)
    {
        switch(MovingType)
        {
            case MT_MovePlayer:
                MovedPawn = GetPlayerPawn();
                break;
            case MT_MovePawn:
                foreach AllActors(class 'Pawn', MovedPawn, MovedPawnTag)
                {
                    if (MovedPawn != none)
                    {
                        break;
                    }
                }
                break;
            default:
                break;
        }

        if (MovedPawn != none)
        {
            MovedPawn.SetLocation(NewPosPlace.Location);
            MovedPawn.SetRotation(NewPosPlace.Rotation);
        }
        else
        {
            msgbox("MovedPawn not finded");
        }
    }
}
