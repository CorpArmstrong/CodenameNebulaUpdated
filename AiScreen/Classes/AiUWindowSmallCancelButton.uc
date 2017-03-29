class AiUWindowSmallCancelButton extends AiUWindowButton;

var localized string CancelText;

function Created()
{
	Super.Created();
	SetText(CancelText);
}

defaultproperties
{
     CancelText="Cancel"
}
