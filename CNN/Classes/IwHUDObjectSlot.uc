//=============================================================================
// IwHUDObjectSlot
//=============================================================================
class IwHUDObjectSlot expands HUDObjectSlot;

#exec TEXTURE IMPORT FILE="Textures\UBHUD_Belt_Selected.pcx" NAME="UBHUD_Belt_Selected" GROUP="UserInterface" MIPS=Off

var Texture SelTexture;

// ----------------------------------------------------------------------
// SetObjectNumber()
// ----------------------------------------------------------------------

function SetObjectNumber(int newNumber)
{
    objectNum = newNumber;

    if (objectNum % 2 == 0)
    {
        slotIconY = 16;
    }
}

// ----------------------------------------------------------------------
// SetItem()
// ----------------------------------------------------------------------

function SetItem(Inventory newItem)
{
    item = newItem;

    if (newItem != none)
    {
        newItem.bInObjectBelt = true;
        newItem.beltPos = objectNum;
    }
    else
    {
        HighlightSelect(false);
        SetToggle(false);
    }

    // Update the text that will be displayed above the icon (if any)
    UpdateItemText();
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
   DrawHUDBackground(gc);

    // Now fill the area under the icon, which can be different
    // colors based on the state of the item.
    // Don't waste time drawing the fill if the fillMode is set
    // to none
    // Don't draw any of this if we're dragging

    if ((item != none) && (item.Icon != none) && (!bDragging))
    {
        // Draw the icon
        DrawHUDIcon(gc);

        // Text defaults
        gc.SetAlignments(HALIGN_Center, VALIGN_Center);
        gc.EnableWordWrap(false);
        gc.SetTextColor(colObjectNum);

        // *** carone ***
        // Draw selection border
        if (bButtonPressed)
        {
            gc.SetStyle(DSTY_Translucent);
            gc.DrawTexture(0, 0, slotFillWidth, slotFillHeight, 0, 0, SelTexture);
        }
    }
    else if ((item == none) && (player != none) && (player.Level.NetMode != NM_Standalone) && (player.bBeltIsMPInventory))
    {
        // Text defaults
        gc.SetAlignments(HALIGN_Center, VALIGN_Center);
        gc.EnableWordWrap(false);
        gc.SetTextColor(colObjectNum);

        if ((objectNum >= 1) && (objectNum <= 3))
        {
            gc.DrawText(1, 42, 42, 7, "WEAPONS");
        }
        else if ((objectNum >= 4) && (objectNum <= 6))
        {
            gc.DrawText(1, 42, 42, 7, "GRENADES");
        }
        else if (((objectNum >= 7) && (objectNum <= 9)) || (objectNum == 0))
        {
            gc.DrawText(1, 42, 42, 7, "TOOLS");
        }
    }

    // Draw the Object Slot Number in upper-right corner
    gc.SetAlignments(HALIGN_Right, VALIGN_Center);
    gc.SetTextColor(colObjectNum);
    gc.DrawText(slotNumberX - 1, slotNumberY, 6, 7, objectNum);
}

function DrawHUDIcon(GC gc)
{
    gc.SetStyle(DSTY_Masked);
    gc.SetTileColorRGB(255, 255, 255);

    if (item == none)
    {
        gc.SetTileColorRGB(0, 0, 0);
        gc.DrawTexture(0, 0, slotFillWidth, slotFillHeight, 0, 0, Texture'Solid');
    }
    else
    {
        gc.DrawStretchedTexture(5, 8, slotFillWidth, slotFillHeight, 0, 0, slotFillWidth + 10, slotFillHeight + 10, item.Icon);
    }
}

function DrawHUDBackground(GC gc)
{
    local Color newBackground;
    gc.SetStyle(backgroundDrawStyle);

    if ((player != none ) && (player.Level.NetMode != NM_Standalone) && (player.bBuySkills))
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

    // DEUS_EX AMSD Warning.  This background delineates specific item locations on the belt, which
    // are usually only known to the items themselves.
    if ((player != none) && (Player.Level.Netmode != NM_Standalone) && (Player.bBeltIsMPInventory) && ((objectNum == 3) || (objectNum == 6)))
    {
        gc.DrawTexture(0, 0, width, height, 0, 0, mpBorderTex);
    }
}

// ----------------------------------------------------------------------
// AssignWinInv()
// ----------------------------------------------------------------------

function AssignWinInv(PersonaScreenInventory newWinInventory)
{
    winInv = newWinInventory;
}

defaultproperties
{
    SelTexture=Texture'CNN.UserInterface.UBHUD_Belt_Selected'
    slotFillWidth=50
    slotFillHeight=50
    borderWidth=50
    slotIconX=0
    slotIconY=0
}
