class AiUWindowMessageBoxCW expands AiUWindowDialogClientWindow;

var MessageBoxButtons Buttons;

var MessageBoxResult EnterResult;
var AiUWindowSmallButton YesButton, NoButton, OKButton, CancelButton;
var localized string YesText, NoText, OKText, CancelText;
var AiUWindowMessageBoxArea MessageArea;

function Created()
{
	Super.Created();
	SetAcceptsFocus();

	MessageArea = AiUWindowMessageBoxArea(CreateWindow(class'AiUWindowMessageBoxArea', 10, 10, WinWidth-20, WinHeight-44));
}

function KeyDown(int Key, float X, float Y)
{
	local AiUWindowMessageBox P;

	P = AiUWindowMessageBox(ParentWindow);

	if(Key == GetPlayerOwner().EInputKey.IK_Enter && EnterResult != MR_None)
	{
		P = AiUWindowMessageBox(ParentWindow);
		P.Result = EnterResult;
		P.Close();
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	MessageArea.SetSize(WinWidth-20, WinHeight-44);

	switch(Buttons)
	{
	case MB_YesNoCancel:
		CancelButton.WinLeft = WinWidth - 52;
		CancelButton.WinTop = WinHeight - 20;
		NoButton.WinLeft = WinWidth - 104;
		NoButton.WinTop = WinHeight - 20;
		YesButton.WinLeft = WinWidth - 156;
		YesButton.WinTop = WinHeight - 20;
		break;
	case MB_YesNo:
		NoButton.WinLeft = WinWidth - 52;
		NoButton.WinTop = WinHeight - 20;
		YesButton.WinLeft = WinWidth - 104;
		YesButton.WinTop = WinHeight - 20;
		break;
	case MB_OKCancel:
		CancelButton.WinLeft = WinWidth - 52;
		CancelButton.WinTop = WinHeight - 20;
		OKButton.WinLeft = WinWidth - 104;
		OKButton.WinTop = WinHeight - 20;
		break;
	case MB_OK:
		OKButton.WinLeft = WinWidth - 52;
		OKButton.WinTop = WinHeight - 20;
		break;
	}
}

function Resized()
{
	Super.Resized();
	MessageArea.SetSize(WinWidth-20, WinHeight-44);
}

function float GetHeight(Canvas C)
{
	return 44 + MessageArea.GetHeight(C);
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;
	Super.Paint(C, X, Y);
	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, WinHeight-24, WinWidth, 24, T);
}

function SetupMessageBoxClient(string InMessage, MessageBoxButtons InButtons, MessageBoxResult InEnterResult)
{
	MessageArea.Message = InMessage;
	Buttons = InButtons;
	EnterResult = InEnterResult;

	// Create buttons
	switch(Buttons)
	{
	case MB_YesNoCancel:
		CancelButton = AiUWindowSmallButton(CreateControl(class'AiUWindowSmallButton', WinWidth - 52, WinHeight - 20, 48, 16));
		CancelButton.SetText(CancelText);
		if(EnterResult == MR_Cancel)
			CancelButton.SetFont(F_Bold);
		else
			CancelButton.SetFont(F_Normal);
		NoButton = AiUWindowSmallButton(CreateControl(class'AiUWindowSmallButton', WinWidth - 104, WinHeight - 20, 48, 16));
		NoButton.SetText(NoText);
		if(EnterResult == MR_No)
			NoButton.SetFont(F_Bold);
		else
			NoButton.SetFont(F_Normal);
		YesButton = AiUWindowSmallButton(CreateControl(class'AiUWindowSmallButton', WinWidth - 156, WinHeight - 20, 48, 16));
		YesButton.SetText(YesText);
		if(EnterResult == MR_Yes)
			YesButton.SetFont(F_Bold);
		else
			YesButton.SetFont(F_Normal);
		break;
	case MB_YesNo:
		NoButton = AiUWindowSmallButton(CreateControl(class'AiUWindowSmallButton', WinWidth - 52, WinHeight - 20, 48, 16));
		NoButton.SetText(NoText);
		if(EnterResult == MR_No)
			NoButton.SetFont(F_Bold);
		else
			NoButton.SetFont(F_Normal);
		YesButton = AiUWindowSmallButton(CreateControl(class'AiUWindowSmallButton', WinWidth - 104, WinHeight - 20, 48, 16));
		YesButton.SetText(YesText);
		if(EnterResult == MR_Yes)
			YesButton.SetFont(F_Bold);
		else
			YesButton.SetFont(F_Normal);
		break;
	case MB_OKCancel:
		CancelButton = AiUWindowSmallButton(CreateControl(class'AiUWindowSmallButton', WinWidth - 52, WinHeight - 20, 48, 16));
		CancelButton.SetText(CancelText);
		if(EnterResult == MR_Cancel)
			CancelButton.SetFont(F_Bold);
		else
			CancelButton.SetFont(F_Normal);
		OKButton = AiUWindowSmallButton(CreateControl(class'AiUWindowSmallButton', WinWidth - 104, WinHeight - 20, 48, 16));
		OKButton.SetText(OKText);
		if(EnterResult == MR_OK)
			OKButton.SetFont(F_Bold);
		else
			OKButton.SetFont(F_Normal);
		break;
	case MB_OK:
		OKButton = AiUWindowSmallButton(CreateControl(class'AiUWindowSmallButton', WinWidth - 52, WinHeight - 20, 48, 16));
		OKButton.SetText(OKText);
		if(EnterResult == MR_OK)
			OKButton.SetFont(F_Bold);
		else
			OKButton.SetFont(F_Normal);
		break;
	}
}

function Notify(AiUWindowDialogControl C, byte E)
{
	local AiUWindowMessageBox P;

	P = AiUWindowMessageBox(ParentWindow);

	if(E == DE_Click)
	{
		switch(C)
		{
		case YesButton:
			P.Result = MR_Yes;
			P.Close();
			break;
		case NoButton:
			P.Result = MR_No;
			P.Close();
			break;
		case OKButton:
			P.Result = MR_OK;
			P.Close();
			break;
		case CancelButton:
			P.Result = MR_Cancel;
			P.Close();
			break;
		}
	}
}

defaultproperties
{
     YesText="Yes"
     NoText="No"
     OKText="OK"
     CancelText="Cancel"
}
