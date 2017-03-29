class AiUWindowTabControlItem extends AiUWindowList;

var string					Caption;
var string					HelpText;

var AiUWindowTabControl		Owner;
var float					TabTop;
var float					TabLeft;
var float					TabWidth;
var float					TabHeight;

var int						RowNumber;
var bool					bFlash;

function SetCaption(string NewCaption)
{
	Caption=NewCaption;
}

function RightClickTab()
{
}

defaultproperties
{
}
