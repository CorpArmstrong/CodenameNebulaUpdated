//=============================================================================
// AiUWindowListControl - Abstract class for list controls
//	- List boxes
//	- Dropdown Menus
//	- Combo Boxes, etc
//=============================================================================
class AiUWindowListControl extends AiUWindowDialogControl;

var class<AiUWindowList>	ListClass;
var AiUWindowList			Items;

function DrawItem(Canvas C, AiUWindowList Item, float X, float Y, float W, float H)
{
	// Declared in Subclass
}

function Created()
{
	Super.Created();

	Items = New ListClass;
	Items.Last = Items;
	Items.Next = None;
	Items.Prev = None;
	Items.Sentinel = Items;
}

defaultproperties
{
}
