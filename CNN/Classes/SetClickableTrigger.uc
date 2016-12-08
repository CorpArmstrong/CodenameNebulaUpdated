//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SetClickableTrigger expands CNNSimpleTrigger;

var () name DeusExDecorationTag;

enum EChangeBoolValue
{
	ECBV_NotChange,
	ECBV_SetToTrue,
	ECBV_SetToFalse,
};

var () EChangeBoolValue SetDec_CollideActors;
var () EChangeBoolValue SetDec_OnlyTriggerable;
var () EChangeBoolValue SetDec_Highlight;

function ActivatedON()
{
	local DeusExDecoration dec;

	if ( DeusExDecorationTag != '' )
	{
		foreach AllActors(class'DeusExDecoration', dec, DeusExDecorationTag)
		{
			switch (SetDec_CollideActors)
			{
				case ECBV_SetToTrue:
					//dec.bCollideActors = true;
					//( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
					dec.SetCollision(true, dec.bBlockActors, dec.bBlockPlayers);
					break;

				case ECBV_SetToFalse:
					//dec.bCollideActors = false;
					dec.SetCollision(false, dec.bBlockActors, dec.bBlockPlayers);
					break;

			}

			switch (SetDec_OnlyTriggerable)
			{
				case ECBV_SetToTrue:
					dec.bOnlyTriggerable = true;
					break;

				case ECBV_SetToFalse:
					dec.bOnlyTriggerable = false;
					break;
			}

			switch (SetDec_Highlight)
			{
				case ECBV_SetToTrue:
					dec.bHighlight = true;
					break;

				case ECBV_SetToFalse:
					dec.bHighlight = false;
					break;
			}
		}
	}
}

DefaultProperties
{

}
