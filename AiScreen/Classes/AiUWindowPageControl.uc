class AiUWindowPageControl extends AiUWindowTabControl;

function ResolutionChanged(float W, float H)
{
	local AiUWindowPageControlPage I;

	for(I = AiUWindowPageControlPage(Items.Next); I != None; I = AiUWindowPageControlPage(I.Next))
		if(I.Page != None && I != SelectedTab )
			I.Page.ResolutionChanged(W, H);

	if(SelectedTab != None)
		AiUWindowPageControlPage(SelectedTab).Page.ResolutionChanged(W, H);
}

function NotifyQuitUnreal()
{
	local AiUWindowPageControlPage I;

	for(I = AiUWindowPageControlPage(Items.Next); I != None; I = AiUWindowPageControlPage(I.Next))
		if(I.Page != None)
			I.Page.NotifyQuitUnreal();
}

function NotifyBeforeLevelChange()
{
	local AiUWindowPageControlPage I;

	for(I = AiUWindowPageControlPage(Items.Next); I != None; I = AiUWindowPageControlPage(I.Next))
		if(I.Page != None)
			I.Page.NotifyBeforeLevelChange();
}

function NotifyAfterLevelChange()
{
	local AiUWindowPageControlPage I;

	for(I = AiUWindowPageControlPage(Items.Next); I != None; I = AiUWindowPageControlPage(I.Next))
		if(I.Page != None)
			I.Page.NotifyAfterLevelChange();
}

function GetDesiredDimensions(out float W, out float H)
{
	local float MaxW, MaxH, TW, TH;
	local AiUWindowPageControlPage I;

	MaxW = 0;
	MaxH = 0;

	for(I = AiUWindowPageControlPage(Items.Next); I != None; I = AiUWindowPageControlPage(I.Next))
	{
		if(I.Page != None)
			I.Page.GetDesiredDimensions(TW, TH);

		if(TW > MaxW) MaxW = TW;
		if(TH > MaxH) MaxH = TH;
	}
	W = MaxW;
	H = MaxH + TabArea.WinHeight;
}


function BeforePaint(Canvas C, float X, float Y)
{
	local float OldWinHeight;
	local AiUWindowPageControlPage I;

	OldWinHeight = WinHeight;
	Super.BeforePaint(C, X, Y);
	WinHeight = OldWinHeight;

	for(I = AiUWindowPageControlPage(Items.Next); I != None; I = AiUWindowPageControlPage(I.Next))
		LookAndFeel.Tab_SetTabPageSize(Self, I.Page);
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
	LookAndFeel.Tab_DrawTabPageArea(Self, C, AiUWindowPageControlPage(SelectedTab).Page);
}

function AiUWindowPageControlPage AddPage(string Caption, class<AiUWindowPageWindow> PageClass, optional name ObjectName)
{
	local AiUWindowPageControlPage P;
	P = AiUWindowPageControlPage(AddTab(Caption));
	P.Page = AiUWindowPageWindow(CreateWindow(PageClass, 0,
				TabArea.WinHeight-(LookAndFeel.TabSelectedM.H-LookAndFeel.TabUnselectedM.H),
				WinWidth, WinHeight-(TabArea.WinHeight-(LookAndFeel.TabSelectedM.H-LookAndFeel.TabUnselectedM.H)),,,ObjectName));
	P.Page.OwnerTab = P;

	if(P != SelectedTab)
		P.Page.HideWindow();
	else
	if(AiUWindowPageControlPage(SelectedTab) != None && WindowIsVisible())
	{
		AiUWindowPageControlPage(SelectedTab).Page.ShowWindow();
		AiUWindowPageControlPage(SelectedTab).Page.BringToFront();
	}

	return P;
}

function AiUWindowPageControlPage InsertPage(AiUWindowPageControlPage BeforePage, string Caption, class<AiUWindowPageWindow> PageClass, optional name ObjectName)
{
	local AiUWindowPageControlPage P;

	if(BeforePage == None)
		return AddPage(Caption, PageClass);

	P = AiUWindowPageControlPage(InsertTab(BeforePage, Caption));
	P.Page = AiUWindowPageWindow(CreateWindow(PageClass, 0,
				TabArea.WinHeight-(LookAndFeel.TabSelectedM.H-LookAndFeel.TabUnselectedM.H),
				WinWidth, WinHeight-(TabArea.WinHeight-(LookAndFeel.TabSelectedM.H-LookAndFeel.TabUnselectedM.H)),,,ObjectName));
	P.Page.OwnerTab = P;

	if(P != SelectedTab)
		P.Page.HideWindow();
	else
	if(AiUWindowPageControlPage(SelectedTab) != None && WindowIsVisible())
	{
		AiUWindowPageControlPage(SelectedTab).Page.ShowWindow();
		AiUWindowPageControlPage(SelectedTab).Page.BringToFront();
	}

	return P;
}

function AiUWindowPageControlPage GetPage(string Caption)
{
	return AiUWindowPageControlPage(GetTab(Caption));
}

function DeletePage(AiUWindowPageControlPage P)
{
	P.Page.Close(True);
	P.Page.HideWindow();
	DeleteTab(P);
}

function Close(optional bool bByParent)
{
	local AiUWindowPageControlPage I;

	for(I = AiUWindowPageControlPage(Items.Next); I != None; I = AiUWindowPageControlPage(I.Next))
		if(I.Page != None)
			I.Page.Close(True);

	Super.Close(bByParent);
}

function GotoTab(AiUWindowTabControlItem NewSelected, optional bool bByUser)
{
	local AiUWindowPageControlPage I;

	Super.GotoTab(NewSelected, bByUser);

	for(I = AiUWindowPageControlPage(Items.Next);I != None;I = AiUWindowPageControlPage(I.Next))
	{
		if(I != NewSelected)
			I.Page.HideWindow();
	}

	if(AiUWindowPageControlPage(NewSelected) != None)
		AiUWindowPageControlPage(NewSelected).Page.ShowWindow();
}

function AiUWindowPageControlPage FirstPage()
{
	return AiUWindowPageControlPage(Items.Next);
}

defaultproperties
{
     //ListClass=class'AiUWindow.UWindowPageControlPage'
     ListClass=Class'AiUWindowPageControlPage'
}
