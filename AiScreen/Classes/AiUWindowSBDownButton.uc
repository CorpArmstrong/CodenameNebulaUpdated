//=============================================================================
// AiUWindowSBDownButton - Scrollbar up button
//=============================================================================
class AiUWindowSBDownButton extends AiUWindowButton;

var float NextClickTime;

function Created()
{
	bNoKeyboard = True;
	Super.Created();
}

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.SB_SetupDownButton(Self);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);
	if(bDisabled)
		return;
	AiUWindowVScrollBar(ParentWindow).Scroll(AiUWindowVScrollBar(ParentWindow).ScrollAmount);
	NextClickTime = Root.GetPlayerOwner().Level.TimeSeconds + 0.5;
}

function Tick(float Delta)
{
	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < Root.GetPlayerOwner().Level.TimeSeconds))
	{
		AiUWindowVScrollBar(ParentWindow).Scroll(AiUWindowVScrollBar(ParentWindow).ScrollAmount);
		NextClickTime = Root.GetPlayerOwner().Level.TimeSeconds + 0.1;
	}

	if(!bMouseDown)
	{
		NextClickTime = 0;
	}
}

defaultproperties
{
}
