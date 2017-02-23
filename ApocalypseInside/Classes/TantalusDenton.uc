//=============================================================================
// TantalusDenton.uc
//=============================================================================
class TantalusDenton extends JCDentonMale;

var travel BioEnergyController bioc;
//var travel AiAugmentationManager AugmentationSystem;

//var AiDataLinkPlay aidataLinkPlay;

//var String playerBias;

// ----------------------------------------------------------------------
// PostBeginPlay()
//
// set up the augmentation and skill systems
// ----------------------------------------------------------------------

function PostBeginPlay() {
	bioc = Spawn(class'BioEnergyController', none);
	Super.PostBeginPlay();
}

event TravelPostAccept() {
	local flagbase flags;
	local DeusExLevelInfo info;
	info = DeusExPlayer(GetPlayerPawn()).GetLevelInfo();
	Super.TravelPostAccept();
	

	flags = flagbase;
	
   	switch(PlayerSkin)
	{
		case 0:
			flags.SetBool('Bias_Templar',True);
			MultiSkins[0] = Texture'ApocalypseInside.Skins.TantalusFace';
			MultiSkins[1] = Texture'DeusExCharacters.Skins.StantonDowdTex2';
			MultiSkins[2] = Texture'DeusExCharacters.Skins.MJ12TroopTex1';
			MultiSkins[3] = Texture'ApocalypseInside.Skins.TantalusFace';
			MultiSkins[4] = Texture'DeusExCharacters.Skins.JockTex1';
			MultiSkins[5] = Texture'DeusExCharacters.Skins.SmugglerTex2';
			MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
			MultiSkins[7] = FireTexture'Effects.Laser.LaserSpot2';
		break;
		case 1:
			flags.SetBool('Bias_Triad',True);
			MultiSkins[0] = Texture'ApocalypseInside.Skins.TantalusAsian';
			MultiSkins[1] = Texture'DeusExCharacters.Skins.JockTex2';
			MultiSkins[2] = Texture'DeusExCharacters.Skins.ThugMaleTex3';
			MultiSkins[3] = Texture'ApocalypseInside.Skins.TantalusFace';
			MultiSkins[4] = Texture'DeusExCharacters.Skins.PaulDentonTex1';
			MultiSkins[5] = Texture'DeusExItems.Skins.PinkMaskTex';
			MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
			//MultiSkins[7] = FireTexture'Effects.Fire.Spark_Electric'; //causes ucc to return error
		break;
		case 2:
			flags.SetBool('Bias_MJ12',True);
			Mesh=LodMesh'DeusExCharacters.GM_Suit';
			MultiSkins[0] = Texture'ApocalypseInside.Skins.TantalusBlack';
			MultiSkins[1] = Texture'DeusExCharacters.Skins.LowerClassMale2Tex2';
			MultiSkins[2] = Texture'DeusExItems.Skins.PinkMaskTex';
			MultiSkins[3] = Texture'DeusExCharacters.Skins.MIBTex1';
			MultiSkins[4] = Texture'DeusExCharacters.Skins.MIBTex1';
			MultiSkins[5] = Texture'DeusExCharacters.Skins.FramesTex4';
			MultiSkins[6] = FireTexture'Effects.Laser.LaserSpot2';
			MultiSkins[7] = Texture'DeusExItems.Skins.PinkMaskTex';
		break;
		case 3:
			flags.SetBool('Bias_NSF',True);
			Mesh=LodMesh'DeusExCharacters.GM_DressShirt';
			MultiSkins[0] = Texture'ApocalypseInside.Skins.TantalusGinger';
			MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';
			MultiSkins[2] = Texture'DeusExItems.Skins.PinkMaskTex';
			MultiSkins[3] = Texture'DeusExCharacters.Skins.ThugMale3Tex2';
			MultiSkins[4] = Texture'DeusExItems.Skins.PinkMaskTex';
			MultiSkins[5] = Texture'ApocalypseInside.Skins.NSFJacket';
			MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
			//MultiSkins[7] = FireTexture'Effects.water.WaterDrop1';
		break;
		case 4:
			flags.SetBool('Bias_UNATCO',True);
			MultiSkins[0] = Texture'ApocalypseInside.Skins.TantalusGoatee';
			MultiSkins[1] = Texture'DeusExCharacters.Skins.SmugglerTex2';
			MultiSkins[2] = Texture'DeusExCharacters.Skins.ThugMale3Tex2';
			MultiSkins[3] = Texture'DeusExCharacters.Skins.JCDentonTex0';
			MultiSkins[4] = Texture'DeusExCharacters.Skins.JCDentonTex1';
			MultiSkins[5] = Texture'DeusExCharacters.Skins.SmugglerTex2';
			MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
			MultiSkins[7] = FireTexture'Effects.Fire.SparkFX1';
		break;
	}
	
	//== in white house mission you play as sec bot, so we nullify skins
	if(caps(info.mapName) == "WHITEHOUSE") {
		Mesh=Mesh(DynamicLoadObject("HDTPCharacters.HDTPSecBot2", class'Mesh', True));
		MultiSkins[0] = Texture'DeusExCharacters.Skins.RobotWeaponTex1';
		MultiSkins[1] = Texture(DynamicLoadObject("HDTPCharacters.Skins.HDTPSecBot2tex1", class'Texture', True));
	}
	if(caps(info.mapName) == "HONGKONG") {
		Mesh=Mesh(DynamicLoadObject("DeusExCharacters.GFM_SuitSkirt", class'Mesh', True));
		MultiSkins[0] = Texture'DeusExCharacters.Skins.WIBTex0';
		MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';
		MultiSkins[2] = Texture'DeusExCharacters.Skins.WIBTex0';
		MultiSkins[3] = Texture'DeusExCharacters.Skins.LegsTex2';
		MultiSkins[4] = Texture'DeusExCharacters.Skins.WIBTex1';
		MultiSkins[5] = Texture'DeusExCharacters.Skins.WIBTex1';
		MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex3';
		MultiSkins[7] = Texture'DeusExCharacters.Skins.LensesTex4';
	}
}

//this is to make sure convos work if actors are far away from e o
function CheckActiveConversationRadius()
{
	local int checkRadius;

	// Ignore if conPlay.GetForcePlay() returns True

	if ((conPlay != None) && (!conPlay.GetForcePlay()) && (conPlay.ConversationStarted()) && (conPlay.displayMode == DM_FirstPerson) && (conPlay.StartActor != None))
	{
		// If this was invoked via a radius, then check to make sure the player doesn't 
		// exceed that radius plus 

		if (conPlay.con.bInvokeRadius) 
			checkRadius = conPlay.con.radiusDistance + 3000;
		else
			checkRadius = 3000; //was 300...too close. Now Gary Savage can talk on and on in the training in a51

		// Add the collisioncylinder since some objects are wider than others
		checkRadius += conPlay.StartActor.CollisionRadius;

		if (VSize(conPlay.startActor.Location - Location) > checkRadius)
		{
			// Abort the conversation
			conPlay.TerminateConversation(True);
		}
	}
}

function bool CheckActorDistances()
{
	//mwahaaha! terrible hack, i know -T.
}

// ----------------------------------------------------------------------
// ShowMainMenu()
//
// overrides the original so we can use our custom ApocalypseInsideMenu.
// ----------------------------------------------------------------------
exec function ShowMainMenu()
{
	local DeusExRootWindow root;
	local DeusExLevelInfo info;
	info = GetLevelInfo();

	root = DeusExRootWindow(rootWindow);
	if (root != None)
		root.InvokeMenu(class'ApocalypseInside.ApocalypseInsideMenuMain');
}

// ----------------------------------------------------------------------
// ShowIntro()
// ----------------------------------------------------------------------

function ShowIntro(optional bool bStartNewGame)
{
	if (DeusExRootWindow(rootWindow) != None)
		DeusExRootWindow(rootWindow).ClearWindowStack();

	bStartNewGameAfterIntro = bStartNewGame;

	// Make sure all augmentations are OFF before going into the intro
	AugmentationSystem.DeactivateAll();

	// Reset the player
	Level.Game.SendPlayer(Self, "AiPrologue");
}

// ----------------------------------------------------------------------
// ShowCredits()
//
// allows us to use custom credits window
// ----------------------------------------------------------------------
/*
function ShowCredits(optional bool bLoadIntro)
{
	local DeusExRootWindow root;
	local burdenCreditsWindow winCredits;

	root = DeusExRootWindow(rootWindow);

	if (root != None)
	{
		// Show the credits screen and force the game not to pause
		// if we're showing the credits after the endgame
		winCredits = burdenCreditsWindow(root.InvokeMenuScreen(Class'burdenCreditsWindow', bLoadIntro));
		winCredits.SetLoadIntro(bLoadIntro);
	}
}
*/

// ----------------------------------------------------------------------
// UpdatePlayerSkin()
// ----------------------------------------------------------------------

function UpdatePlayerSkin()
{
	local UberAlles uber;

	foreach AllActors(class'UberAlles', uber)
		break;

	if (uber != None)
		uber.SetSkin(Self);

}

//invokes new hud initially for infolinks. found how to do it on http://www.offtopicproductions.com/tacks/CustomInfolinkPortraits/GameReaction%20Forums%20-%20Custom%20InfoLink%20Portraits.htm

function Possess()
{

local DeusExRootWindow root;

Super.Possess();

root = DeusExRootWindow(rootWindow);

root.hud.Destroy();
root.hud = DeusexHUD(root.NewChild(Class'ApocalypseInsideHUD'));

root.hud.UpdateSettings(Self);
root.hud.SetWindowAlignments(HALIGN_Full,VALIGN_Full, 0, 0);

}

// ----------------------------------------------------------------------
// StartDataLinkTransmission()
//
// Locates and starts the DataLink passed in
// ----------------------------------------------------------------------

function Bool StartDataLinkTransmission(
	String datalinkName,
	Optional DataLinkTrigger datalinkTrigger)
{
	local Conversation activeDataLink;
	local bool bDataLinkPlaySpawned;

	// Don't allow DataLinks to start if we're in PlayersOnly mode
	if ( Level.bPlayersOnly )
		return False;

	activeDataLink = GetActiveDataLink(datalinkName);

	if ( activeDataLink != None )
	{
		// Search to see if there's an active DataLinkPlay object
		// before creating one

		if ( dataLinkPlay == None )
		{

			datalinkPlay = Spawn(class'AiDataLinkPlay');
			bDataLinkPlaySpawned = True;
		}

		// Call SetConversation(), which returns
		if (datalinkPlay.SetConversation(activeDataLink))
		{
			datalinkPlay.SetTrigger(datalinkTrigger);

			if (datalinkPlay.StartConversation(Self))
			{
				return True;
			}
			else
			{
				// Datalink must already be playing, or in queue
				if (bDataLinkPlaySpawned)
				{
					datalinkPlay.Destroy();
					datalinkPlay = None;
				}

				return False;
			}
		}
		else
		{
			// Datalink must already be playing, or in queue
			if (bDataLinkPlaySpawned)
			{
				datalinkPlay.Destroy();
				datalinkPlay = None;
			}
			return False;
		}
	}
	else
	{
		return False;
	}
}

// ----------------------------------------------------------------------
// InitializeSubSystems()
// ----------------------------------------------------------------------

function InitializeSubSystems()
{
	//Super.InitializeSubSystems();
	//AugmentationSystem.Destroy();
	//SkillSystem.Destroy();

	// Spawn the BarkManager
	if (BarkManager == None)
		BarkManager = Spawn(class'BarkManager', Self);

	// Spawn the Color Manager
	CreateColorThemeManager();
    ThemeManager.SetOwner(self);

	// install the augmentation system if not found
	if (AugmentationSystem == None)
	{
		AugmentationSystem = Spawn(class'AiAugmentationManager', Self);
		AugmentationSystem.CreateAugmentations(Self);
		AugmentationSystem.AddDefaultAugmentations();
        AugmentationSystem.SetOwner(Self);
	}
	else
	{
		AugmentationSystem.SetPlayer(Self);
        AugmentationSystem.SetOwner(Self);
	}

	// install the skill system if not found
	if (SkillSystem == None)
	{
		SkillSystem = Spawn(class'AiSkillManager', Self);
		SkillSystem.CreateSkills(Self);
	}
	else
	{
		SkillSystem.SetPlayer(Self);
	}

   if ((Level.Netmode == NM_Standalone) || (!bBeltIsMPInventory))
   {
      // Give the player a keyring
      //CreateKeyRing();
   }
}

//   Let HDTP know that Tantalus is not JC denton.

function bool Facelift(bool bOn)
	{
	}

// ----------------------------------------------------------------------
// CreateThemeManager()
// ----------------------------------------------------------------------

function CreateColorThemeManager()
{
	if (ThemeManager == None)
	{
		ThemeManager = Spawn(Class'ColorThemeManager', Self);

		// Add all default themes.

		// Menus
		ThemeManager.AddTheme(Class'ColorThemeMenu_Default');
		ThemeManager.AddTheme(Class'ColorThemeMenu_BlueAndGold');
		ThemeManager.AddTheme(Class'ColorThemeMenu_CoolGreen');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Cops');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Cyan');
		ThemeManager.AddTheme(Class'ColorThemeMenu_DesertStorm');
		ThemeManager.AddTheme(Class'ColorThemeMenu_DriedBlood');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Dusk');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Earth');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Green');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Grey');
		ThemeManager.AddTheme(Class'ColorThemeMenu_IonStorm');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Lava');
		ThemeManager.AddTheme(Class'ColorThemeMenu_NightVision');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Ninja');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Olive');
		ThemeManager.AddTheme(Class'ColorThemeMenu_PaleGreen');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Pastel');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Plasma');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Primaries');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Purple');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Red');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Seawater');
		ThemeManager.AddTheme(Class'ColorThemeMenu_SoylentGreen');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Starlight');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Steel');
		ThemeManager.AddTheme(Class'ColorThemeMenu_SteelGreen');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Superhero');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Terminator');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Violet');

		// HUD
		ThemeManager.AddTheme(Class'ColorThemeHUD_Default');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Amber');
		ThemeManager.AddTheme(Class'ColorThemeHUD_ApostleMod');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Cops');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Cyan');
		ThemeManager.AddTheme(Class'ColorThemeHUD_DarkBlue');
		ThemeManager.AddTheme(Class'ColorThemeHUD_DesertStorm');
		ThemeManager.AddTheme(Class'ColorThemeHUD_DriedBlood');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Dusk');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Grey');
		ThemeManager.AddTheme(Class'ColorThemeHUD_IonStorm');
		ThemeManager.AddTheme(Class'ColorThemeHUD_NightVision');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Ninja');
		ThemeManager.AddTheme(Class'ColorThemeHUD_PaleGreen');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Pastel');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Plasma');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Primaries');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Purple');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Red');
		ThemeManager.AddTheme(Class'ColorThemeHUD_SoylentGreen');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Starlight');
		ThemeManager.AddTheme(Class'ColorThemeHUD_SteelGreen');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Superhero');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Terminator');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Violet');
	}
}

defaultproperties
{
    TruePlayerName="Tantalus Denton"
	BindName=Tantalus
    Credits=0
	MenuThemeName="ApostleMod"
	HUDThemeName="ApostleMod"
    strStartMap="AiPrologue"
    CarcassType=Class'JCDentonMaleCarcass'
    Mesh=LodMesh'DeusExCharacters.GM_Trench'
    MultiSkins(0)=Texture'ApocalypseInside.Skins.TantalusFace'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.StantonDowdTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(3)=Texture'ApocalypseInside.Skins.TantalusFace'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.JockTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.SmugglerTex2'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex4'
    MultiSkins(7)=FireTexture'Effects.Laser.LaserSpot2'
    FamiliarName="Tantalus Denton"
    UnfamiliarName="Tantalus Denton"
    Tag="TantalusTag"
	Energy=150.00
    EnergyMax=200.00
}
