//-----------------------------------------------------------
//  my version of ConversationTrigger with more parameters
//-----------------------------------------------------------
class CnnConversTrigger expands CNNSimpleTrigger;

var(ConversationTrigger) name ConversationTag;
var(ConversationTrigger) string BindName;
var(ConversationTrigger) name CheckFlag;
var(ConversationTrigger) bool bCheckFalse;
var(ConversationTrigger) bool bForcePlay; // new parameter, use with 3th person conversations only

// we send event only if dialog was started
singular function ActivatedON()
{
	local DeusExPlayer player;
	local bool bSuccess;
	local Actor A, conOwner;

	player = DeusExPlayer(GetPlayerPawn());
	bSuccess = True;

	if (player == None)
		return;

	if (CheckFlag != '')
	{
		if (!player.flagBase.GetBool(CheckFlag))
			bSuccess = bCheckFalse;
		else
			bSuccess = !bCheckFalse;
	}

	if ((BindName != "") && (ConversationTag != ''))
	{
		foreach AllActors(class'Actor', A)
			if (A.BindName == BindName)
			{
				conOwner = A;
				break;
			}


		if (bSuccess)
			if (player.StartConversationByName(ConversationTag, conOwner, false, bForcePlay))
				//Super.Trigger(Other, Instigator);
				super.ActivatedON();
	}
}

DefaultProperties
{

}
