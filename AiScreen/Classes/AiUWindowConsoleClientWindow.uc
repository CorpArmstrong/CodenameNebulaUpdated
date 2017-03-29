class AiUWindowConsoleClientWindow extends AiUWindowDialogClientWindow;

#exec TEXTURE IMPORT NAME=BlackTexture FILE=Textures\BlackTexture.bmp GROUP="Icons" MIPS=OFF

var AiUWindowConsoleTextAreaControl TextArea;
var AiUWindowEditControl	EditControl;

function Created()
{
	TextArea = AiUWindowConsoleTextAreaControl(CreateWindow(class'AiUWindowConsoleTextAreaControl', 0, 0, WinWidth, WinHeight));
	EditControl = AiUWindowEditControl(CreateControl(class'AiUWindowEditControl', 0, WinHeight-16, WinWidth, 16));
	EditControl.SetFont(F_Normal);
	EditControl.SetNumericOnly(False);
	EditControl.SetMaxLength(400);
	EditControl.SetHistory(True);
}

function Notify(AiUWindowDialogControl C, byte E)
{
	local string s;
	Super.Notify(C, E);

	switch(E)
	{
	case DE_EnterPressed:
		switch(C)
		{
		case EditControl:
			if(EditControl.GetValue() != "")
			{
				s = EditControl.GetValue();
				Root.Console.Message( None, "> "$s, 'Console' );
				EditControl.Clear();
				if( !Root.Console.ConsoleCommand( s ) )
					Root.Console.Message( None, Localize("Errors","Exec","Core"), 'Console' );
			}
			break;
		}
		break;
	case DE_WheelUpPressed:
		switch(C)
		{
		case EditControl:
			TextArea.VertSB.Scroll(-1);
			break;
		}
		break;
	case DE_WheelDownPressed:
		switch(C)
		{
		case EditControl:
			TextArea.VertSB.Scroll(1);
			break;
		}
		break;
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	EditControl.SetSize(WinWidth, 17);
	EditControl.WinLeft = 0;
	EditControl.WinTop = WinHeight - EditControl.WinHeight;
	EditControl.EditBoxWidth = WinWidth;

	TextArea.SetSize(WinWidth, WinHeight - EditControl.WinHeight);
}

function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

defaultproperties
{
}
