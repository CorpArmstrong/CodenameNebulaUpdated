class AiUWindowPageControlPage extends AiUWindowTabControlItem;

var AiUWindowPageWindow	Page;

function RightClickTab()
{
	Page.RightClickTab();
}

function AiUWindowPageControlPage NextPage()
{
	return AiUWindowPageControlPage(Next);
}

defaultproperties
{
}
