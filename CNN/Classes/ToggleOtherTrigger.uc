//-----------------------------------------------------------
//  This trigger used for enabling or disabling other triggers
//-----------------------------------------------------------
class ToggleOtherTrigger expands CNNSimpleTrigger;

// change bInitialActive for Trigger subclases
// change bEnable for CNNSimpleTrigger subclases

struct ToggleTriggersInfo
{
	var () Name TriggerTag;
	var () bool bEnabled;
};

var () ToggleTriggersInfo ToggleTriggers[8];

function ActivatedON()
{
local int i;
local int j;
local Trigger trig;
local CNNSimpleTrigger cnnTrig;
local bool findedSome;

	for ( i = 0; i < 8; i ++ )
		if ( ToggleTriggers[i].TriggerTag != '' )
		{
			findedSome = false;

			foreach AllActors( class 'Trigger', trig, ToggleTriggers[i].TriggerTag )
			{
				trig.bInitiallyActive = ToggleTriggers[i].bEnabled;
				findedSome=true;
				DebugInfo(trig.Tag@"=="@trig.bInitiallyActive);
			}

			foreach AllActors( class 'CNNSimpleTrigger', cnnTrig, ToggleTriggers[i].TriggerTag )
			{
				cnnTrig.bEnabled = ToggleTriggers[i].bEnabled;
				findedSome=true;
				DebugInfo(cnnTrig.Tag@"=="@cnnTrig.bEnabled);
			}

			if ( !findedSome )
				DebugInfo("Not finded any"@ToggleTriggers[i].TriggerTag);
		}



	super.ActivatedON();
}

DefaultProperties
{

}
