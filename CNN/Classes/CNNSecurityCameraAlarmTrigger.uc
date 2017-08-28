//-----------------------------------------------------------
//  Class:    CNNSecurityCameraAlarmTrigger
//  Author:   CorpArmstrong
//
//  This trigger will toggle SecurityCamera's params, such as:
//  bNoAlarm
//-----------------------------------------------------------

class CNNSecurityCameraAlarmTrigger expands CNNTrigger;

var() name cameraTag;

function TriggerCameraAlarm()
{
    local SecurityCamera secCam;

    foreach AllActors(class 'SecurityCamera', secCam, cameraTag)
    {
        secCam.bNoAlarm = !secCam.bNoAlarm;
		BroadcastMessage("SecurityCamera bNoAlarm = " $secCam.bNoAlarm);
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    TriggerCameraAlarm();
    Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        TriggerCameraAlarm();
        Super.Touch(Other);
    }
}
