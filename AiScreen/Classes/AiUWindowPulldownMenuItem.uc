//=============================================================================
// AiUWindowPulldownMenuItem
//=============================================================================

class AiUWindowPulldownMenuItem extends AiUWindowList;

var string					Caption;
var Texture					Graphic;
var byte					HotKey;

var AiUWindowPulldownMenu		SubMenu;
var	bool					bChecked;
var	bool					bDisabled;

var AiUWindowPulldownMenu		Owner;
var float					ItemTop;

function AiUWindowPulldownMenu CreateSubMenu(class<AiUWindowPulldownMenu> MenuClass, optional AiUWindowWindow InOwnerWindow)
{
	SubMenu = AiUWindowPulldownMenu(Owner.ParentWindow.CreateWindow(MenuClass, 0, 0, 100, 100, InOwnerWindow));
	SubMenu.HideWindow();
	SubMenu.Owner = Self;
	return SubMenu;
}

function Select()
{
	if(SubMenu != None)
	{
		SubMenu.WinLeft = Owner.WinLeft + Owner.WinWidth - Owner.HBORDER;
		SubMenu.WinTop = ItemTop - Owner.VBORDER;

		SubMenu.ShowWindow();
	}
}

function SetCaption(string C)
{
	local string Junk, Junk2;

	Caption = C;
	HotKey = Owner.ParseAmpersand(C, Junk, Junk2, False);
}

function DeSelect()
{
	if(SubMenu != None)
	{
		SubMenu.DeSelect();
		SubMenu.HideWindow();
	}
}

function CloseUp()
{
	Owner.CloseUp();
}

function AiUWindowMenuBar GetMenuBar()
{
	return Owner.GetMenuBar();
}

defaultproperties
{
}
