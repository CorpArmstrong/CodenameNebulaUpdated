class AiUWindowTabControlLeftButton extends AiUWindowButton;

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Tab_SetupLeftButton(Self);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);
	if(!bDisabled)
		AiUWindowTabControl(ParentWindow).TabArea.TabOffset--;
}

defaultproperties
{
     bNoKeyboard=True
}
