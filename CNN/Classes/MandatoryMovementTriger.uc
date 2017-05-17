//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MandatoryMovementTriger expands CNNTrigger;

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
    Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        MovePawn();
        Super.Touch(Other);
    }
}

function MovePawn()
{
    local SpawnPoint NewPosPlace;
    local Pawn MovedPawn;

    NewPosPlace = None;

    foreach AllActors(class 'SpawnPoint', NewPosPlace, SpawnPointTag)
    {
    	if (NewPosPlace != None)
		{
			break;
		}
	}

    if (NewPosPlace != None)
    {
        switch(MovingType)
        {
            case MT_MovePlayer:
                MovedPawn = GetPlayerPawn();
                break;
            case MT_MovePawn:
                foreach AllActors(class 'Pawn', MovedPawn, MovedPawnTag)
                {
                    if (MovedPawn != None)
                    {
                        break;
                    }
                }
                break;
            default:
                break;
        }

        if (MovedPawn != None)
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

defaultproperties
{
}
