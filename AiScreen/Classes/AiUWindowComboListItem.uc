class AiUWindowComboListItem extends AiUWindowList;

var string					Value;
var string					Value2;		// A second, non-displayed value
var int						SortWeight;

var float					ItemTop;

function int Compare(AiUWindowList T, AiUWindowList B)
{
	local AiUWindowComboListItem TI, BI;
	local string TS, BS;

	TI = AiUWindowComboListItem(T);
	BI = AiUWindowComboListItem(B);

	if(TI.SortWeight == BI.SortWeight)
	{
		TS = caps(TI.Value);
		BS = caps(BI.Value);

		if(TS == BS)
			return 0;

		if(TS < BS)
			return -1;

		return 1;

	}
	else
		return TI.SortWeight - BI.SortWeight;
}

defaultproperties
{
}
