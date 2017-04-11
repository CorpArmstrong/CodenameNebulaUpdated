//=============================================================================
// IwHUDActiveItemsDisplay
//=============================================================================

class IwHUDActiveItemsDisplay extends HUDActiveItemsDisplay;

var IwHUDActiveAugsBorder  testwinAugsContainer;
var IwHUDActiveItemsBorder testwinItemsContainer;


// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	CreateContainerWindows();

	Hide();
}



// ----------------------------------------------------------------------
// CreateContainerWindows()
// ----------------------------------------------------------------------

function CreateContainerWindows()
{
	testwinAugsContainer  = IwHUDActiveAugsBorder(NewChild(Class'IwHUDActiveAugsBorder'));
	testwinItemsContainer = IwHUDActiveItemsBorder(NewChild(Class'IwHUDActiveItemsBorder'));
}


// ----------------------------------------------------------------------
// AddIcon()
// ----------------------------------------------------------------------

function AddIcon(Texture newIcon, Object saveObject)
{
	//local TestHUDActiveItem activeItem;

	if (saveObject.IsA('Augmentation'))
		testwinAugsContainer.AddIcon(newIcon, saveObject);
	else
		testwinItemsContainer.AddIcon(newIcon, saveObject);

	AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// RemoveIcon()
// ----------------------------------------------------------------------

function RemoveIcon(Object removeObject)
{
	if (removeObject.IsA('Augmentation'))
		testwinAugsContainer.RemoveObject(removeObject);
	else
		testwinItemsContainer.RemoveObject(removeObject);

	AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// UpdateAugIconStatus()
// ----------------------------------------------------------------------

function UpdateAugIconStatus(Augmentation aug)
{
	testwinAugsContainer.UpdateAugIconStatus(aug);
}

// ----------------------------------------------------------------------
// ClearAugmentationDisplay()
// ----------------------------------------------------------------------

function ClearAugmentationDisplay()
{
	testwinAugsContainer.ClearAugmentationDisplay();
}

// ----------------------------------------------------------------------
// SetVisibility()
//
// Only show if one or more icons is being displayed
// ----------------------------------------------------------------------

function SetVisibility( bool bNewVisibility )
{
	Show(bNewVisibility);

	AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// ParentRequestedPreferredSize()
// ----------------------------------------------------------------------

event ParentRequestedPreferredSize(bool bWidthSpecified, out float preferredWidth,
                                   bool bHeightSpecified, out float preferredHeight)
{
	local float augsWidth, augsHeight;
	local float itemsWidth, itemsHeight;

	testwinAugsContainer.QueryPreferredSize(augsWidth, augsHeight);
	testwinItemsContainer.QueryPreferredSize(itemsWidth, itemsHeight);

	preferredWidth  = augsWidth + itemsWidth;
	preferredHeight = augsHeight + itemsHeight;
}

// ----------------------------------------------------------------------
// ConfigurationChanged()
// ----------------------------------------------------------------------

function ConfigurationChanged()
{
	local float augsWidth, augsHeight;
	local float itemsWidth, itemsHeight;
	local float itemPosX;

	if (testwinItemsContainer != None)
	{
		testwinItemsContainer.QueryPreferredSize(itemsWidth, itemsHeight);
		itemPosX = 0;
	}

	// Position the two windows
	if ((testwinAugsContainer != None) && (testwinAugsContainer.iconCount > 0))
	{
		testwinAugsContainer.QueryPreferredSize(augsWidth, augsHeight);
		testwinAugsContainer.ConfigureChild(itemsWidth, 0, augsWidth, augsHeight);

		itemPosX = itemsWidth + itemAugsOffsetX;
	}

	// Now that we know where the Augmentation window is, position
	// the Items window

	if (testwinItemsContainer != None)
	{
		// First check to see if there's enough room underneat the augs display 
		// to show the active items.

		if ((augsHeight + itemsHeight) > height)
			testwinItemsContainer.ConfigureChild(itemAugsOffsetX, itemAugsOffsetY, itemsWidth, itemsHeight);
		else
			testwinItemsContainer.ConfigureChild(itemPosX, augsHeight - 2, itemsWidth, itemsHeight);
	}		
}
/*
// ----------------------------------------------------------------------
// ChildRequestedReconfiguration()
// ----------------------------------------------------------------------

event bool ChildRequestedReconfiguration(window childWin)
{
	return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
*/
defaultproperties
{
     itemAugsOffsetX=14
     itemAugsOffsetY=6
}
