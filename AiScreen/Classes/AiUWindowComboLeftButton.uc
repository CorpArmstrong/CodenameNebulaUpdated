class AiUWindowComboLeftButton extends AiUWindowButton;

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Combo_SetupLeftButton(Self);
}

function LMouseDown(float X, float Y)
{
	local int i;

	Super.LMouseDown(X, Y);
	if(!bDisabled)
	{
		i = AiUWindowComboControl(OwnerWindow).GetSelectedIndex();
		i--;
		if(i < 0)
			i = AiUWindowComboControl(OwnerWindow).List.Items.Count() - 1;
		AiUWindowComboControl(OwnerWindow).SetSelectedIndex(i);
	}
}

defaultproperties
{
     bNoKeyboard=True
}
