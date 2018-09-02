//-----------------------------------------------------------
//  Class:    CNNZoneTrigger
//  Author:   CorpArmstrong
//
//  This trigger will alter ZoneInfo's params, such as:
//  1) ZoneDamage
//  2) ZoneVelocity
//-----------------------------------------------------------

class CNNZoneTrigger expands CNNTrigger;

var(TargetZone) name zoneTag;
var(TargetZone) name zoneDamageType;
var(TargetZone) int zoneDamagePerSec;
var(TargetZone) vector zoneVelocity;

function TriggerZone()
{
    local ZoneInfo zInfo;

    foreach AllActors(class 'ZoneInfo', zInfo, zoneTag)
    {
        zInfo.DamageType = zoneDamageType;
        zInfo.ZoneVelocity = zoneVelocity;
		zInfo.DamagePerSec = zoneDamagePerSec;
		BroadcastMessage("zoneTag = " $ zInfo.Tag);
		BroadcastMessage("zoneVelocity = " $ zInfo.ZoneVelocity);
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    TriggerZone();
    Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        TriggerZone();
        Super.Touch(Other);
    }
}
