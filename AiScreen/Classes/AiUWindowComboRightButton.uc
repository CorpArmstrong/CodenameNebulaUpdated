class AiUWindowComboRightButton extends AiUWindowButton;

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Combo_SetupRightButton(Self);
}

function LMouseDown(float X, float Y)
{
	local int i;

	Super.LMouseDown(X, Y);
	if(!bDisabled)
	{
		i = AiUWindowComboControl(OwnerWindow).GetSelectedIndex();
		i++;
		if(i >= AiUWindowComboControl(OwnerWindow).List.Items.Count())
			i = 0;
		AiUWindowComboControl(OwnerWindow).SetSelectedIndex(i);
	}
}

defaultproperties
{
     bNoKeyboard=True
}
