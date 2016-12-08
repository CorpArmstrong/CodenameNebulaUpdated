//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UpsSetVisualEffectsTrigger expands CNNSimpleTrigger;

var (UpsSetVisualEffects) name CnnUpsTag;

var (UpsSetVisualEffects) bool  bPulsation;
var (UpsSetVisualEffects) bool  bRotating;

var (UpsSetVisualEffects) float PulsationTime;
var (UpsSetVisualEffects) float PulsationRange;

var (UpsSetVisualEffects) int RotationSpeed;     // one turn around self per thisnumber of seconds


function ActivatedON()
{
local CNNUPS cnnUps;

	foreach AllActors(class'CNNUPS', cnnUps, CnnUpsTag)
	{
		cnnUps.bPulsation = self.bPulsation;
		cnnUps.bRotating = self.bPulsation;

		cnnUps.PulsationTime = self.PulsationTime;
		cnnUps.PulsationRange = self.PulsationRange;

		cnnUps.RotationSpeed = self.RotationSpeed;
	}

	super.ActivatedON();
}

DefaultProperties
{
	CnnUpsTag=CNNUPS

	// the most "Excited" state of UPS
	bPulsation=true
	bRotating=true

	PulsationTime=0.25
	PulsationRange=2

	RotationSpeed=20000.0
}
