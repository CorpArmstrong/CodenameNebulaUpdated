//=============================================================================
// AvatarGenerator.
//=============================================================================
class AvatarGenerator extends PawnGenerator;

// ----------------------------------------------------------------------
// Destroyed()
// ----------------------------------------------------------------------
/*
function Destroyed()
{
    local int i;

    // Destroy all our pawns
    for (i = 0; i < ArrayCount(Pawns); i++)
    {
        Pawns[i].Pawn.Destroy();
    }

    Super.Destroyed();
}
*/

defaultproperties
{
     PawnClasses(0)=(Count=5,PawnClass=Class'CNN.Avatar')
     Alliance=Karkarian
     ActiveArea=1600.000000
     Radius=200.000000
     MaxCount=5
     bPawnsTransient=True
     bRepopulate=True
     Orders=RunningTo
}
