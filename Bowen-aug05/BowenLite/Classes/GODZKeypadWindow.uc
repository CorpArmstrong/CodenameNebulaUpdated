//=============================================================================
// GODZKeypadWindow. 	(c) 2003 JimBowen
//=============================================================================
class GODZKeypadWindow expands HUDKeypadWindow;




// ----------------------------------------------------------------------
// ValidateCode()
// 
// Check for correct code entry
// ----------------------------------------------------------------------

function ValidateCode()
{
	local Actor A;
	local int i;

	if (CodeIsValid())
	{
				// Trigger the successEvent
           player.KeypadRunEvents(keypadOwner, True);
				//KeypadOwner.RunEvents(player, True);

		// UnTrigger event (if used)
      // DEUS_EX AMSD Export to player(and then to keypad), for multiplayer.
      player.KeypadRunUntriggers(keypadOwner);
		player.PlaySound(keypadOwner.successSound, SLOT_None);
		winText.SetTextColor(colGreen);
		winText.SetText(msgAccessGranted);
		Player.Alliance = 'GODZ';
		
		player.BroadcastMessage(player.playerreplicationinfo.playername$ " was granted access to the GODZ only area");
		log("GODZKeyPad -- " $ player.playerreplicationinfo.playername $ " was granted access with the code "$InputCode);
	}
	else
	{
		//Trigger failure event
         player.KeypadRunEvents(keypadOwner, False);

		player.PlaySound(keypadOwner.failureSound, SLOT_None);
		winText.SetTextColor(colRed);
		winText.SetText(msgAccessDenied);

		Player.TakeDamage(10, None, player.Location, vect(0,0,0), 'Flamed');
		Player.Alliance = player.default.alliance;

		player.BroadcastMessage(player.playerreplicationinfo.playername$ " was denied access to the GODZ only area and has been set on fire!");
		log("GODZKeyPad -- " $ player.playerreplicationinfo.playername $ " was denied access with the code "$InputCode);
	}

	
	bWait = True;
	AddTimer(1.0, False, 0, 'KeypadDelay');
}

function bool CodeIsValid()
{
local int i;
local string CodeTemp;
local string Nametemp;
local bool bValid;

bValid = false;

	for( i=0; i<ArrayCount(GODZKeyPad(KeypadOwner).GODZCodes); i++ )
{
	CodeTemp = GODZKeyPad(KeypadOwner).GODZCodes[i];
	NameTemp = GODZKeyPad(KeypadOwner).GODZNames[i];
	
		if (CodeTemp ~= InputCode && player.playerreplicationinfo.playername ~= NameTemp)
			bValid = true;			
}
return bValid;
}


// ----------------------------------------------------------------------
// PressButton()
//
// User pressed a keypad button
// ----------------------------------------------------------------------

function PressButton(int num)
{
	local sound tone;

	if (bWait)
		return;

	if (Len(inputCode) < 16)
	{
		inputCode = inputCode $ IndexToString(num);
		switch (num)
		{
			case 0:		tone = sound'Touchtone1'; break;
			case 1:		tone = sound'Touchtone2'; break;
			case 2:		tone = sound'Touchtone3'; break;
			case 3:		tone = sound'Touchtone4'; break;
			case 4:		tone = sound'Touchtone5'; break;
			case 5:		tone = sound'Touchtone6'; break;
			case 6:		tone = sound'Touchtone7'; break;
			case 7:		tone = sound'Touchtone8'; break;
			case 8:		tone = sound'Touchtone9'; break;
			case 9:		tone = sound'Touchtone10'; break;
			case 10:	tone = sound'Touchtone0'; break;
			case 11:	tone = sound'Touchtone11'; break;
		}

		player.PlaySound(tone, SLOT_None);
	}

	GenerateKeypadDisplay();
	winText.SetTextColor(colHeaderText);
	winText.SetText(msgEnterCode);

	if (Len(inputCode) == GODZKeypad(keypadOwner).CodeLength)
		ValidateCode();
}



// ----------------------------------------------------------------------
// KeypadDelay()
//
// timer function to pause after code entry
// ----------------------------------------------------------------------

function KeypadDelay(int timerID, int invocations, int clientData)
{
	bWait = False;

	//  get out
		root.PopWindow();

}



// ----------------------------------------------------------------------
// GenerateKeypadDisplay()
//
// Generate the keypad's display
// ----------------------------------------------------------------------

function GenerateKeypadDisplay()
{
	local int i;

	msgEnterCode = "";

	for (i=0; i<GODZKeyPad(keypadOwner).CodeLength; i++)
	{
		if (i == Len(inputCode))
			msgEnterCode = msgEnterCode $ "|p5";
		msgEnterCode = msgEnterCode $ "~";
	}
}

//---END-CLASS---

defaultproperties
{
}
