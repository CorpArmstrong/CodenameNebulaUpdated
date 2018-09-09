//-----------------------------------------------------------------
//  Class:    CNNGravityTrigger
//  Author:   CorpArmstrong
//
//  This trigger will set gravity vector for specified ZoneInfo.
//  Physics can be applied on actors using 'physicsActorTag' param.
//-----------------------------------------------------------------
class CNNGravityTrigger extends CNNTrigger;

var(GravityInfo) name zoneInfoTag;
var(GravityInfo) vector zoneGravity;
var(GravityInfo) bool applyPhysics;
var(GravityInfo) name physicsActorTag;
var(GravityInfo) EPhysics physicsType;

function ApplyGravity()
{
    local ZoneInfo zInfo;
    local Actor physicsActor;

    foreach AllActors(class 'ZoneInfo', zInfo, zoneInfoTag)
    {
        zInfo.ZoneGravity = zoneGravity;

        if (applyPhysics)
        {
            foreach AllActors(class 'Actor', physicsActor, physicsActorTag)
            {
                physicsActor.SetPhysics(physicsType);
            }
        }
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    ApplyGravity();
    super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        ApplyGravity();
        super.Touch(Other);
    }
}
