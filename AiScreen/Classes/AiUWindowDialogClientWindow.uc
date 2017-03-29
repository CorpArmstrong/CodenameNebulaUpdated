class AiUWindowDialogClientWindow extends AiUWindowClientWindow;


// Used for scrolling
var float DesiredWidth;
var float DesiredHeight;

var AiUWindowDialogControl	TabLast;

function OKPressed()
{
}

function Notify(AiUWindowDialogControl C, byte E)
{
	// Handle this notification in a subclass.
}

function AiUWindowDialogControl CreateControl(class<AiUWindowDialogControl> ControlClass, float X, float Y, float W, float H, optional AiUWindowWindow OwnerWindow)
{
	local AiUWindowDialogControl C;

	C = AiUWindowDialogControl(CreateWindow(ControlClass, X, Y, W, H, OwnerWindow));
	C.Register(Self);
	C.Notify(C.DE_Created);

	if(TabLast == None)
	{
		TabLast = C;
		C.TabNext = C;
		C.TabPrev = C;
	}
	else
	{
		C.TabNext = TabLast.TabNext;
		C.TabPrev = TabLast;
		TabLast.TabNext.TabPrev = C;
		TabLast.TabNext = C;

		TabLast = C;
	}

	return C;
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
	LookAndFeel.DrawClientArea(Self, C);
}


function GetDesiredDimensions(out float W, out float H)
{
	W = DesiredWidth;
	H = DesiredHeight;
}

defaultproperties
{
}
