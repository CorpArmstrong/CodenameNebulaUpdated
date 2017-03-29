//=============================================================================
// AiUWindowSBLeftButton - Scrollbar left button
//=============================================================================
class AiUWindowSBLeftButton extends AiUWindowButton;

var float NextClickTime;

function Created()
{
	bNoKeyboard = True;
	Super.Created();
}

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.SB_SetupLeftButton(Self);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);
	if(bDisabled)
		return;
	AiUWindowHScrollBar(ParentWindow).Scroll(-AiUWindowHScrollBar(ParentWindow).ScrollAmount);
	NextClickTime = GetLevel().TimeSeconds + 0.5;
}

function Tick(float Delta)
{
	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < GetLevel().TimeSeconds))
	{
		AiUWindowHScrollBar(ParentWindow).Scroll(-AiUWindowHScrollBar(ParentWindow).ScrollAmount);
		NextClickTime = GetLevel().TimeSeconds + 0.1;
	}

	if(!bMouseDown)
	{
		NextClickTime = 0;
	}
}

defaultproperties
{
}
