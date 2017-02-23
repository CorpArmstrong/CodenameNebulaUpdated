//=============================================================================
// IwHUDObjectBelt
//=============================================================================
class IwHUDObjectBelt expands HUDObjectBelt;

#exec TEXTURE IMPORT FILE="Textures\UBHUD_Belt_Background_left.pcx"	NAME="UBHUD_Belt_BG_left" GROUP="UserInterface" MIPS=Off 
#exec TEXTURE IMPORT FILE="Textures\UBHUD_Belt_Background_right.pcx" NAME="UBHUD_Belt_BG_right" GROUP="UserInterface" MIPS=Off 



// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	// Hardcoded size, baby! (...geek) ;p
	SetSize(288, 128);

	
//	CreateSlots();
//	CreateNanoKeySlot();

//	PopulateBelt();
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

	// Radio window used to contain objects so they can be selected
	// with the mouse on the inventory screen.

	//winRadio = RadioBoxWindow(NewChild(Class'RadioBoxWindow'));
	//winRadio.SetSize(504, 54);
	//winRadio.SetSize(286, 126);
	//winRadio.SetPos(16, 16);
	//winRadio.bOneCheck = False;

	//winSlots = Window(winRadio.NewChild(Class'Window'));
	//winSlots.SetMargins(0, 0);
	//winSlots.SetMinorSpacing(0);
	//winSlots.SetOrder(ORDER_LeftThenUp);
	//winRadio.bSizeParentToChildren = false;
	//winRadio.bSizeChildrenToParent = false;

	for (i=0; i<10; i++)
	{
		//objects[i] = TestHUDObjectSlot(winSlots.NewChild(Class'TestHUDObjectSlot'));
		objects[i] = IwHUDObjectSlot(NewChild(Class'IwHUDObjectSlot'));
		objects[i].SetObjectNumber(i);
		if (i == 0)
			objects[i].SetPos(229, 22);
		else
			objects[i].SetPos(17+(i-1)*23.5, 70 - 48*((i-1) % 2));
		
	}
}


// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{

	local Color newBackground;

	gc.SetStyle(backgroundDrawStyle);

	if (( player != None ) && (player.Level.NetMode != NM_Standalone) && ( player.bBuySkills ))
	{
		newBackground.r = colBackground.r / 2;
		newBackground.g = colBackground.g / 2;
		newBackground.b = colBackground.b / 2;
		gc.SetTileColor(newBackground);
	}
	else
		gc.SetTileColor(colBackground);

	gc.DrawTexture(  2, 6, 256, 128, 0, 0, texBackgroundLeft);
	gc.DrawTexture(258, 6, 32, 128, 0, 0, texBackgroundRight);

}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
/*
	local Color newCol;

	if (bDrawBorder)
	{
		gc.SetStyle(borderDrawStyle);
		if (( player != None ) && ( player.bBuySkills ))
		{
			newCol.r = colBorder.r / 2;
			newCol.g = colBorder.g / 2;
			newCol.b = colBorder.b / 2;
			gc.SetTileColor(newCol);
		}
		else
			gc.SetTileColor(colBorder);

		gc.DrawTexture(  0, 0, 256, 69, 0, 0, texBorder[0]);
		gc.DrawTexture(256, 0, 256, 69, 0, 0, texBorder[1]);
		gc.DrawTexture(512, 0,  29, 69, 0, 0, texBorder[2]);
	}
*/
}

// ----------------------------------------------------------------------
// RemoveObjectFromBelt()
// ----------------------------------------------------------------------

function RemoveObjectFromBelt(Inventory item)
{
	local int i;
   local int StartPos;
   
   StartPos = 1;
   if ( (Player != None) && (Player.Level.NetMode != NM_Standalone) && (Player.bBeltIsMPInventory) )
      StartPos = 0;

	for (i=StartPos; IsValidPos(i); i++)
	{
		if (objects[i].GetItem() == item)
		{
		/*	objects[i].Destroy();
			objects[i] = IwHUDObjectSlot(NewChild(Class'IwHUDObjectSlot'));
			objects[i].SetObjectNumber(i);
			if (i == 0)
				objects[i].SetPos(229, 22);
			else
			objects[i].SetPos(17+(i-1)*23.5, 70 - 48*((i-1) % 2));
		*/	
			objects[i].SetItem(None);
			item.bInObjectBelt = False;
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
	local int  i;
   local int FirstPos;
	local bool retval;

	retval = true;

	if ((newItem != None ) && (newItem.Icon != None))
	{
		// If this is the NanoKeyRing, force it into slot 0
		if (newItem.IsA('NanoKeyRing'))
		{
			ClearPosition(0);
			pos = 0;
		}

		if (  (!IsValidPos(pos)) || 
            (  (Player.Level.NetMode != NM_Standalone) && 
               (Player.bBeltIsMPInventory) && 
               (!newItem.TestMPBeltSpot(pos)) ) )
		{
         FirstPos = 1;
         if ((Player.Level.NetMode != NM_Standalone) && (Player.bBeltIsMPInventory))
            FirstPos = 0;
			for (i=FirstPos; IsValidPos(i); i++)
         {
				if ((objects[i].GetItem() == None) && ( (Player.Level.NetMode == NM_Standalone) || (!Player.bBeltIsMPInventory) || (newItem.TestMPBeltSpot(i))))
            {
					break;
            }
         }
			if (!IsValidPos(i))
			{
				if (bOverride)
					pos = 1;
			}
			else
			{
				pos = i;
			}
		}

		if (IsValidPos(pos))
		{
			// If there's already an object here, remove it
			if ( objects[pos].GetItem() != None )
				RemoveObjectFromBelt(objects[pos].GetItem());

			objects[pos].SetItem(newItem);
		}
		else
		{
			retval = false;
		}
	}
	else
		retval = false;

	// The inventory item needs to know it's in the object
	// belt, as well as the location inside the belt.  This is used
	// when traveling to a new map.

	if ((retVal) && (Player.Role == ROLE_Authority))
	{
		newItem.bInObjectBelt = True;
		newItem.beltPos = pos;
	}

	UpdateInHand();

	return (retval);
}


function PopulateBelt()
{
	local Inventory anItem;
	//local TestHUDObjectBelt belt;
	local DeusExPlayer player;

	// Get a pointer to the player
	player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);

	for (anItem=player.Inventory; anItem!=None; anItem=anItem.Inventory)
		if (anItem.bInObjectBelt)
      {
			AddObjectToBelt(anItem, anItem.beltPos, True);
      }
}



// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     //texBackgroundLeft=Texture'DeusExUI.UserInterface.HUDObjectBeltBackground_Left'
     //texBackgroundRight=Texture'DeusExUI.UserInterface.HUDObjectBeltBackground_Right'
     texBackgroundLeft=Texture'fgrhk.UserInterface.UBHUD_Belt_BG_left'
     texBackgroundRight=Texture'fgrhk.UserInterface.UBHUD_Belt_BG_right'
//     texBorder(0)=Texture'DeusExUI.UserInterface.HUDObjectBeltBorder_1'
//     texBorder(1)=Texture'DeusExUI.UserInterface.HUDObjectBeltBorder_2'
//     texBorder(2)=Texture'DeusExUI.UserInterface.HUDObjectBeltBorder_3'
}
