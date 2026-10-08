//-----------------------------------------------------------------------
// Class:    CNNWaypoint
//-----------------------------------------------------------------------
// A spot for a pawn's GoingTo orders where the map has no path node.
// Spawned by script; it collides with nothing but marks arrival, which
// ends GoingTo.
//-----------------------------------------------------------------------
class CNNWaypoint extends Keypoint;

defaultproperties
{
    bStatic=False
    bCollideActors=True
    CollisionRadius=24.000000
    CollisionHeight=48.000000
}
