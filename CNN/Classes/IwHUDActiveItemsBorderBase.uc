//=============================================================================
// IwHUDActiveItemsBorderBase
//=============================================================================
class IwHUDActiveItemsBorderBase extends HUDBaseWindow abstract;

var Window winIcons;
var int iconCount;

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
    super.InitWindow();
    CreateTileWindow();
    Hide();
}

// ----------------------------------------------------------------------
// CreateTileWindow()
// ----------------------------------------------------------------------

function CreateTileWindow()
{
}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
    local int i;
    i = 0;

    if ((bDrawBorder) && (iconCount > 0))
    {
        gc.SetStyle(borderDrawStyle);
        gc.SetTileColor(colBorder);

        if (iconCount == 1)
        {
            gc.DrawTexture(0, 0, width, topHeight, 0, 0, texBorder1);
        }
        else if (iconCount % 2 == 0)
        {
            for (i = 0; i < (iconCount / 2); i++)
            {
            	gc.DrawPattern(0, centerheight * i, width, 128, 0, 0, texBorderCenter);
            }
        }
        else if (iconCount % 2 != 0)
        {
            for (i = 0; i < iconCount / 2; i++)
            {
            	gc.DrawPattern(0, centerheight * i, width, 128, 0, 0, texBorderCenter);
            }

            gc.DrawTexture(0, centerheight * i, width, topHeight, 0, 0, texBorder1);
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
    iconWindow = IwHUDActiveItemBase(GetTopChild());

    while (iconWindow != none)
    {
        // Abort if this object already exists!!
        if (iconWindow.GetClientObject() == saveObject)
        {
            return;
        }

        iconWindow = IwHUDActiveItemBase(iconWindow.GetLowerSibling());
    }

    // Hide if there are no icons visible
    if (++iconCount == 1)
    {
        Show();
    }

    if (saveObject.IsA('Augmentation'))
    {
        activeItem = IwHUDActiveItemBase(NewChild(Class'IwHUDActiveAug'));
    }
    else
    {
        activeItem = IwHUDActiveItemBase(NewChild(Class'IwHUDActiveItem'));
    }

    if (activeItem != none)
    {
        if (iconcount % 2 == 0)
        {
            activeItem.SetPos(32, iconcount * 23.4 - 13);
        }
        else
        {
            activeItem.SetPos(70, iconcount * 23.4 - 13);
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

    // Loop through all our children and check to see if we have a match.

    currentWindow = GetBottomChild(false);

    while (currentWindow != none)
    {
        nextWindow = currentWindow.GetHigherSibling(false);

        if (currentWindow.GetClientObject() == removeObject)
        {
            currentWindow.Hide();
            currentWindow.SetClientObject(none);

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
        for (i = ItemInd + 1; i <= iconCount + 1; i++)
        {
            currentWindow = GetTopChild();

            while (currentWindow != none)
            {
                nextWindow = currentWindow.GetLowerSibling();

                if (IwHUDActiveItemBase(currentWindow).IconIndex == i)
                {
                    IwHUDActiveItemBase(currentWindow).IconIndex--;

                    if ((i - 1) % 2 == 0)
                    {
                        currentWindow.SetPos(32, (i - 1) * 23.4 - 13);
                    }
                    else
                    {
                        currentWindow.SetPos(70, (i - 1) * 23.4 - 13);
                    }

                    break;
                }
                else
                {
                    currentWindow = nextWindow;
                }
            }
        }
    }

    AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// RemoveAllIcons()
// ----------------------------------------------------------------------

function RemoveAllIcons()
{
    DestroyAllChildren();
    iconCount = 0;
}

// ----------------------------------------------------------------------
// ParentRequestedPreferredSize()
// ----------------------------------------------------------------------

event ParentRequestedPreferredSize(bool bWidthSpecified, out float preferredWidth,
                                   bool bHeightSpecified, out float preferredHeight)
{
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

    while(currentWindow != none)
    {
        nextWindow = currentWindow.GetHigherSibling(false);

        if (IwHUDActiveItemBase(currentWindow).IconIndex == ItemPos)
        {
            return IwHUDActiveItemBase(currentWindow);
        }

        currentWindow = nextWindow;
    }

    return none;
}
