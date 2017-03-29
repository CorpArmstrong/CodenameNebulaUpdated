class AiUWindowHotkeyWindowList extends AiUWindowList;


var AiUWindowWindow		Window;


function AiUWindowHotkeyWindowList FindWindow(AiUWindowWindow W)
{
	local AiUWindowHotkeyWindowList l;

	l = AiUWindowHotkeyWindowList(Next);
	while(l != None) 
	{
		if(l.Window == W) return l;
		l = AiUWindowHotkeyWindowList(l.Next);
	}
	return None;
}

defaultproperties
{
}
