//=============================================================================
// IwHUDActiveItemsBorderBase
//=============================================================================

class IwHUDActiveItemsBorderBase extends HUDBaseWindow
	abstract;

var Window winIcons;
var int        iconCount;

var Texture texBorderTop;
var Texture texBorderCenter;
var Texture texBorderBottom;

var Texture texBorder1;

var Texture texBorderTopO;
var Texture texBorderCenterO;
var Texture texBorderBottomO;

var int centerheight;

var int borderTopMargin;
var int borderBottomMargin;
var int borderWidth;
var int topHeight;
var int topOffset;
var int bottomHeight;
var int bottomOffset;
var int tilePosX;
var int tilePosY;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	CreateTileWindow();

	Hide();
}

// ----------------------------------------------------------------------
// CreateTileWindow()
// ----------------------------------------------------------------------

function CreateTileWindow()
{

	//winIcons = TileWindow(NewChild(Class'TileWindow'));
	//winIcons = NewChild(Class'Window');
	//winIcons.SetMargins(0, 0);
	//winIcons.SetMinorSpacing(2);
	//winIcons.SetOrder(ORDER_Down);
	//winIcons.SetSize(64,64);
	//winIcons.SetPos(tilePosX, tilePosY);
}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
	local int i;
	i=0;
	
	if ((bDrawBorder) && (iconCount > 0))
	{
		gc.SetStyle(borderDrawStyle);
		gc.SetTileColor(colBorder);

		if (iconCount == 1)
		{
			gc.DrawTexture(0,0,width,topHeight,0,0, texBorder1);
		}
		else if (iconCount % 2 == 0) //even numbers
		{
			//gc.DrawTexture(0, 0, width, topHeight, 0, 0, texBorderTop);
			//if (iconCount > 2)
			for (i=0; i<(iconCount / 2); i++)
				gc.DrawPattern(0, centerheight*i, width, 128, 0, 0, texBorderCenter);
			//gc.DrawTexture(0, topOffset + centerheight*i, width, bottomHeight, 0, 0, texBorderBottom);
		}
		else if (iconCount % 2 != 0) //odd numbers
		{
			//gc.DrawTexture(0, 0, width, topHeight-11, 0, 0, texBorderTopO);
			for (i=0; i<iconCount / 2; i++)
				gc.DrawPattern(0, centerheight*i, width, 128, 0, 0, texBorderCenter);
			gc.DrawTexture(0, centerheight*i, width, topHeight, 0, 0, texBorder1);
		}
	}
	
}

// ----------------------------------------------------------------------
// AddIcon()
// ----------------------------------------------------------------------

function AddIcon(Texture newIcon, Object saveObject)
{
	local IwHUDActiveItemBase activeItem;
	local IwHUDActiveItemBase iconWindow;

	// First make sure this object isn't already in the window
	//iconWindow = IwHUDActiveItemBase(winIcons.GetTopChild());
	iconWindow = IwHUDActiveItemBase(GetTopChild());
	while(iconWindow != None)
	{
		// Abort if this object already exists!!
		if (iconWindow.GetClientObject() == saveObject)
			return;

		iconWindow = IwHUDActiveItemBase(iconWindow.GetLowerSibling());
	}
	
	// Hide if there are no icons visible
	if (++iconCount == 1)
		Show();

	if (saveObject.IsA('Augmentation'))
		activeItem = IwHUDActiveItemBase(NewChild(Class'IwHUDActiveAug'));
		//activeItem = IwHUDActiveItemBase(winIcons.NewChild(Class'IwHUDActiveAug'));
	else
		activeItem = IwHUDActiveItemBase(NewChild(Class'IwHUDActiveItem'));
		//activeItem = IwHUDActiveItemBase(winIcons.NewChild(Class'IwHUDActiveItem'));

	if (activeItem != None)
	{
		if (iconcount % 2 == 0) //even
		{
			activeItem.SetPos(32,iconcount * 23.4 - 13);
		}
		else
		{
			activeItem.SetPos(70,iconcount * 23.4 - 13);
		}
		activeItem.IconIndex = iconcount;
	}
	
	activeItem.SetIcon(newIcon);
	activeItem.SetClientObject(saveObject);
	activeItem.SetObject(saveObject);

	AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// RemoveObject()
// ----------------------------------------------------------------------

function RemoveObject(Object removeObject)
{
	local Window currentWindow;
	local Window nextWindow;
	local byte ItemInd;
	local byte i;

	// Loop through all our children and check to see if 
	// we have a match.

	//currentWindow = winIcons.GetTopChild();
	currentWindow = GetBottomChild(false);
	while(currentWindow != None)
	{
		nextWindow = currentWindow.GetHigherSibling(false);
		
		if (currentWindow.GetClientObject() == removeObject)
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
		
			ItemInd = IwHUDActiveItemBase(currentWindow).IconIndex;
			break;
		}
		currentWindow = nextWindow;
		
	}

	if (iconCount >= ItemInd)
	{
		for (i=ItemInd+1; i<=iconCount+1; i++)
		{
			currentWindow = GetTopChild();
			
			while(currentWindow != None)
			{
				nextWindow = currentWindow.GetLowerSibling();
		
				if (IwHUDActiveItemBase(currentWindow).IconIndex == i)
				{
					IwHUDActiveItemBase(currentWindow).IconIndex--;
					if ((i-1) % 2 == 0)
					{
						currentWindow.SetPos(32,(i-1) * 23.4 - 13);
					}
					else
					{
						currentWindow.SetPos(70,(i-1) * 23.4 - 13);
					}
					break;
				}
				else currentWindow = nextWindow;
			}
		}
	}
	AskParentForReconfigure();
	
/*
	local Window currentWindow;
	local Window nextWindow;
	local bool bIconDestroyed;

	bIconDestroyed = false;
	// Loop through all our children and check to see if 
	// we have a match.

	//currentWindow = winIcons.GetTopChild();
	currentWindow = GetTopChild();
	while(currentWindow != None)
	{
		nextWindow = currentWindow.GetLowerSibling();
		
		if (bIconDestroyed)
		{
			if (currentWindow.IsA('IwHUDActiveItemBase'))
			{
				IwHUDActiveItemBase(currentWindow).IconIndex--;
				if (IwHUDActiveItemBase(currentWindow).IconIndex % 2 == 0)
				{
					currentWindow.SetPos(35,(IwHUDActiveItemBase(currentWindow).IconIndex) * 23.4 + 10);
				}
				else
				{
					currentWindow.SetPos(70,(IwHUDActiveItemBase(currentWindow).IconIndex - 1) * 23.4 + 10);
				}
			}
		}	
		else if (currentWindow.GetClientObject() == removeObject)
		{
			currentWindow.Destroy();

			// Hide if there are no icons visible
			if (--iconCount == 0)
			{
				Hide();
				break;
			}
			
			bIconDestroyed=true;
			//break;
		}

		currentWindow = nextWindow;
		AskParentForReconfigure();
	}

//	AskParentForReconfigure();
*/
}

// ----------------------------------------------------------------------
// RemoveAllIcons()
// ----------------------------------------------------------------------

function RemoveAllIcons()
{
	//winIcons.DestroyAllChildren();
	DestroyAllChildren();
	iconCount = 0;
}

// ----------------------------------------------------------------------
// ParentRequestedPreferredSize()
// ----------------------------------------------------------------------

event ParentRequestedPreferredSize(bool bWidthSpecified, out float preferredWidth,
                                   bool bHeightSpecified, out float preferredHeight)
{
	//winIcons.QueryPreferredSize(preferredWidth, preferredHeight);
	//QueryPreferredSize(preferredWidth, preferredHeight);

	preferredWidth  = borderWidth;
	preferredHeight = preferredHeight + borderTopMargin + borderBottomMargin;
}


// ----------------------------------------------------------------------
// GetItemFromPos() (carone)
// ----------------------------------------------------------------------

function IwHUDActiveItemBase GetItemFromPos(byte ItemPos)
{
	local IwHUDActiveItemBase ActiveItem;
	local Window currentWindow;
	local Window nextWindow;
	
	currentWindow = GetBottomChild(false);	
	while(currentWindow != None)
	{
		nextWindow = currentWindow.GetHigherSibling(false);
			
		if (IwHUDActiveItemBase(currentWindow).IconIndex == ItemPos)	
			return IwHUDActiveItemBase(currentWindow);
		
		currentWindow = nextWindow;
	}
	return None;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
