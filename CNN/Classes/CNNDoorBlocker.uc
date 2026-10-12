//=============================================================================
// CNNDoorBlocker.
//
// An invisible collision cylinder. A row of them stands in for a mover whose
// brush has been taken away -- see CNNEntryDoorMesh.
//=============================================================================
class CNNDoorBlocker extends Actor;

defaultproperties
{
    bHidden=True
    bCollideActors=True
    bBlockActors=True
    bBlockPlayers=True
    bProjTarget=True
    CollisionRadius=12.000000
    CollisionHeight=80.000000
    RemoteRole=ROLE_None
}
