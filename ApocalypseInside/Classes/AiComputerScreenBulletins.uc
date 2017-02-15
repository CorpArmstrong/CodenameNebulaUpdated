class AiComputerScreenBulletins expands ComputerScreenBulletins;

var MenuUIHeaderWindow          winHeader;
var MenuUIActionButtonWindow    btnSpecial;
var MenuUIActionButtonWindow    btnLogout;
var MenuUIListWindow            lstBulletins;
var MenuUINormalLargeTextWindow winBulletin;

var Localized String NoBulletinsTodayText;
var Localized String BulletinsHeaderText;

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();

	btnLogout = winButtonBar.AddButton(ButtonLabelLogout, HALIGN_Right);

	CreateHeaderWindow();
	CreateBulletinsListWindow();
	CreateBulletinViewWindow();
}

// ----------------------------------------------------------------------
// CreateHeaderWindow()
// ----------------------------------------------------------------------
/*
function CreateHeaderWindow()
{
	winHeader = MenuUIHeaderWindow(winClient.NewChild(Class'MenuUIHeaderWindow'));
	
	winHeader.SetPos(  11 * dxEnhancedGUIScaleMultiplier, 
					    6 * dxEnhancedGUIScaleMultiplier);
	winHeader.SetSize(300 * dxEnhancedGUIScaleMultiplier, 
					   12 * dxEnhancedGUIScaleMultiplier);
	winHeader.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	winHeader.SetText(BulletinsHeaderText);
}
*/
// ----------------------------------------------------------------------
// CreateBulletinsListWindow()
// ----------------------------------------------------------------------
/*
function CreateBulletinsListWindow()
{
	local MenuUIScrollAreaWindow winScroll;

	winScroll = CreateScrollAreaWindow(winClient);
	
	winScroll.SetPos(  11 * dxEnhancedGUIScaleMultiplier, 
					   22 * dxEnhancedGUIScaleMultiplier);
	winScroll.SetSize(373 * dxEnhancedGUIScaleMultiplier, 
					  113 * dxEnhancedGUIScaleMultiplier);

	lstBulletins = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));
	lstBulletins.EnableMultiSelect(False);
	lstBulletins.EnableAutoExpandColumns(False);
	lstBulletins.EnableHotKeys(False);
	lstBulletins.SetNumColumns(1);
	lstBulletins.SetColumnWidth(0, 373 * dxEnhancedGUIScaleMultiplier);
}
*/
// ----------------------------------------------------------------------
// CreateBulletinViewWindow()
// ----------------------------------------------------------------------
/*
function CreateBulletinViewWindow()
{
	local MenuUIScrollAreaWindow winScroll;

	winScroll = CreateScrollAreaWindow(winClient);
	winScroll.SetPos(  11 * dxEnhancedGUIScaleMultiplier, 143 * dxEnhancedGUIScaleMultiplier);
	winScroll.SetSize(373 * dxEnhancedGUIScaleMultiplier, 232 * dxEnhancedGUIScaleMultiplier);

	winBulletin = MenuUINormalLargeTextWindow(winScroll.ClipWindow.NewChild(Class'MenuUINormalLargeTextWindow'));
	winBulletin.SetTextMargins(4 * dxEnhancedGUIScaleMultiplier, 1 * dxEnhancedGUIScaleMultiplier);
	winBulletin.SetWordWrap(True);
	winBulletin.SetTextAlignments(HALIGN_Left, VALIGN_Top);
}
*/
// ----------------------------------------------------------------------
// SetNetworkTerminal()
// ----------------------------------------------------------------------

function SetNetworkTerminal(NetworkTerminal newTerm)
{
	Super.SetNetworkTerminal(newTerm);

	if (winTerm.AreSpecialOptionsAvailable())
	{
		btnSpecial = winButtonBar.AddButton(ButtonLabelSpecial, HALIGN_Left);
		CreateLeftEdgeWindow();
	}
}

// ----------------------------------------------------------------------
// SetCompOwner()
// ----------------------------------------------------------------------

function SetCompOwner(ElectronicDevices newCompOwner)
{
	local int bulletinIndex;
	local int rowId;

	Super.SetCompOwner(newCompOwner);

	// Now populate the bulletins
	if (WebAccessPoint(compOwner).bulletinTag != '')
	{
		// Churn through the bulletin text
		ProcessDeusExText(WebAccessPoint(compOwner).bulletinTag);

		// Now populate our list
		for(bulletinIndex=0; bulletinIndex<=fileIndex; bulletinIndex++)
			lstBulletins.AddRow(fileInfo[bulletinIndex].fileDescription);

		// Select the first row
		rowId = lstBulletins.IndexToRowId(0);
		lstBulletins.SetRow(rowId, True);
	}
/*
	if(WebAccessPoint(compOwner).bulletinTitles[0] != "")
	{
		fileIndex = bulletinIndex;
		bulletinIndex = 0;

		while(WebAccessPoint(compOwner).bulletinTitles[bulletinIndex] != "" && bulletinIndex < 4 && fileIndex < 9)
		{
			fileInfo[fileIndex].fileDescription = WebAccessPoint(compOwner).bulletinTitles[bulletinIndex];
			fileInfo[fileIndex].fileString = WebAccessPoint(compOwner).bulletinText[bulletinIndex];
			lstBulletins.AddRow(fileInfo[fileIndex].fileDescription);

			bulletinIndex++;
		}

		rowId = lstBulletins.IndexToRowId(0);
		lstBulletins.SetRow(rowId, True);
	}

	if(WebAccessPoint(compOwner).bulletinTag == '' && WebAccessPoint(compOwner).bulletinTitles[0] == "")
	{
		// No bulletins, so just print a "No Bulletins Today!" message
		winBulletin.SetText(NoBulletinsTodayText);
		winBulletin.SetTextAlignments(HALIGN_Center, VALIGN_Center);
	}
	*/
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;

	bHandled = True;

	switch( buttonPressed )
	{
		case btnLogout:
			CloseScreen("EXIT");
			break;

		case btnSpecial:
			CloseScreen("SPECIAL");
			break;

		default:
			bHandled = False;
			break;
	}

	if (bHandled)
		return True;
	else
		return Super.ButtonActivated(buttonPressed);
}

// ----------------------------------------------------------------------
// ListSelectionChanged() 
//
// Show the appropriate bulletin
// ----------------------------------------------------------------------

event bool ListSelectionChanged(window list, int numSelections, int focusRowId)
{
	local int bulletinIndex;

	bulletinIndex = lstBulletins.RowIdToIndex(focusRowId);
	winBulletin.SetText("");
	if(fileInfo[bulletinIndex].fileName != '')
		ProcessDeusExText(fileInfo[bulletinIndex].fileName, winBulletin);
	/*else if(fileInfo[bulletinIndex].fileString != "")
		winBulletin.SetText(fileInfo[bulletinIndex].fileString);*/
}

// ----------------------------------------------------------------------
// DJ: Doubled values, except: textureRows, textureCols
// ----------------------------------------------------------------------

defaultproperties
{
    NoBulletinsTodayText="No Bulletins Today!"
    BulletinsHeaderText="Please choose a bulletin to view:"
    Title="Bulletins"
    ClientWidth=790
    ClientHeight=824
    clientTextures(0)=Texture'DeusExUI.UserInterface.ComputerBulletinBackground_1'
    clientTextures(1)=Texture'DeusExUI.UserInterface.ComputerBulletinBackground_2'
    clientTextures(2)=Texture'DeusExUI.UserInterface.ComputerBulletinBackground_3'
    clientTextures(3)=Texture'DeusExUI.UserInterface.ComputerBulletinBackground_4'
    textureRows=2
    textureCols=2
    statusPosY=766
    defaultStatusLeftOffset=24
    ComputerNodeFunctionLabel="Bulletins"
}
