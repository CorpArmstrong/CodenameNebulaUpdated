class AiUWindowLayoutRow expands AiUWindowLayoutBase;

var AiUWindowLayoutCell	CellList;

function SetupSentinel(optional bool bInTreeSort)
{
	Super.SetupSentinel(bInTreeSort);
	CellList = new class'AiUWindowLayoutCell';
	CellList.SetupSentinel();
}


function AiUWindowLayoutCell AddCell(optional int ColSpan, optional int RowSpan)
{
	local AiUWindowLayoutCell C;

	C = AiUWindowLayoutCell(CellList.Append(class'AiUWindowLayoutCell'));
	C.ColSpan = ColSpan;
	C.RowSpan = RowSpan;

	return C;
}

function float CalcMinHeight()
{

}

defaultproperties
{
}
