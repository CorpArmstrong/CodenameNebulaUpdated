//=============================================================================
// IwHUDObjectBelt
//=============================================================================
class IwHUDObjectBelt extends HUDObjectBelt;

#exec TEXTURE IMPORT FILE="Textures\UBHUD_Belt_Background_left.pcx" NAME="UBHUD_Belt_BG_left" GROUP="UserInterface" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\UBHUD_Belt_Background_right.pcx" NAME="UBHUD_Belt_BG_right" GROUP="UserInterface" MIPS=Off

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
    super.InitWindow();
    SetSize(288, 128); // Hardcoded size, baby! (...geek) ;p
}

// ----------------------------------------------------------------------
// CreateSlots()
//
// Creates the Slots
// ----------------------------------------------------------------------

function CreateSlots()
{
    local int i;
    local RadioBoxWindow winRadio;

    for (i = 0; i < 10; i++)
    {
        objects[i] = IwHUDObjectSlot(NewChild(Class'IwHUDObjectSlot'));
        objects[i].SetObjectNumber(i);

        if (i == 0)
        {
            objects[i].SetPos(229, 22);
        }
        else
        {
            objects[i].SetPos(17 + (i - 1) * 23.5, 70 - 48 * ((i - 1) % 2));
        }
    }
}

// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{
    local Color newBackground;
    gc.SetStyle(backgroundDrawStyle);

    if ((player != none) && (player.Level.NetMode != NM_Standalone) && (player.bBuySkills))
    {
        newBackground.r = colBackground.r / 2;
        newBackground.g = colBackground.g / 2;
        newBackground.b = colBackground.b / 2;
        gc.SetTileColor(newBackground);
    }
    else
    {
        gc.SetTileColor(colBackground);
    }

    gc.DrawTexture(2, 6, 256, 128, 0, 0, texBackgroundLeft);
    gc.DrawTexture(258, 6, 32, 128, 0, 0, texBackgroundRight);
}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
}

// ----------------------------------------------------------------------
// RemoveObjectFromBelt()
// ----------------------------------------------------------------------

function RemoveObjectFromBelt(Inventory item)
{
    local int i;
    local int StartPos;

    StartPos = 1;

    if ((Player != none) && (Player.Level.NetMode != NM_Standalone) && (Player.bBeltIsMPInventory))
    {
        StartPos = 0;
    }

    for (i = StartPos; IsValidPos(i); i++)
    {
        if (objects[i].GetItem() == item)
        {
            objects[i].SetItem(none);
            item.bInObjectBelt = false;
            item.beltPos = -1;
            break;
        }
    }
}

// ----------------------------------------------------------------------
// AddObjectToBelt()
// ----------------------------------------------------------------------

function bool AddObjectToBelt(Inventory newItem, int pos, bool bOverride)
{
    local int i;
    local int FirstPos;
    local bool retval;

    retval = true;

    if ((newItem != none ) && (newItem.Icon != none))
    {
        // If this is the NanoKeyRing, force it into slot 0
        if (newItem.IsA('NanoKeyRing'))
        {
            ClearPosition(0);
            pos = 0;
        }

        if ((!IsValidPos(pos)) ||
            ((Player.Level.NetMode != NM_Standalone) &&
               (Player.bBeltIsMPInventory) &&
               (!newItem.TestMPBeltSpot(pos))))
        {
            FirstPos = 1;

            if ((Player.Level.NetMode != NM_Standalone) && (Player.bBeltIsMPInventory))
            {
                FirstPos = 0;
            }

            for (i = FirstPos; IsValidPos(i); i++)
            {
                if ((objects[i].GetItem() == none) && ((Player.Level.NetMode == NM_Standalone) || (!Player.bBeltIsMPInventory) || (newItem.TestMPBeltSpot(i))))
                {
                    break;
                }
            }

            if (!IsValidPos(i))
            {
                if (bOverride)
                {
                    pos = 1;
                }
            }
            else
            {
                pos = i;
            }
        }

        if (IsValidPos(pos))
        {
            // If there's already an object here, remove it
            if (objects[pos].GetItem() != none)
            {
                RemoveObjectFromBelt(objects[pos].GetItem());
            }

            objects[pos].SetItem(newItem);
        }
        else
        {
            retval = false;
        }
    }
    else
    {
        retval = false;
    }

    // The inventory item needs to know it's in the object
    // belt, as well as the location inside the belt.  This is used
    // when traveling to a new map.

    if ((retVal) && (Player.Role == ROLE_Authority))
    {
        newItem.bInObjectBelt = true;
        newItem.beltPos = pos;
    }

    UpdateInHand();

    return (retval);
}


function PopulateBelt()
{
    local Inventory anItem;
    local DeusExPlayer player;

    player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);

    for (anItem = player.Inventory; anItem != none; anItem = anItem.Inventory)
    {
        if (anItem.bInObjectBelt)
        {
            AddObjectToBelt(anItem, anItem.beltPos, true);
        }
    }
}

defaultproperties
{
    texBackgroundLeft=Texture'CNN.UserInterface.UBHUD_Belt_BG_left'
    texBackgroundRight=Texture'CNN.UserInterface.UBHUD_Belt_BG_right'
}
