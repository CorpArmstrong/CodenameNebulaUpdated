class AiUWindowSmallCloseButton extends AiUWindowSmallButton;

var localized string CloseText;

function Created()
{
	Super.Created();
	SetText(CloseText);
}

function Click(float X, float Y)
{
	AiUWindowFramedWindow(GetParent(class'AiUWindowFramedWindow')).Close();
}

defaultproperties
{
     CloseText="Close"
}
