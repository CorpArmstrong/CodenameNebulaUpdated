//=============================================================================
// ApocalypseInsideHUD.
//=============================================================================
class ApocalypseInsideHUD expands DeusExHUD;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	local DeusExRootWindow root;
	local DeusExPlayer player;

	//Super.InitWindow();

	// Get a pointer to the root window
	root = DeusExRootWindow(GetRootWindow());

	// Get a pointer to the player
	player = DeusExPlayer(root.parentPawn);

	SetFont(Font'TechMedium');
	SetSensitivity(false);

	ammo			= HUDAmmoDisplay(NewChild(Class'HUDAmmoDisplay'));
	hit				= IwHUDHitDisplay(NewChild(Class'IwHUDHitDisplay'));
	cross.Destroy(); 
	cross			= Crosshair(NewChild(Class'Crosshair'));
	belt			= IwHUDObjectBelt(NewChild(Class'IwHUDObjectBelt'));
	activeItems		= IwHUDActiveItemsDisplay(NewChild(Class'IwHUDActiveItemsDisplay'));
	damageDisplay.Destroy();
	damageDisplay	= AiDamageHUDDisplay(NewChild(Class'AiDamageHUDDisplay'));
	compass.Destroy(); 
	compass     	= AiHUDCompassDisplay(NewChild(Class'AiHUDCompassDisplay'));
	hms				= HUDMultiSkills(NewChild(Class'HUDMultiSkills'));

	// Create the InformationWindow
	info = HUDInformationDisplay(NewChild(Class'HUDInformationDisplay', False));

	// Create the log window
	msgLog	= HUDLogDisplay(NewChild(Class'HUDLogDisplay', False));
	msgLog.SetLogTimeout(player.GetLogTimeout());

	frobDisplay = FrobDisplayWindow(NewChild(Class'FrobDisplayWindow'));
	frobDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	augDisplay	= AugmentationDisplayWindow(NewChild(Class'AugmentationDisplayWindow'));
	augDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	startDisplay = HUDMissionStartTextDisplay(NewChild(Class'HUDMissionStartTextDisplay', False));
//	startDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	// Bark display
	barkDisplay = HUDBarkDisplay(NewChild(Class'HUDBarkDisplay', False));

	// Received Items Display
	receivedItems = HUDReceivedDisplay(NewChild(Class'HUDReceivedDisplay', False));
}

function HUDInfoLinkDisplay CreateInfoLinkWindow()
{
	if ( infolink != None )
		return None;
	
	infolink = HUDInfoLinkDisplay(NewChild(Class'AiHUDInfoLinkDisplay'));

	// Hide Log window
	if ( msgLog != None )
		msgLog.Hide();

	infolink.AskParentForReconfigure();

	return infolink;
}
