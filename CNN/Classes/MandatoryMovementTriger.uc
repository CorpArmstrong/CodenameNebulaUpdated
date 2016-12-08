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
    local SpawnPoint NewPosPlace;
    local Pawn MovedPawn;

// ================================================
        // find a first spawn point who macth by tag
        NewPosPlace = None;
        foreach AllActors( class 'SpawnPoint', NewPosPlace, SpawnPointTag )
            if ( NewPosPlace != None ) break;

        if ( NewPosPlace != None )
        {

            if ( MovingType == MT_MovePlayer )
            {
                MovedPawn = GetPlayerPawn();
            }
            else if ( MovingType == MT_MovePlayer )
            {
                foreach AllActors( class 'Pawn', MovedPawn, MovedPawnTag )
                    if ( MovedPawn != None ) break;
            }

            if ( MovedPawn != None )
            {
                MovedPawn.SetLocation(NewPosPlace.Location);
                MovedPawn.SetRotation(NewPosPlace.Rotation);
            }
            else msgbox("MovedPawn not finded");
        }
// ================================================

	Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    local SpawnPoint NewPosPlace;
    local Pawn MovedPawn;

	if (IsRelevant(Other))
	{
// ================================================
        // find a first spawn point who macth by tag
        NewPosPlace = None;
        foreach AllActors( class 'SpawnPoint', NewPosPlace, SpawnPointTag )
            if ( NewPosPlace != None ) break;

        if ( NewPosPlace != None )
        {

            if ( MovingType == MT_MovePlayer )
            {
                MovedPawn = GetPlayerPawn();
            }
            else if ( MovingType == MT_MovePlayer )
            {
                foreach AllActors( class 'Pawn', MovedPawn, MovedPawnTag )
                    if ( MovedPawn != None ) break;
            }

            if ( MovedPawn != None )
            {
                MovedPawn.SetLocation(NewPosPlace.Location);
                MovedPawn.SetRotation(NewPosPlace.Rotation);
            }
            else msgbox("MovedPawn not finded");
        }
// ================================================
		Super.Touch(Other);
	}
}

defaultproperties
{
}
