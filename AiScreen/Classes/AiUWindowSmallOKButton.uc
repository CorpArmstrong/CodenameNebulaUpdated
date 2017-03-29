class AiUWindowSmallOKButton extends AiUWindowSmallCloseButton;

var localized string OKText;

function Created()
{
	Super.Created();
	SetText(OKText);
}

defaultproperties
{
     OKText="OK"
}
