//-----------------------------------------------------------
// CNNDoorSignalLight
//-----------------------------------------------------------
class CNNDoorSignalLight extends CageLight; // make CNNActor descendant

function bool Facelift(bool bOn)
{
    //nothing
}

function BeginPlay()
{
    // without super
}

function Trigger(Actor Other, Pawn Instigator)
{
    Skin=Texture'NCL_Green';
    LightType=LT_Steady;
}

function UnTrigger(Actor Other, Pawn Instigator)
{
    Skin=Texture'NCL_Red';
    LightType=LT_None;
}

defaultproperties
{
    Mesh=LodMesh'CNN.CLight'
    Skin=Texture'CNN.NCL_Red';
    ScaleGlow=2.0;
    bUnlit=true;
    DrawScale=0.5;
    LightType=LT_None;
    LightHue=81;
    LightSaturation=64;
    bCollideActors=false;
    bCollideWorld=false;
    bBlockActors=false;
    bBlockPlayers=false;
    bProjTarget=false;
}
