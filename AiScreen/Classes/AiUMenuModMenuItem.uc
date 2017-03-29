// Descend from this class to add an item to the Mod menu.
	// Be sure to put a line in your Mod's .int file to specify this class
	// eg:
	// Object=(Name=MyModPkg.MyModMenuItem,Class=Class,MetaClass=UMenu.UMenuModMenuItem,Description="&My Mod,This text goes on the status bar")

	class AiUMenuModMenuItem expands AiUWindowList;

	var localized string MenuCaption;
	var localized string MenuHelp;

	var AiUWindowPulldownMenuItem MenuItem;	// Used internally

	function Setup()
	{
		/// Called when the menu item iCUWindowList
	}

	function Execute()
	{
		// Called when the menu item is chosen
	}

	defaultproperties
	{
	     MenuCaption="&My Mod"
	     MenuHelp="This text goes on the status bar"
	}
