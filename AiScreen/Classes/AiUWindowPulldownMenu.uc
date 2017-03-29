//=============================================================================
// AiUWindowPulldownMenu
//=============================================================================


class AiUWindowPulldownMenu extends AiUWindowListControl;

#exec TEXTURE IMPORT NAME=MenuTick FILE=Textures\MenuTick.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuDivider FILE=Textures\MenuDivider.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuSubArrow FILE=Textures\MenuSubArrow.bmp GROUP="Icons" FLAGS=2 MIPS=OFF

var AiUWindowPulldownMenuItem		Selected;

// Owner is either a AiUWindowMenuBarItem or AiUWindowPulldownMenuItem
var AiUWindowList					Owner;

var int ItemHeight;
var int VBorder;
var int HBorder;
var int TextBorder;

// External functions
function AiUWindowPulldownMenuItem AddMenuItem(string C, Texture G)
{
	local AiUWindowPulldownMenuItem I;

	I = AiUWindowPulldownMenuItem(Items.Append(class'AiUWindowPulldownMenuItem'));

	I.Owner = Self;
	I.SetCaption(C);
	I.Graphic = G;

	return I;
}

// Mostly-private funcitons

function Created()
{
	ListClass = class'AiUWindowPulldownMenuItem';
	SetAcceptsFocus();
	Super.Created();
	ItemHeight = LookAndFeel.Pulldown_ItemHeight;
	VBorder = LookAndFeel.Pulldown_VBorder;
	HBorder = LookAndFeel.Pulldown_HBorder;
	TextBorder = LookAndFeel.Pulldown_TextBorder;
}

function Clear()
{
	Items.Clear();
	Selected = None;
}

function DeSelect()
{
	if(Selected != None)
	{
		Selected.DeSelect();
		Selected = None;
	}
}

function Select(AiUWindowPulldownMenuItem I)
{
}

function PerformSelect(AiUWindowPulldownMenuItem NewSelected)
{
	if(Selected != None && NewSelected != Selected) Selected.DeSelect();

	if(NewSelected == None)
	{
		Selected = None;
	}
	else
	{
		if(Selected != NewSelected && NewSelected.Caption != "-" && !NewSelected.bDisabled)
			LookAndFeel.PlayMenuSound(Self, MS_MenuItem);

		Selected = NewSelected;
		if(Selected != None)
		{
			Selected.Select();
			Select(Selected);
		}
	}
}

function SetSelected(float X, float Y)
{
	local AiUWindowPulldownMenuItem NewSelected;

	NewSelected = AiUWindowPulldownMenuItem(Items.FindEntry((Y - VBorder) / ItemHeight));

	PerformSelect(NewSelected);
}

function ShowWindow()
{
	local AiUWindowPulldownMenuItem I;
	Super.ShowWindow();
	PerformSelect(None);
	FocusWindow();
}

function MouseMove(float X, float Y)
{
	Super.MouseMove(X, Y);
	SetSelected(X, Y);
	FocusWindow();
}

function LMouseUp(float X, float Y)
{
	If(Selected != None && Selected.Caption != "-" && !Selected.bDisabled)
	{
		BeforeExecuteItem(Selected);
		ExecuteItem(Selected);
	}
	Super.LMouseUp(X, Y);
}

function LMouseDown(float X, float Y)
{
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, MaxWidth;
	local int Count;
	local AiUWindowPulldownMenuItem I;


	MaxWidth = 100;
	Count = 0;

	C.Font = Root.Fonts[F_Normal];
	C.SetPos(0, 0);

	for( I = AiUWindowPulldownMenuItem(Items.Next);I != None; I = AiUWindowPulldownMenuItem(I.Next) )
	{
		Count++;
		TextSize(C, RemoveAmpersand(I.Caption), W, H);
		if(W > MaxWidth) MaxWidth = W;
	}

	WinWidth = MaxWidth + ((HBorder + TextBorder) * 2);
	WinHeight = (ItemHeight * Count) + (VBorder * 2);

	// Take care of bHelp items
	if(	((AiUWindowMenuBarItem(Owner) != None) && (AiUWindowMenuBarItem(Owner).bHelp)) ||
		WinLeft+WinWidth > ParentWindow.WinWidth )
	{
		WinLeft = ParentWindow.WinWidth - WinWidth;
	}

	if(AiUWindowPulldownMenuItem(Owner) != None)
	{
		I = AiUWindowPulldownMenuItem(Owner);

		if(WinWidth + WinLeft > ParentWindow.WinWidth)
			WinLeft = I.Owner.WinLeft + I.Owner.HBORDER - WinWidth;
	}
}

function Paint(Canvas C, float X, float Y)
{
	local int Count;
	local AiUWindowPulldownMenuItem I;

	DrawMenuBackground(C);

	Count = 0;

	for( I = AiUWindowPulldownMenuItem(Items.Next);I != None; I = AiUWindowPulldownMenuItem(I.Next) )
	{
		DrawItem(C, I, HBorder, VBorder + (ItemHeight * Count), WinWidth - (2 * HBorder), ItemHeight);
		Count++;
	}
}

function DrawMenuBackground(Canvas C)
{
	LookAndFeel.Menu_DrawPulldownMenuBackground(Self, C);
}

function DrawItem(Canvas C, AiUWindowList Item, float X, float Y, float W, float H)
{
	LookAndFeel.Menu_DrawPulldownMenuItem(Self, AiUWindowPulldownMenuItem(Item), C, X, Y, W, H, Selected == Item);
}

function BeforeExecuteItem(AiUWindowPulldownMenuItem I)
{
	LookAndFeel.PlayMenuSound(Self, MS_WindowOpen);
}

function ExecuteItem(AiUWindowPulldownMenuItem I)
{
	CloseUp();
}

function CloseUp(optional bool bByOwner)
{
	local AiUWindowPulldownMenuItem I;

	// tell our owners to close up
	if(!bByOwner)
	{
		if(AiUWindowPulldownMenuItem(Owner) != None)  AiUWindowPulldownMenuItem(Owner).CloseUp();
		if(AiUWindowMenuBarItem(Owner) != None)  AiUWindowMenuBarItem(Owner).CloseUp();
	}

	// tell our children to close up
	for( I = AiUWindowPulldownMenuItem(Items.Next);I != None; I = AiUWindowPulldownMenuItem(I.Next) )
		if(I.SubMenu != None)
			I.SubMenu.CloseUp(True);
}

function AiUWindowMenuBar GetMenuBar()
{
	if(AiUWindowPulldownMenuItem(Owner) != None) return AiUWindowPulldownMenuItem(Owner).GetMenuBar();
	if(AiUWindowMenuBarItem(Owner) != None) return AiUWindowMenuBarItem(Owner).GetMenuBar();
}

function FocusOtherWindow(AiUWindowWindow W)
{
	Super.FocusOtherWindow(W);

	if(Selected != None)
		if(W == Selected.SubMenu) return;

	if(AiUWindowPulldownMenuItem(Owner) != None)
		if(AiUWindowPulldownMenuItem(Owner).Owner == W) return;

	if(bWindowVisible)
		CloseUp();
}

function KeyDown(int Key, float X, float Y)
{
	local AiUWindowPulldownMenuItem I;

	I = Selected;

	switch(Key)
	{
	case 0x26: // Up
		if(I == None || I == Items.Next)
			I = AiUWindowPulldownMenuItem(Items.Last);
		else
			I = AiUWindowPulldownMenuItem(I.Prev);

		if(I == None)
			I = AiUWindowPulldownMenuItem(Items.Last);
		else
			if(I.Caption == "-")
				I = AiUWindowPulldownMenuItem(I.Prev);

		if(I == None)
			I = AiUWindowPulldownMenuItem(Items.Last);

		if(I.SubMenu == None)
			PerformSelect(I);
		else
			Selected = I;

		break;
	case 0x28: // Down
		if(I == None)
			I = AiUWindowPulldownMenuItem(Items.Next);
		else
			I = AiUWindowPulldownMenuItem(I.Next);

		if(I == None)
			I = AiUWindowPulldownMenuItem(Items.Next);
		else
			if(I.Caption == "-")
				I = AiUWindowPulldownMenuItem(I.Next);

		if(I == None)
			I = AiUWindowPulldownMenuItem(Items.Next);

		if(I.SubMenu == None)
			PerformSelect(I);
		else
			Selected = I;

		break;
	case 0x25: // Left
		if(AiUWindowPulldownMenuItem(Owner) != None)
		{
			 AiUWindowPulldownMenuItem(Owner).Owner.PerformSelect(None);
			 AiUWindowPulldownMenuItem(Owner).Owner.Selected = AiUWindowPulldownMenuItem(Owner);
		}
		if(AiUWindowMenuBarItem(Owner) != None)
			AiUWindowMenuBarItem(Owner).Owner.KeyDown(Key, X, Y);
		break;
	case 0x27: // Right
		if(I != None && I.SubMenu != None)
		{
			Selected = None;
			PerformSelect(I);
			I.SubMenu.Selected = AiUWindowPulldownMenuItem(I.SubMenu.Items.Next);
		}
		else
		{
			if(AiUWindowPulldownMenuItem(Owner) != None)
			{
				AiUWindowPulldownMenuItem(Owner).Owner.PerformSelect(None);
				AiUWindowPulldownMenuItem(Owner).Owner.KeyDown(Key, X, Y);
			}
			if(AiUWindowMenuBarItem(Owner) != None)
				AiUWindowMenuBarItem(Owner).Owner.KeyDown(Key, X, Y);
		}
		break;
	case 0x0D: // Enter
		if(I.SubMenu != None)
		{
			Selected = None;
			PerformSelect(I);
		}
		else
			if(Selected != None && Selected.Caption != "-" && !Selected.bDisabled)
			{
				BeforeExecuteItem(Selected);
				ExecuteItem(Selected);
			}
		break;
	default:
	}
}

function KeyUp(int Key, float X, float Y)
{
	local AiUWindowPulldownMenuItem I;

	if(Key >= 0x41 && Key <= 0x60)
	{
		// Check for hotkeys in each menu item
		for( I = AiUWindowPulldownMenuItem(Items.Next);I != None; I = AiUWindowPulldownMenuItem(I.Next) )
		{
			if(Key == I.HotKey)
			{
				PerformSelect(I);
				if(I != None && I.Caption != "-" && !I.bDisabled)
				{
					BeforeExecuteItem(I);
					ExecuteItem(I);
				}
			}
		}
	}
}

function MenuCmd(int Item)
{
	local int j;
	local AiUWindowPulldownMenuItem I;

	for( I = AiUWindowPulldownMenuItem(Items.Next);I != None; I = AiUWindowPulldownMenuItem(I.Next) )
	{
		if(j == Item)
		{
			PerformSelect(I);
			if( I.Caption != "-" && !I.bDisabled )
			{
				BeforeExecuteItem(I);
				ExecuteItem(I);
			}
			return;
		}
		j++;
	}
}

defaultproperties
{
     bAlwaysOnTop=True
}
