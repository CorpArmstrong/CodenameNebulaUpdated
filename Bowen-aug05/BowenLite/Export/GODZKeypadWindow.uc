//================================================================================
// GODZKeypadWindow.
//================================================================================
class GODZKeypadWindow extends HUDKeypadWindow;

function ValidateCode ()
{
	local Actor A;
	local int i;

	if ( CodeIsValid() )
	{
		Player.KeypadRunEvents(keypadOwner,True);
		Player.KeypadRunUntriggers(keypadOwner);
		Player.PlaySound(keypadOwner.successSound,0);
		winText.UnknownFunction1476(colGreen);
		winText.UnknownFunction1550(msgAccessGranted);
		Player.Alliance='GODZ';
		Player.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName $ " was granted access to the GODZ only area");
		Log("GODZKeyPad -- " $ Player.PlayerReplicationInfo.PlayerName $ " was granted access with the code " $ inputCode);
	}
	else
	{
		Player.KeypadRunEvents(keypadOwner,False);
		Player.PlaySound(keypadOwner.failureSound,0);
		winText.UnknownFunction1476(colRed);
		winText.UnknownFunction1550(msgAccessDenied);
		Player.TakeDamage(10,None,Player.Location,vect(0.00,0.00,0.00),'Flamed');
		Player.Alliance=Player.Default.Alliance;
		Player.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName $ " was denied access to the GODZ only area and has been set on fire!");
		Log("GODZKeyPad -- " $ Player.PlayerReplicationInfo.PlayerName $ " was denied access with the code " $ inputCode);
	}
	bWait=True;
	UnknownFunction1490(1.00,False,0,'KeypadDelay');
}

function bool CodeIsValid ()
{
	local int i;
	local string CodeTemp;
	local string Nametemp;
	local bool bValid;

	bValid=False;
	i=0;
JL000F:
	if ( i < 64 )
	{
		CodeTemp=GODZKeypad(keypadOwner).GODZCodes[i];
		Nametemp=GODZKeypad(keypadOwner).GODZNames[i];
		if ( (CodeTemp ~= inputCode) && (Player.PlayerReplicationInfo.PlayerName ~= Nametemp) )
		{
			bValid=True;
		}
		i++;
		goto JL000F;
	}
	return bValid;
}

function PressButton (int Num)
{
	local Sound tone;

	if ( bWait )
	{
		return;
	}
	if ( Len(inputCode) < 16 )
	{
		inputCode=inputCode $ IndexToString(Num);
		switch (Num)
		{
			case 0:
			tone=Sound'Touchtone1';
			break;
			case 1:
			tone=Sound'Touchtone2';
			break;
			case 2:
			tone=Sound'Touchtone3';
			break;
			case 3:
			tone=Sound'Touchtone4';
			break;
			case 4:
			tone=Sound'Touchtone5';
			break;
			case 5:
			tone=Sound'Touchtone6';
			break;
			case 6:
			tone=Sound'Touchtone7';
			break;
			case 7:
			tone=Sound'Touchtone8';
			break;
			case 8:
			tone=Sound'Touchtone9';
			break;
			case 9:
			tone=Sound'Touchtone10';
			break;
			case 10:
			tone=Sound'Touchtone0';
			break;
			case 11:
			tone=Sound'Touchtone11';
			break;
			default:
		}
		Player.PlaySound(tone,0);
	}
	GenerateKeypadDisplay();
	winText.UnknownFunction1476(colHeaderText);
	winText.UnknownFunction1550(msgEnterCode);
	if ( Len(inputCode) == GODZKeypad(keypadOwner).CodeLength )
	{
		ValidateCode();
	}
}

function KeypadDelay (int timerId, int invocations, int clientData)
{
	bWait=False;
	Root.PopWindow();
}

function GenerateKeypadDisplay ()
{
	local int i;

	msgEnterCode="";
	i=0;
JL000F:
	if ( i < GODZKeypad(keypadOwner).CodeLength )
	{
		if ( i == Len(inputCode) )
		{
			msgEnterCode=msgEnterCode $ "|p5";
		}
		msgEnterCode=msgEnterCode $ "~";
		i++;
		goto JL000F;
	}
}