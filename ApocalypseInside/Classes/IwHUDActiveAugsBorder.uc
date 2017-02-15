//=============================================================================
// IwHUDActiveAugsBorder
//=============================================================================

class IwHUDActiveAugsBorder extends IwHUDActiveItemsBorderBase;

var int FirstKeyNum;
var int LastKeyNum;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	SetSize(128,400);
	// Create *ALL* the icons, but hide them.
	CreateIcons();
}

// ----------------------------------------------------------------------
// CreateIcons()
// ----------------------------------------------------------------------

function CreateIcons()
{
	local int keyIndex;
	local IwHUDActiveAug iconWindow;

	for(keyIndex=FirstKeyNum; keyIndex<=LastKeyNum; keyIndex++)
	{
		//iconWindow = IwHUDActiveAug(winIcons.NewChild(Class'IwHUDActiveAug'));
		iconWindow = IwHUDActiveAug(NewChild(Class'IwHUDActiveAug'));
		iconWindow.SetKeyNum(keyIndex);
		iconWindow.Hide();
	}
}

// ----------------------------------------------------------------------
// ClearAugmentationDisplay()
// ----------------------------------------------------------------------

function ClearAugmentationDisplay()
{
	local Window currentWindow;
	local Window foundWindow;

	// Loop through all our children and check to see if 
	// we have a match.

	//currentWindow = winIcons.GetTopChild();
	currentWindow = GetTopChild();
	while(currentWindow != None)
	{
		currentWindow.Hide();
		currentWindow.SetClientObject(None);
		currentWindow = currentWindow.GetLowerSibling();
	}

	iconCount = 0;
}

// ----------------------------------------------------------------------
// AddIcon()
//
// Find the appropriate 
// ----------------------------------------------------------------------

function AddIcon(Texture newIcon, Object saveObject)
{
	local IwHUDActiveAug augItem;
	local IwHUDActiveItemBase curItem;
	
//	local Window currentWindow;
//	local Window nextWindow;
	local byte AugInd;
	local byte i,i2;

	augItem = FindAugWindowByKey(Augmentation(saveObject));

	if (augItem != None)
	{
		augItem.IconIndex = iconcount+1;
			
		augItem.SetIcon(newIcon);
		augItem.SetClientObject(saveObject);
		augItem.SetObject(saveObject);
		augItem.Show();

		// Hide if there are no icons visible
		if (++iconCount == 1)
			Show();
		
		if (iconCount > 1)
		{
			for (i=1; i<iconCount; i++)
			{
				curItem = GetItemFromPos(i);
				if (IwHUDActiveAug(curItem).HotKeyNum > augItem.HotKeyNum) //IwHUDActiveAug(GetItemFromPos(i))
				{
					AugInd = i;
					for (i2=iconCount-1; i2>=AugInd; i2--)
					{
						curItem = GetItemFromPos(i2);
						curItem.IconIndex++;
						if ((i2) % 2 == 0)
						{
							curItem.SetPos(70,(i2) * 23.4 + 10);
						}
						else
						{
							curItem.SetPos(30,(i2) * 23.4 + 10);
						}
					}

					augItem.IconIndex = AugInd;
					break;
				}
			}
		}
		AugInd = augItem.IconIndex;
		if ((AugInd-1) % 2 == 0) //even
		{
			augItem.SetPos(70,(AugInd-1) * 23.4 + 10);
		}
		else
		{
			augItem.SetPos(30,(AugInd-1) * 23.4 + 10);
		}
	}
}

// ----------------------------------------------------------------------
// RemoveObject()
// ----------------------------------------------------------------------

function RemoveObject(Object removeObject)
{
	local Window currentWindow;
	local Window nextWindow;
	local IwHUDActiveItemBase curItem;
	local byte AugInd;
	local byte i;

	// Loop through all our children and check to see if 
	// we have a match.

	//currentWindow = winIcons.GetTopChild();
	currentWindow = GetBottomChild(false);
	while(currentWindow != None)
	{
		nextWindow = currentWindow.GetHigherSibling(false);
		
		if (IwHUDActiveAug(currentWindow).HotKeyNum == Augmentation(removeObject).HotKeyNum)
		{
			currentWindow.Hide();
			currentWindow.SetClientObject(None);

			// Hide if there are no icons visible
			if (--iconCount == 0)
			{
				Hide();
				AskParentForReconfigure();
				return;
			}
		
			AugInd = IwHUDActiveAug(currentWindow).IconIndex;
			IwHUDActiveAug(currentWindow).IconIndex = 0;
			
			break;
		}
		currentWindow = nextWindow;
		
	}

	if (iconCount >= AugInd)
	{
		for (i=AugInd+1; i<=iconCount+1; i++)
		{
			curItem = GetItemFromPos(i);
				
			curItem.IconIndex--;
			if ((i) % 2 == 0)
			{
				curItem.SetPos(70,(i-2) * 23.4 + 10);
			}
			else
			{
				curItem.SetPos(30,(i-2) * 23.4 + 10);
			}

		}
	}
}

// ----------------------------------------------------------------------
// FindAugWindowByKey()
// ----------------------------------------------------------------------

function IwHUDActiveAug FindAugWindowByKey(Augmentation anAug)
{
	local Window currentWindow;
	local Window foundWindow;

	// Loop through all our children and check to see if 
	// we have a match.

	//currentWindow = winIcons.GetTopChild(False);
	currentWindow = GetTopChild(False);

	while(currentWindow != None)
	{
		if (IwHUDActiveAug(currentWindow).HotKeyNum == anAug.HotKeyNum)
		{
			foundWindow = currentWindow;
			break;
		}

		currentWindow = currentWindow.GetLowerSibling(False);
	}

	return IwHUDActiveAug(foundWindow);
}

// ----------------------------------------------------------------------
// UpdateAugIconStatus()
// ----------------------------------------------------------------------

function UpdateAugIconStatus(Augmentation aug)
{
	local IwHUDActiveAug iconWindow;

	// First make sure this object isn't already in the window
	//iconWindow = IwHUDActiveAug(winIcons.GetTopChild());
	iconWindow = IwHUDActiveAug(GetTopChild());
	while(iconWindow != None)
	{
		// Abort if this object already exists!!
		if (iconWindow.GetClientObject() == aug)
		{
			iconWindow.UpdateAugIconStatus();
			break;			
		}
		iconWindow = IwHUDActiveAug(iconWindow.GetLowerSibling());
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     FirstKeyNum=3
     LastKeyNum=12
	 texBorder1=Texture'fgrhk.UserInterface.UBHUD_Aug_1'
     //texBorderTop=Texture'fgrhk.UserInterface.UBHUD_Aug_e_top'
     texBorderCenter=Texture'fgrhk.UserInterface.UBHUD_Aug_e'
     //texBorderBottom=Texture'fgrhk.UserInterface.UBHUD_Aug_e_bottom'
     //texBorderTopO=Texture'fgrhk.UserInterface.UBHUD_Aug_o_top'
     //texBorderCenterO=Texture'fgrhk.UserInterface.UBHUD_Aug_o_middle'
     //texBorderBottomO=Texture'fgrhk.UserInterface.UBHUD_Aug_o_bottom'
     centerheight=47     
     borderTopMargin=7
     borderBottomMargin=6
     borderWidth=128 //48
     topHeight=64
     topOffset=64
     bottomHeight=64
     bottomOffset=64
     tilePosX=0
     tilePosY=0
}
