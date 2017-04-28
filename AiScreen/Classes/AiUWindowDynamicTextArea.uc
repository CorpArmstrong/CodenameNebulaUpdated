class AiUWindowDynamicTextArea expands AiUWindowDialogControl;

var config int MaxLines;

var bool bTopCentric;
var float DefaultTextHeight;
var bool bScrollOnResize;
var bool bVCenter;
var bool bHCenter;
var bool bAutoScrollbar;
var bool bVariableRowHeight;	// Assumes !bTopCentric, !bScrollOnResize
var float WrapWidth;

// private
var AiUWindowDynamicTextRow List;
var AiUWindowVScrollBar VertSB;
var float OldW, OldH;
var bool bDirty;
var int Count;
var int VisibleRows;
var int Font;
var Font AbsoluteFont;
var color TextColor;
var class<AiUWindowDynamicTextRow> RowClass;

function Created()
{
	Super.Created();

	VertSB = AiUWindowVScrollbar(CreateWindow(class'AiUWindowVScrollbar', WinWidth-12, 0, 12, WinHeight));
	VertSB.bAlwaysOnTop = True;

	Clear();
}

function Clear()
{
	bDirty = True;

	if(List != None)
	{
		if(List.Next == None)
			return;
		List.DestroyList();
	}

	List = new RowClass;
	List.SetupSentinel();
}

function SetAbsoluteFont(Font F)
{
	AbsoluteFont = F;
}

function SetFont(int F)
{
	Font = F;
}

function SetTextColor(Color C)
{
	TextColor = C;
}

function TextAreaClipText(Canvas C, float DrawX, float DrawY, coerce string S, optional bool bCheckHotkey)
{
	ClipText(C, DrawX, DrawY, S, bCheckHotkey);
}

function TextAreaTextSize(Canvas C, string Text, out float W, out float H)
{
	TextSize(C, Text, W, H);
}

function BeforePaint( Canvas C, float X, float Y )
{
	Super.BeforePaint(C, X, Y);

	VertSB.WinTop = 0;
	VertSB.WinHeight = WinHeight;
	VertSB.WinWidth = LookAndFeel.Size_ScrollbarWidth;
	VertSB.WinLeft = WinWidth - LookAndFeel.Size_ScrollbarWidth;
}

function Paint( Canvas C, float MouseX, float MouseY )
{
	local AiUWindowDynamicTextRow L;
	local int SkipCount, DrawCount;
	local int i;
	local float Y, Junk;
	local bool bWrapped;

	C.DrawColor = TextColor;

	if(AbsoluteFont != None)
		C.Font = AbsoluteFont;
	else
		C.Font = Root.Fonts[Font];

	if(OldW != WinWidth || OldH != WinHeight)
	{
		WordWrap(C, True);
		OldW = WinWidth;
		OldH = WinHeight;
		bWrapped = True;
	}
	else
	if(bDirty)
	{
		WordWrap(C, False);
		bWrapped = True;
	}

	if(bWrapped)
	{
		TextAreaTextSize(C, "A", Junk, DefaultTextHeight);
		VisibleRows = WinHeight / DefaultTextHeight;
		Count = List.Count();
		VertSB.SetRange(0, Count, VisibleRows);

		if(bScrollOnResize)
		{
			if(bTopCentric)
				VertSB.Pos = 0;
			else
				VertSB.Pos = VertSB.MaxPos;
		}

		if(bAutoScrollbar && !bVariableRowHeight)
		{
			if(Count <= VisibleRows)
				VertSB.HideWindow();
			else
				VertSB.ShowWindow();
		}
	}

	if(bTopCentric)
	{
		SkipCount = VertSB.Pos;
		L = AiUWindowDynamicTextRow(List.Next);
		for(i=0; i < SkipCount && (L != None) ; i++)
			L = AiUWindowDynamicTextRow(L.Next);

		if(bVCenter && Count <= VisibleRows)
			Y = int((WinHeight - (Count * DefaultTextHeight)) / 2);
		else
			Y = 1;

		DrawCount = 0;
		while(Y < WinHeight)
		{
			DrawCount++;
			if(L != None)
			{
				Y += DrawTextLine(C, L, Y);
				L = AiUWindowDynamicTextRow(L.Next);
			}
			else
				Y += DefaultTextHeight;
		}

		if(bVariableRowHeight)
		{
			VisibleRows = DrawCount - 1;

			while(VertSB.Pos + VisibleRows > Count)
				VisibleRows--;

			VertSB.SetRange(0, Count, VisibleRows);

			if(bAutoScrollbar)
			{
				if(Count <= VisibleRows)
					VertSB.HideWindow();
				else
					VertSB.ShowWindow();
			}
		}
	}
	else
	{
		SkipCount = Max(0, Count - (VisibleRows + VertSB.Pos));
		L = AiUWindowDynamicTextRow(List.Last);
		for(i=0; i < SkipCount && (L != List) ; i++)
			L = AiUWindowDynamicTextRow(L.Prev);

		Y = WinHeight - DefaultTextHeight;
		while(L != List && L != None && Y > -DefaultTextHeight)
		{
			DrawTextLine(C, L, Y);
			Y = Y - DefaultTextHeight;
			L = AiUWindowDynamicTextRow(L.Prev);
		}
	}
}

function AiUWindowDynamicTextRow AddText(string NewLine)
{
	local AiUWindowDynamicTextRow L;
	local string Temp;
	local int i;

	bDirty = True;

	i = InStr(NewLine, "\\n");
	if(i != -1)
	{
		Temp = Mid(NewLine, i+2);
		NewLine = Left(NewLine, i);
	}
	else
		Temp = "";


	// reuse a row if possible
	L = CheckMaxRows();

	if(L != None)
		List.AppendItem(L);
	else
		L = AiUWindowDynamicTextRow(List.Append(RowClass));

	L.Text = NewLine;
	L.WrapParent = None;
	L.bRowDirty = True;

	if(Temp != "")
		AddText(Temp);

	return L;
}

function AiUWindowDynamicTextRow CheckMaxRows()
{
	local AiUWindowDynamicTextRow L;
	L = None;
	while(MaxLines > 0 && List.Count() > MaxLines - 1 && List.Next != None)
	{
		L = AiUWindowDynamicTextRow(List.Next);
		RemoveWrap(L);
		L.Remove();
	}
	return L;
}

function WordWrap(Canvas C, bool bForce)
{
	local AiUWindowDynamicTextRow L;

	for(L = AiUWindowDynamicTextRow(List.Next); L != None; L = AiUWindowDynamicTextRow(L.Next))
		if(L.WrapParent == None && (L.bRowDirty || bForce))
			WrapRow(C, L);

	bDirty = False;
}

function WrapRow(Canvas C, AiUWindowDynamicTextRow L)
{
	local AiUWindowDynamicTextRow CurrentRow, N;
	local float MaxWidth;
	local int WrapPos;

	if(WrapWidth == 0)
	{
		if(VertSB.bWindowVisible || bAutoScrollbar)
			MaxWidth = WinWidth - VertSB.WinWidth;
		else
			MaxWidth = WinWidth;
	}
	else
		MaxWidth = WrapWidth;

	L.bRowDirty = False;

	// fast check - single line?
	N = AiUWindowDynamicTextRow(L.Next);
	if(N == None || N.WrapParent != L)
	{
		if(GetWrapPos(C, L, MaxWidth) == -1)
			return;
	}

	RemoveWrap(L);
	CurrentRow = L;

	while(True)
	{
		WrapPos = GetWrapPos(C, CurrentRow, MaxWidth);
		if(WrapPos == -1)
			break;

		CurrentRow = SplitRowAt(CurrentRow, WrapPos);
	}
}

///////////////////////////////////////////////////////
// Functions to override to change format/layout
///////////////////////////////////////////////////////

function float DrawTextLine(Canvas C, AiUWindowDynamicTextRow L, float Y)
{
	local float X, W, H;

	if(bHCenter)
	{
		TextAreaTextSize(C, L.Text, W, H);
		if(VertSB.bWindowVisible)
			X = int(((WinWidth - VertSB.WinWidth) - W) / 2);
		else
			X = int((WinWidth - W) / 2);
	}
	else
		X = 2;
	TextAreaClipText(C, X, Y, L.Text);

	return DefaultTextHeight;
}


// find where to break the line
function int GetWrapPos(Canvas C, AiUWindowDynamicTextRow L, float MaxWidth)
{
	local float W, H, LineWidth, NextWordWidth;
	local string Input, NextWord;
	local int WordsThisRow, WrapPos;

	// quick check
	TextAreaTextSize(C, L.Text, W, H);
	if(W <= MaxWidth)
		return -1;

	Input = L.Text;
	WordsThisRow = 0;
	LineWidth = 0;
	WrapPos = 0;
	NextWord = "";

	while(Input != "" || NextWord != "")
	{
		if(NextWord == "")
		{
			RemoveNextWord(Input, NextWord);
			TextAreaTextSize(C, NextWord, NextWordWidth, H);
		}
		if(WordsThisRow > 0 && LineWidth + NextWordWidth > MaxWidth)
		{
			return WrapPos;
		}
		else
		{
			WrapPos += Len(NextWord);
			LineWidth += NextWordWidth;
			NextWord = "";
			WordsThisRow++;
		}
	}
	return -1;
}

function AiUWindowDynamicTextRow SplitRowAt(AiUWindowDynamicTextRow L, int SplitPos)
{
	local AiUWindowDynamicTextRow N;

	N = AiUWindowDynamicTextRow(L.InsertAfter(RowClass));

	if(L.WrapParent == None)
		N.WrapParent = L;
	else
		N.WrapParent = L.WrapParent;

	N.Text = Mid(L.Text, SplitPos);
	L.Text = Left(L.Text, SplitPos);

	return N;
}

function RemoveNextWord(out string Text, out string NextWord)
{
	local int i;

	i = InStr(Text, " ");
	if(i == -1)
	{
		NextWord = Text;
		Text = "";
	}
	else
	{
		while(Mid(Text, i, 1) == " ")
			i++;

		NextWord = Left(Text, i);
		Text = Mid(Text, i);
	}
}

function RemoveWrap(AiUWindowDynamicTextRow L)
{
	local AiUWindowDynamicTextRow N;

	// Remove previous word-wrapping
	N = AiUWindowDynamicTextRow(L.Next);
	while(N != None && N.WrapParent == L)
	{
		L.Text = L.Text $ N.Text;
		N.Remove();
		N = AiUWindowDynamicTextRow(L.Next);
	}
}

defaultproperties
{
     bScrollOnResize=True
     TextColor=(R=255,G=255,B=255)
     RowClass=class'AiUWindow.UWindowDynamicTextRow'
     bNoKeyboard=True
}