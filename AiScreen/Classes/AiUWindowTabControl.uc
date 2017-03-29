class AiUWindowTabControl extends AiUWindowListControl;

var AiUWindowTabControlLeftButton		LeftButton;
var AiUWindowTabControlRightButton	RightButton;
var AiUWindowTabControlTabArea		TabArea;
var AiUWindowTabControlItem			SelectedTab;

var bool							bMultiLine;
var bool							bSelectNearestTabOnRemove;

function Created()
{
	Super.Created();

	SelectedTab = None;

	TabArea = AiUWindowTabControlTabArea(CreateWindow(class'AiUWindowTabControlTabArea',
					0, 0, WinWidth - LookAndFeel.Size_ScrollbarWidth
						- LookAndFeel.Size_ScrollbarWidth - 10,
					 LookAndFeel.Size_TabAreaHeight+LookAndFeel.Size_TabAreaOverhangHeight));

	TabArea.bAlwaysOnTop = True;

	LeftButton = AiUWindowTabControlLeftButton(CreateWindow(class'AiUWindowTabControlLeftButton', WinWidth-20, 0, 10, 12));
	RightButton = AiUWindowTabControlRightButton(CreateWindow(class'AiUWindowTabControlRightButton', WinWidth-10, 0, 10, 12));
}

function BeforePaint(Canvas C, float X, float Y)
{
	TabArea.WinTop = 0;
	TabArea.WinLeft = 0;

	if(bMultiLine)
		TabArea.WinWidth = WinWidth;
	else
		TabArea.WinWidth = WinWidth - LookAndFeel.Size_ScrollbarWidth - LookAndFeel.Size_ScrollbarWidth - 10;

	TabArea.LayoutTabs(C);
	WinHeight = (LookAndFeel.Size_TabAreaHeight * TabArea.TabRows) + LookAndFeel.Size_TabAreaOverhangHeight;
	TabArea.WinHeight = WinHeight;

	Super.BeforePaint(C, X, Y);
}

function SetMultiLine(bool InMultiLine)
{
	bMultiLine = InMultiLine;

	if(bMultiLine)
	{
		LeftButton.HideWindow();
		RightButton.HideWindow();
	}
	else
	{
		LeftButton.ShowWindow();
		RightButton.ShowWindow();
	}
}

function Paint(Canvas C, float X, float Y)
{
	local Region R;
	local Texture T;

	T = GetLookAndFeelTexture();
	R = LookAndFeel.TabBackground;
	DrawStretchedTextureSegment( C, 0, 0, WinWidth, LookAndFeel.Size_TabAreaHeight * TabArea.TabRows, R.X, R.Y, R.W, R.H, T );
}

function AiUWindowTabControlItem AddTab(string Caption)
{
	local AiUWindowTabControlItem I;

	I = AiUWindowTabControlItem(Items.Append(ListClass));

	I.Owner = Self;
	I.SetCaption(Caption);

	if(SelectedTab == None)
		SelectedTab = I;

	return I;
}

function AiUWindowTabControlItem InsertTab(AiUWindowTabControlItem BeforeTab, string Caption)
{
	local AiUWindowTabControlItem I;

	I = AiUWindowTabControlItem(BeforeTab.InsertBefore(ListClass));

	I.Owner = Self;
	I.SetCaption(Caption);

	if(SelectedTab == None)
		SelectedTab = I;

	return I;
}

function GotoTab( AiUWindowTabControlItem NewSelected, optional bool bByUser )
{
	if(SelectedTab != NewSelected && bByUser)
		LookAndFeel.PlayMenuSound(Self, MS_ChangeTab);
	SelectedTab = NewSelected;
	TabArea.bShowSelected = True;
}

function AiUWindowTabControlItem GetTab( string Caption )
{
	local AiUWindowTabControlItem I;
	for(I = AiUWindowTabControlItem(Items.Next); I != None; I = AiUWindowTabControlItem(I.Next))
	{
		if(I.Caption == Caption) return I;
	}

	return None;
}

function DeleteTab( AiUWindowTabControlItem Tab )
{
	local AiUWindowTabControlItem NextTab;
	local AiUWindowTabControlItem PrevTab;

	NextTab = AiUWindowTabControlItem(Tab.Next);
	PrevTab = AiUWindowTabControlItem(Tab.Prev);
	Tab.Remove();

	if(SelectedTab == Tab)
	{
		if(bSelectNearestTabOnRemove)
		{
			Tab = NextTab;
			if(Tab == None)
				Tab = PrevTab;

			GotoTab(Tab);
		}
		else
			GotoTab(AiUWindowTabControlItem(Items.Next));
	}
}

defaultproperties
{
     ListClass=class'AiUWindow.UWindowTabControlItem'
}
