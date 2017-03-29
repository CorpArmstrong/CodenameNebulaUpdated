class AiUWindowLayoutControl extends AiUWindowLayoutBase;

var AiUWindowDialogClientWindow	OwnerWindow;

var float				WinTop;
var float				WinLeft;
var float				WinWidth;
var float				WinHeight;

var float				MinimumWidth;
var float				MinimumHeight;


var AiUWindowLayoutRow	RowList;


// Methods
static function AiUWindowLayoutControl Create()
{
	local AiUWindowLayoutControl C;

	C = new class'AiUWindowLayoutControl';
	C.RowList = new class'AiUWindowLayoutRow';
	C.RowList.SetupSentinel();

	return C;
}


/*
Layout procedure

1.  Calculate minimum (desired) row height by asking
    controls
2.  For each column, work out the minimum (desired) width for this column.
    Then add these up and 
	
	.
2.	If this is less than WinHeight, space cells to fit.
3.	If this is more than WinHeight, adjust parent
    window's DesiredWidth/DesiredHeight variables to cause scrolling.


*/

function PerformLayout()
{
	local AiUWindowLayoutRow R;
	local float TotalWidth;
	local float TotalHeight;

	for(R = AiUWindowLayoutRow(RowList.Next); R != None; R = AiUWindowLayoutRow(R.Next))
		TotalHeight += R.CalcMinHeight();

	
		TotalWidth += R.CalcMinHeight();


}

function AiUWindowLayoutRow AddRow()
{
	return AiUWindowLayoutRow(RowList.Append(class'AiUWindowLayoutRow'));
}

function AiUWindowLayoutCell AddCell(optional int ColSpan, optional int RowSpan)
{
	return RowList.AddCell(ColSpan, RowSpan);
}

defaultproperties
{
}
