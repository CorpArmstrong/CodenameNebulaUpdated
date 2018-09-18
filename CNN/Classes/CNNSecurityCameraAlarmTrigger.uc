//-----------------------------------------------------------
//  Class:    CNNSecurityCameraAlarmTrigger
//  Author:   CorpArmstrong
//
//  This trigger will toggle SecurityCamera's params, such as:
//  bNoAlarm
//-----------------------------------------------------------

class CNNSecurityCameraAlarmTrigger expands CNNTrigger;

var() name cameraTag;
var() bool bToggleAllCameras;

function TriggerCameraAlarm()
{
    local SecurityCamera secCam;

    if (!bToggleAllCameras)
    {
        foreach AllActors(class 'SecurityCamera', secCam, cameraTag)
        {
            secCam.bNoAlarm = !secCam.bNoAlarm;
        }
    }
    else
    {
        foreach AllActors(class 'SecurityCamera', secCam)
        {
            secCam.bNoAlarm = !secCam.bNoAlarm;
        }
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    TriggerCameraAlarm();
    super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        TriggerCameraAlarm();
        super.Touch(Other);
    }
}

defaultproperties
{
    cameraTag=SecurityCamera
    bToggleAllCameras=true
}
