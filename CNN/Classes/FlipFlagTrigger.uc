//-----------------------------------------------------------
// one ugly thing for some places
//-----------------------------------------------------------
class FlipFlagTrigger expands CNNSimpleTrigger;

var () name flagName;

var () String strWhenTrue;
var () String strWhenFalse;

function ActivatedON()
{
	local DeusExPlayer player;
	local bool flagValue;
	local int  flagExpiration;

	if ( flagName != '' )
	{
		player = DeusExPlayer(GetPlayerPawn());

		if ( player != None )
		{
			flagValue = player.flagBase.GetBool(flagName);
			flagExpiration = player.flagBase.GetExpiration(flagName, FLAG_Bool);

			flagValue = !flagValue;

			if (flagExpiration == -1)
			{
				player.flagBase.SetBool(flagName, flagValue);
			}
			else
			{
				player.flagBase.SetBool(flagName, flagValue,, flagExpiration);
			}

			if ( flagValue )
				GameLog(strWhenTrue);
			else
				GameLog(strWhenFalse);

		}

	}



	super.ActivatedON();
}

DefaultProperties
{
	strWhenTrue="Flag become True";
	strWhenFalse="Flag become False";
}
