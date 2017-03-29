class AiUWindowLookAndFeel extends AiUWindowBase;

var() Texture	Active;			// Active widgets, window frames, etc.
var() Texture	Inactive;		// Inactive Widgets, window frames, etc.
var() Texture	ActiveS;
var() Texture	InactiveS;

var() Texture	Misc;			// Miscellaneous: backgrounds, bevels, etc.

var() Region	FrameTL;
var() Region	FrameT;
var() Region	FrameTR;

var() Region	FrameL;
var() Region	FrameR;

var() Region	FrameBL;
var() Region	FrameB;
var() Region	FrameBR;

var() Color		FrameActiveTitleColor;
var() Color		FrameInactiveTitleColor;
var() Color		HeadingActiveTitleColor;
var() Color		HeadingInActiveTitleColor;

var() int		FrameTitleX;
var() int		FrameTitleY;

var() Region	BevelUpTL;
var() Region	BevelUpT;
var() Region	BevelUpTR;

var() Region	BevelUpL;
var() Region	BevelUpR;

var() Region	BevelUpBL;
var() Region	BevelUpB;
var() Region	BevelUpBR;
var() Region	BevelUpArea;


var() Region	MiscBevelTL[4];
var() Region	MiscBevelT[4];
var() Region	MiscBevelTR[4];
var() Region	MiscBevelL[4];
var() Region	MiscBevelR[4];
var() Region	MiscBevelBL[4];
var() Region	MiscBevelB[4];
var() Region	MiscBevelBR[4];
var() Region	MiscBevelArea[4];

var() Region	ComboBtnUp;
var() Region	ComboBtnDown;
var() Region	ComboBtnDisabled;

var() int		ColumnHeadingHeight;
var() Region	HLine;

var() Color		EditBoxTextColor;
var() int		EditBoxBevel;

var() Region	TabSelectedL;
var() Region	TabSelectedM;
var() Region	TabSelectedR;

var() Region	TabUnselectedL;
var() Region	TabUnselectedM;
var() Region	TabUnselectedR;

var() Region	TabBackground;


var() float		Size_ScrollbarWidth;
var() float		Size_ScrollbarButtonHeight;		// Interchange W and H for horizontal SB's
var() float		Size_MinScrollbarHeight;

var() float		Size_TabAreaHeight;				// The height of the clickable tab area
var() float		Size_TabAreaOverhangHeight;		// The height of the tab area overhang
var() float		Size_TabSpacing;
var() float		Size_TabXOffset;

var() float		Pulldown_ItemHeight;
var() float		Pulldown_VBorder;
var() float		Pulldown_HBorder;
var() float		Pulldown_TextBorder;

function Texture GetTexture(AiUWindowFramedWindow W)
{
	if(W.bStatusBar)
	{
		if(W.IsActive())
			return ActiveS;
		else
			return InactiveS;
	}
	else
	{
		if(W.IsActive())
			return Active;
		else
			return Inactive;
	}
}

/* Setup Functions */
function Setup();
function FW_DrawWindowFrame(AiUWindowFramedWindow W, Canvas C);
function Region FW_GetClientArea(AiUWindowFramedWindow W);
function FrameHitTest FW_HitTest(AiUWindowFramedWindow W, float X, float Y);
function FW_SetupFrameButtons(AiUWindowFramedWindow W, Canvas C);
function DrawClientArea(AiUWindowClientWindow W, Canvas C);
function Combo_SetupSizes(AiUWindowComboControl W, Canvas C);
function Combo_Draw(AiUWindowComboControl W, Canvas C);
function Combo_GetButtonBitmaps(AiUWindowComboButton W);
function Combo_SetupLeftButton(AiUWindowComboLeftButton W);
function Combo_SetupRightButton(AiUWindowComboRightButton W);
function Checkbox_SetupSizes(AiUWindowCheckbox W, Canvas C);
function Checkbox_Draw(AiUWindowCheckbox W, Canvas C);
function ComboList_DrawBackground(AiUWindowComboList W, Canvas C);
function ComboList_DrawItem(AiUWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected);
function Editbox_SetupSizes(AiUWindowEditControl W, Canvas C);
function Editbox_Draw(AiUWindowEditControl W, Canvas C);
function SB_SetupUpButton(AiUWindowSBUpButton W);
function SB_SetupDownButton(AiUWindowSBDownButton W);
function SB_SetupLeftButton(AiUWindowSBLeftButton W);
function SB_SetupRightButton(AiUWindowSBRightButton W);
function SB_VDraw(AiUWindowVScrollbar W, Canvas C);
function SB_HDraw(AiUWindowHScrollbar W, Canvas C);
function Tab_DrawTab(AiUWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText);
function Tab_GetTabSize(AiUWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H);
function Tab_SetupLeftButton(AiUWindowTabControlLeftButton W);
function Tab_SetupRightButton(AiUWindowTabControlRightButton W);
function Tab_SetTabPageSize(AiUWindowPageControl W, AiUWindowPageWindow P);
function Tab_DrawTabPageArea(AiUWindowPageControl W, Canvas C, AiUWindowPageWindow P);
function Menu_DrawMenuBar(AiUWindowMenuBar W, Canvas C);
function Menu_DrawMenuBarItem(AiUWindowMenuBar B, AiUWindowMenuBarItem I, float X, float Y, float W, float H, Canvas C);
function Menu_DrawPulldownMenuBackground(AiUWindowPulldownMenu W, Canvas C);
function Menu_DrawPulldownMenuItem(AiUWindowPulldownMenu M, AiUWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected);
function Button_DrawSmallButton(AiUWindowSmallButton B, Canvas C);
function PlayMenuSound(AiUWindowWindow W, MenuSound S);
function ControlFrame_SetupSizes(AiUWindowControlFrame W, Canvas C);
function ControlFrame_Draw(AiUWindowControlFrame W, Canvas C);

defaultproperties
{
}
