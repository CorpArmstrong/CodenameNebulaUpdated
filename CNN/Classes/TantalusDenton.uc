//=============================================================================
// TantalusDenton.uc
//=============================================================================
class TantalusDenton extends JCDentonMale;

var travel ChineseSkillController chinese;
var private QuestSystem questSystem;

//var travel AiAugmentationManager AugmentationSystem;

//var CASConPlay conplay; UNCOMMENT!

//var AiDataLinkPlay aidataLinkPlay;

//var String playerBias;

// ----------------------------------------------------------------------
// PostBeginPlay()
//
// set up the augmentation and skill systems
// ----------------------------------------------------------------------

function PostBeginPlay()
{
    chinese = Spawn(class'ChineseSkillController', none);
    Super.PostBeginPlay();
}

event TravelPostAccept()
{
    local flagbase flags;
    local DeusExLevelInfo info;
    info = DeusExPlayer(GetPlayerPawn()).GetLevelInfo();
    super.TravelPostAccept();

    flags = flagbase;

    switch(PlayerSkin)
    {
        case 0:
            flags.SetBool('Bias_UNATCO',True);
            MultiSkins[0] = Texture'CNN.Skins.TantalusFace';
            MultiSkins[1] = Texture'DeusExCharacters.Skins.SmugglerTex2';
            MultiSkins[2] = Texture'DeusExCharacters.Skins.ThugMale3Tex2';
            MultiSkins[3] = Texture'CNN.Skins.TantalusFace';
            MultiSkins[4] = Texture'DeusExCharacters.Skins.JockTex1';
            MultiSkins[5] = Texture'DeusExCharacters.Skins.SmugglerTex2';
            MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
            MultiSkins[7] = FireTexture'Effects.Laser.LaserSpot2';
        break;
        case 1:
            flags.SetBool('Bias_Triad',True);
            MultiSkins[0] = Texture'CNN.Skins.TantalusAsian';
            MultiSkins[1] = Texture'DeusExCharacters.Skins.JockTex2';
            MultiSkins[2] = Texture'DeusExCharacters.Skins.ThugMaleTex3';
			MultiSkins[3] = None;
            MultiSkins[4] = Texture'DeusExCharacters.Skins.SmugglerTex1';
			MultiSkins[5] = None;
            MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex2';
            MultiSkins[7] = FireTexture'Effects.Laser.LaserSpot2';
			Texture = Texture'DeusExItems.Skins.PinkMaskTex';
            //MultiSkins[7] = FireTexture'Effects.Fire.Spark_Electric'; //causes ucc to return error
        break;
        case 2:
            flags.SetBool('Bias_MJ12',True);
            Mesh=LodMesh'DeusExCharacters.GM_DressShirt_B';
            MultiSkins[0] = Texture'DeusExCharacters.Skins.ThugMale3Tex1';
            MultiSkins[1] = Texture'DeusExCharacters.Skins.MJ12TroopTex1';
			MultiSkins[2] = None;
            MultiSkins[3] = Texture'CNN.Skins.TantalusBlack';
			MultiSkins[4] = None;
            MultiSkins[5] = Texture'DeusExItems.Skins.GrayMaskTex';
            MultiSkins[6] = FireTexture'Effects.Laser.LaserSpot2';
			MultiSkins[7] = None;
			Texture = Texture'DeusExItems.Skins.PinkMaskTex';
        break;
        case 3:
            flags.SetBool('Bias_NSF',True);
            Mesh=LodMesh'DeusExCharacters.GM_DressShirt';
            MultiSkins[0] = Texture'CNN.Skins.TantalusGinger';
            MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';
            MultiSkins[2] = Texture'DeusExItems.Skins.PinkMaskTex';
            MultiSkins[3] = Texture'DeusExCharacters.Skins.ThugMale3Tex2';
            MultiSkins[4] = Texture'DeusExItems.Skins.PinkMaskTex';
            MultiSkins[5] = Texture'CNN.Skins.NSFJacket';
            MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
            //MultiSkins[7] = FireTexture'Effects.water.WaterDrop1';
        break;
        case 4:
            flags.SetBool('Bias_Templar',True);
            MultiSkins[0] = Texture'CNN.Skins.TantalusGoatee';
            MultiSkins[1] = Texture'DeusExCharacters.Skins.StantonDowdTex2';
			MultiSkins[2] = Texture'DeusExCharacters.Skins.MJ12TroopTex1';
			MultiSkins[3] = None;
            MultiSkins[4] = Texture'DeusExCharacters.Skins.JockTex1';
            MultiSkins[5] = Texture'DeusExCharacters.Skins.SmugglerTex2';
            MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
            MultiSkins[7] = FireTexture'Effects.Laser.LaserSpot2';
        break;
    }

    //== in white house mission you play as sec bot, so we nullify skins
    if (caps(info.mapName) == "WHITEHOUSE")
    {
        Mesh=Mesh(DynamicLoadObject("HDTPCharacters.HDTPSecBot2", class'Mesh', True));
        MultiSkins[0] = Texture'DeusExCharacters.Skins.RobotWeaponTex1';
        MultiSkins[1] = Texture(DynamicLoadObject("HDTPCharacters.Skins.HDTPSecBot2tex1", class'Texture', True));
    }

    if (caps(info.mapName) == "HONGKONG")
    {
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

// Invincibility gate for the deferred-ESC cutscene cleanup. When the
// CNNCutsceneCleanup flag is set, CNNBaseIngameCutscene has decided
// that the player is still inside the cutscene's PlayerStart radius —
// UE1 same-map URL travel would ignore the #tag and respawn at the
// default PlayerStart (which on MoonIntro is inside the meteor
// explosion). We keep the player alive while the IP chain carries
// them out of that radius. The flag is cleared in CheckIntroFlags on
// the post-reload mission instance.
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    if (FlagBase != none && FlagBase.GetBool('CNNCutsceneCleanup'))
        return;
    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
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

// Intentional override: disables the parent's per-frame auto-terminate
// of conversations when actors drift too far apart. CNN's scripted
// scenes (cutscenes, scripted movements, holocomm) need that to be a
// no-op so conversations don't get killed mid-cutscene. Callers ignore
// the return value (vanilla DeusExPlayer has the same pattern).
function bool CheckActorDistances()
{
    return false;
}

// ----------------------------------------------------------------------
// ShowMainMenu()
//
// Overrides the original so we can use our custom ApocalypseInsideMenu.
//
// ESC during an in-progress in-map cutscene must end the cutscene (skip
// to the post-cutscene location), not open the main menu. CNN's cutscenes
// run on the gameplay map via CNNBaseIngameCutscene (extends MissionScript),
// so vanilla's MissionNumber==98/99 + MissionEndgame guards don't catch
// them. Without this branch, the menu opens while CameraPoint/Interpolation
// chains keep running and `player.bHidden` stays true — when the menu
// closes the player is invisible with broken collision/eye height.
// ----------------------------------------------------------------------
exec function ShowMainMenu()
{
    local DeusExRootWindow root;
    local CNNBaseIngameCutscene cs;

    foreach AllActors(class'CNNBaseIngameCutscene', cs)
    {
        if (!cs.IsArrivalCompleted)
        {
            if (conPlay != None)
                conPlay.TerminateConversation();
            cs.SendPlayerOnce();
            return;
        }
        break;
    }

    root = DeusExRootWindow(rootWindow);

    if (root != None)
    {
        root.InvokeMenu(class'CNN.CNNMenuMainTest');
    }
}

// ----------------------------------------------------------------------
// ShowIntro()
// ----------------------------------------------------------------------

function ShowIntro(optional bool bStartNewGame)
{
    if (DeusExRootWindow(rootWindow) != None)
    {
        DeusExRootWindow(rootWindow).ClearWindowStack();
    }

    AugmentationSystem.DeactivateAll();

    if (bStartNewGame)
    {
        // CNN has no separate intro map — we go straight to the
        // gameplay map. Vanilla DX1's "New Game" path runs an intro
        // map first, then PostIntro calls StartNewGame which does
        // the heavy cleanup (ResetPlayer destroys + recreates
        // AugmentationSystem/SkillSystem/inventory; DeleteSaveGameFiles
        // wipes .dxs). Skipping that bridge leaves stale subsystem
        // references and player rail-mode state in .dxs, which breaks
        // the cutscene on replay. Run StartNewGame directly so the
        // gameplay map gets the same fresh slate vanilla would have
        // produced.
        StartNewGame(strStartMap);
    }
    else
    {
        bStartNewGameAfterIntro = bStartNewGame;
        Level.Game.SendPlayer(self, strStartMap);
    }
}

// ----------------------------------------------------------------------
// ShowCredits()
//
// allows us to use custom credits window
// ----------------------------------------------------------------------

function ShowCredits(optional bool bLoadIntro)
{
    local DeusExRootWindow root;
    local CNNCreditsWindow winCredits;

    root = DeusExRootWindow(rootWindow);

    if (root != None)
    {
        // Show the credits screen and force the game not to pause
        // if we're showing the credits after the endgame
        winCredits = CNNCreditsWindow(root.InvokeMenuScreen(Class'CNNCreditsWindow', bLoadIntro));
        winCredits.SetLoadIntro(bLoadIntro);
    }
}

exec function ShowCreditsTest()
{
	ShowCredits(true);
}

// ----------------------------------------------------------------------
// UpdatePlayerSkin()
// ----------------------------------------------------------------------

function UpdatePlayerSkin()
{
    local UberAlles uber;

    foreach AllActors(class'UberAlles', uber)
        break;

    if (uber != None)
    {
        uber.SetSkin(self);
    }
}

//invokes new hud initially for infolinks. found how to do it on http://www.offtopicproductions.com/tacks/CustomInfolinkPortraits/GameReaction%20Forums%20-%20Custom%20InfoLink%20Portraits.htm

function Possess()
{
    local DeusExRootWindow root;
    super.Possess();

    root = DeusExRootWindow(rootWindow);

    root.hud.Destroy();
    root.hud = DeusexHUD(root.NewChild(Class'CNNHUD'));

    root.hud.UpdateSettings(self);
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
    if (Level.bPlayersOnly)
    {
        return false;
    }

    activeDataLink = GetActiveDataLink(datalinkName);

    if (activeDataLink != none)
    {
        // Search to see if there's an active DataLinkPlay object
        // before creating one

        if (dataLinkPlay == none)
        {
            datalinkPlay = Spawn(class'AiDataLinkPlay');
            bDataLinkPlaySpawned = true;
        }

        // Call SetConversation(), which returns
        if (datalinkPlay.SetConversation(activeDataLink))
        {
            datalinkPlay.SetTrigger(datalinkTrigger);

            if (datalinkPlay.StartConversation(self))
            {
                return true;
            }
            else
            {
                // Datalink must already be playing, or in queue
                if (bDataLinkPlaySpawned)
                {
                    datalinkPlay.Destroy();
                    datalinkPlay = none;
                }

                return false;
            }
        }
        else
        {
            // Datalink must already be playing, or in queue
            if (bDataLinkPlaySpawned)
            {
                datalinkPlay.Destroy();
                datalinkPlay = none;
            }

            return false;
        }
    }
    else
    {
        return false;
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
    if (BarkManager == none)
    {
        BarkManager = Spawn(class'BarkManager', self);
    }

    // Spawn the Color Manager
    CreateColorThemeManager();
    ThemeManager.SetOwner(self);

    // install the augmentation system if not found
    if (AugmentationSystem == none)
    {
        AugmentationSystem = Spawn(class'AiAugmentationManager', self);
        AugmentationSystem.CreateAugmentations(self);
        AugmentationSystem.AddDefaultAugmentations();
        AugmentationSystem.SetOwner(self);
    }
    else
    {
        AugmentationSystem.SetPlayer(self);
        AugmentationSystem.SetOwner(self);
    }

    // install the skill system if not found
    if (SkillSystem == none)
    {
        SkillSystem = Spawn(class'AiSkillManager', self);
        SkillSystem.CreateSkills(self);
    }
    else
    {
        SkillSystem.SetPlayer(self);
    }

    // Give the player a keyring
    if ((Level.Netmode == NM_Standalone) || (!bBeltIsMPInventory))
    {
        CreateKeyRing();
    }
}

//   Let HDTP know that Tantalus is not JC denton.
function bool Facelift(bool bOn) {}

// ----------------------------------------------------------------------
// CreateThemeManager()
// ----------------------------------------------------------------------

function CreateColorThemeManager()
{
    if (ThemeManager == none)
    {
        ThemeManager = Spawn(Class'ColorThemeManager', self);

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

// ----------------------------------------------------------------------
// StartConversation()
//
// Checks to see if a valid conversation exists for this moment in time
// between the ScriptedPawn and the PC.  If so, then it triggers the
// conversation system and returns TRUE when finished.
// ----------------------------------------------------------------------
// TODO: Fix native class first, than uncomment this method!
/*
function bool StartConversation(
    Actor invokeActor,
    EInvokeMethod invokeMethod,
    optional Conversation con,
    optional bool bAvoidState,
    optional bool bForcePlay
    )
{
    local DeusExRootWindow root;

    root = DeusExRootWindow(rootWindow);

    // First check to see the actor has any conversations or if for some
    // other reason we're unable to start a conversation (typically if
    // we're alread in a conversation or there's a UI screen visible)

    if ((!bForcePlay) && ((invokeActor.conListItems == none) || (!CanStartConversation())))
    {
        return false;
    }

    // Make sure the other actor can converse
    if ((!bForcePlay) && ((ScriptedPawn(invokeActor) != none) && (!ScriptedPawn(invokeActor).CanConverse())))
    {
        return false;
    }

    // If we have a conversation passed in, use it.  Otherwise check to see
    // if the passed in actor actually has a valid conversation that can be
    // started.

    if (con == none)
    {
        con = GetActiveConversation(invokeActor, invokeMethod);
    }

    // If we have a conversation, put the actor into "Conversation Mode".
    // Otherwise just return false.
    //
    // TODO: Scan through the conversation and put *ALL* actors involved
    //       in the conversation into the "Conversation" state??

    if (con != none)
    {
        // Check to see if this conversation is already playing.  If so,
        // then don't start it again.  This prevents a multi-bark conversation
        // from being abused.
        if ((conPlay != none) && (conPlay.con == con))
        {
            return false;
        }

        // Now check to see if there's a conversation playing that is owned
        // by the InvokeActor *and* the player has a speaking part *and*
        // it's a first-person convo, in which case we want to abort here.
        if (((conPlay != none) && (conPlay.invokeActor == invokeActor)) &&
            (conPlay.con.bFirstPerson) &&
            (conPlay.con.IsSpeakingActor(self)))
        {
            return false;
        }

        // Check if the person we're trying to start the conversation
        // with is a Foe and this is a Third-Person conversation.
        // If so, ABORT!
        if ((!bForcePlay) && ((!con.bFirstPerson) && (ScriptedPawn(invokeActor) != none) && (ScriptedPawn(invokeActor).GetPawnAllianceType(self) == ALLIANCE_Hostile)))
        {
            return false;
        }

        // If the player is involved in this conversation, make sure the
        // scriptedpawn even WANTS to converse with the player.
        //
        // I have put a hack in here, if "con.bCanBeInterrupted"
        // (which is no longer used as intended) is set, then don't
        // call the ScriptedPawn::CanConverseWithPlayer() function

        if ((!bForcePlay) && ((con.IsSpeakingActor(self)) && (!con.bCanBeInterrupted) && (ScriptedPawn(invokeActor) != none) && (!ScriptedPawn(invokeActor).CanConverseWithPlayer(self))))
        {
            return false;
        }

        // Hack alert!  If this is a Bark conversation (as denoted by the
        // conversation name, since we don't have a field in ConEdit),
        // then force this conversation to be first-person
        if (Left(con.conName, Len(con.conOwnerName) + 5) == (con.conOwnerName $ "_Bark"))
        {
            con.bFirstPerson = true;
        }

        // Make sure the player isn't ducking.  If the player can't rise
        // to start a third-person conversation (blocked by geometry) then
        // immediately abort the conversation, as this can create all
        // sorts of complications (such as the player standing through
        // geometry!!)

        if ((!con.bFirstPerson) && (ResetBasedPawnSize() == false))
        {
            return false;
        }

        // If ConPlay exists, end the current conversation playing
        if (conPlay != none)
        {
            // If we're already playing a third-person conversation, don't interrupt with
            // another *radius* induced conversation (frobbing is okay, though).
            if ((conPlay.con != none) && (conPlay.con.bFirstPerson) && (invokeMethod == IM_Radius))
            {
                return false;
            }

            conPlay.InterruptConversation();
            conPlay.TerminateConversation();
        }

        // If this is a first-person conversation _and_ a DataLink is already
        // playing, then abort.  We don't want to give the user any more
        // distractions while a DL is playing, since they're pretty important.
        if (dataLinkPlay != none)
        {
            if (con.bFirstPerson)
            {
                return false;
            }
            else
            {
                dataLinkPlay.AbortAndSaveHistory();
            }
        }

        // Found an active conversation, so start it
        // CorpArmstrong: Inject our class here:
        //conPlay = Spawn(class'CASConPlay');	UNCOMMENT!
		conPlay = Spawn(class'ConPlay');
        conPlay.SetStartActor(invokeActor);
        conPlay.SetConversation(con);
        conPlay.SetForcePlay(bForcePlay);
        conPlay.SetInitialRadius(VSize(Location - invokeActor.Location));

        // If this conversation was invoked with IM_Named, then save away
        // the current radius so we don't abort until we get outside
        // of this radius + 100.
        if ((invokeMethod == IM_Named) || (invokeMethod == IM_Frob))
        {
            conPlay.SetOriginalRadius(con.radiusDistance);
            con.radiusDistance = VSize(invokeActor.Location - Location);
        }

        // If the invoking actor is a ScriptedPawn, then force this person
        // into the conversation state
        if ((!bForcePlay) && (ScriptedPawn(invokeActor) != none))
        {
            ScriptedPawn(invokeActor).EnterConversationState(con.bFirstPerson, bAvoidState);
        }

        // Do the same if this is a DeusExDecoration
        if ((!bForcePlay) && (DeusExDecoration(invokeActor) != none))
        {
            DeusExDecoration(invokeActor).EnterConversationState(con.bFirstPerson, bAvoidState);
        }

        // If this is a third-person convo, we're pretty much going to
        // pause the game.  If this is a first-person convo, then just
        // keep on going..
        //
        // If this is a third-person convo *AND* 'bForcePlay' == True,
        // then use first-person mode, as we're playing an intro/endgame
        // sequence and we can't have the player in the convo state (bad bad bad!)

        if ((!con.bFirstPerson) && (!bForcePlay))
        {
            GotoState('Conversation');
        }
        else
        {
            if (!conPlay.StartConversation(self, invokeActor, bForcePlay))
            {
                AbortConversation(true);
            }
        }

        return true;
    }
    else
    {
        return false;
    }
}
Commented out to test build*/

function ToggleCameraStateNoDebugMessage(SecurityCamera cam)
{
   if (cam.bActive)
   {
      cam.UnTrigger(none, none);
      cam.team = -1;
   }
   else
   {
      MakeCameraAlly(cam);
      cam.Trigger(none, none);
   }

   // Make sure the camera isn't in bStasis=True
   // so it responds to our every whim.
   cam.bStasis = False;
}

function SetInvisible(bool B)
{
    if (!bAdmin && (Level.Netmode != NM_Standalone))
    {
        return;
    }

    if (B)
    {
        bHidden = true;
        Visibility = 0;
        // DEUS_EX STM - added AI invisibility
        bDetectable = false;
    }
    else
    {
        bHidden = false;
        Visibility = default.Visibility;
        // DEUS_EX STM - added AI invisibility
        bDetectable = true;
    }
}

function GoalCompleted( Name goalName )
{
    super.GoalCompleted(goalName);
    UpdateQuestSystem();
}

function UpdateQuestSystem()
{
    local QuestSystem currentQuestSystem;

    if (questSystem == none)
    {
        foreach AllActors(class 'QuestSystem', currentQuestSystem, '')
        {
            questSystem = currentQuestSystem;
            break;
        }
    }

    if (questSystem != none)
    {
        questSystem.Update();
    }
}

// ----------------------------------------------------------------------
// CNNTestEnding()
//
// Sets the accumulated-state flags for one L2 ending so it can be tested
// without replaying the level. Chapter06L2.CheckEndingReached() picks the
// ending up on its next Timer tick and travels.
//
// From the console, on 06_OpheliaL2:
//     CNNTestEnding hijack | transcend | conspiracy | mutiny
//
// Unlike EditFlags/Legend this needs no bCheatsEnabled, because those route
// through InvokeUIScreen and are gated; an exec function is callable
// directly. Setting a flag by hand in the EditFlags UI works too -- this
// just spares you knowing which flags matter for which ending.
// ----------------------------------------------------------------------

exec function CNNTestEnding(string which)
{
    which = Caps(which);

    // Cleared first so repeat calls in one session don't accumulate and let
    // an earlier, higher-priority ending win.
    FlagBase.SetBool('PlayerDiedOnL2', false);
    FlagBase.SetBool('PlayerDiedDuringUpload', false);
    FlagBase.SetBool('CanArmMagdalene', false);
    FlagBase.SetBool('MikeWongExposed', false);
    FlagBase.SetBool('SeedsOfDoubtPlanted', false);
    FlagBase.SetBool('FinalGoodbyePlayed', false);

    if (which == "MUTINY")
    {
        FlagBase.SetBool('PlayerDiedOnL2', true);
    }
    else if (which == "HIJACK")
    {
        FlagBase.SetBool('CanArmMagdalene', true);
        FlagBase.SetBool('FinalGoodbyePlayed', true);
    }
    else if (which == "TRANSCEND")
    {
        FlagBase.SetBool('MikeWongExposed', true);
        FlagBase.SetBool('FinalGoodbyePlayed', true);
    }
    else if (which == "CONSPIRACY")
    {
        FlagBase.SetBool('FinalGoodbyePlayed', true);
    }
    else
    {
        ClientMessage("CNNTestEnding: use hijack, transcend, conspiracy or mutiny");
        return;
    }

    ClientMessage("CNNTestEnding: " $ which $ " -- traveling on next mission tick");
}

// ----------------------------------------------------------------------
// CNNWhere()
//
// Prints and LOGS the player's exact position, facing and zone.
//
// Needed because bug reports like "there is an invisible wall here" or "the
// geometry renders wrong here" are not actionable without coordinates --
// L2's actors and brushes can all be looked up in L2_export.t3d, but only
// if we know where "here" is. Logged as well as shown, so it survives into
// the session transcript that `cnn log "CNN L2"` reads back.
// ----------------------------------------------------------------------

exec function CNNWhere()
{
    local string zoneName;
    local DeusExLevelInfo info;
    local string mapName;

    if (Region.Zone != None)
        zoneName = string(Region.Zone.Name);
    else
        zoneName = "none";

    info = GetLevelInfo();
    if (info != None)
        mapName = info.mapName;
    else
        mapName = "unknown";

    ClientMessage("CNNWhere: " $ int(Location.X) $ " " $ int(Location.Y) $ " " $
                  int(Location.Z) $ "  yaw=" $ Rotation.Yaw $ "  zone=" $ zoneName);

    Log("CNN L2 where: map=" $ mapName $
        " loc=(" $ int(Location.X) $ ", " $ int(Location.Y) $ ", " $ int(Location.Z) $ ")" $
        " yaw=" $ Rotation.Yaw $ " pitch=" $ Rotation.Pitch $
        " zone=" $ zoneName $
        " headRegionZone=" $ string(HeadRegion.Zone.Name));
}

// ----------------------------------------------------------------------
// CNNGoto()
//
// Teleports to a named L2 landmark. Testing L2 means reaching specific
// coordinates -- the Samantha Reed trigger, Magdalene, the tube -- and the
// route between them was never mapped, so walking there means hunting for
// doors. The coordinates themselves are exact (measured from
// L2_export.t3d; see CNNDocs/L2_WalkthroughMap.md), so jumping straight to
// them is the reliable way in.
//
// Landmarks are L2's. Running this on another map will drop you outside
// the world -- that is what the ghost hint below is for.
//
// Like CNNTestEnding this is an exec function, so it needs no cheats.
// ----------------------------------------------------------------------

exec function CNNGoto(string where)
{
    local vector dest, tryLoc;
    local int attempt;
    local DeusExLevelInfo info;
    local bool bKnown;

    where = Caps(where);
    bKnown = true;

    if      (where == "START")     dest = vect(-1044, -1900,   891);  // arrival
    else if (where == "SAM")       dest = vect(  841, -2031,     8);  // MeetSamanthaReed trigger
    else if (where == "SAMANTHA")  dest = vect(  971, -3991, -1284);  // Samantha Reed herself
    else if (where == "MAGDALENE") dest = vect( 1083, -2133, -1335);  // Magdalene, level start
    else if (where == "MAGLAB")    dest = vect(  878, -1682,     0);  // where OpenLabs moves her
    else if (where == "SOLDIERS")  dest = vect(  908, -1587,    24);  // MJ12Sergeant -- starts MeetSoldiers
    else if (where == "BATTLE")    dest = vect(  874, -1850,    -3);  // CommCenterBattleSpawnPoint
    else if (where == "IOT")       dest = vect(  701, -2861, -1348);  // clearance terminal
    else if (where == "WONG")      dest = vect(  782, -4058, -1301);
    else if (where == "MEPH")      dest = vect(  866, -4480, -1233);
    else if (where == "JC")        dest = vect(  894, -2315, -1303);  // JC Avatar
    else if (where == "TUBE")      dest = vect(  843, -6084,     8);  // LoadingInTube trigger
    else if (where == "FINAL")     dest = vect( 1801, -6412,     8);  // MagdaleneInsideTube -- ending gate
    else bKnown = false;

    if (!bKnown)
    {
        ClientMessage("CNNGoto: start sam samantha magdalene maglab soldiers battle iot wong meph jc tube final");
        return;
    }

    Velocity = vect(0, 0, 0);
    Acceleration = vect(0, 0, 0);

    // The landmarks are actor ORIGINS taken from the map export. Triggers and
    // NPCs sit near floor level, so teleporting the player's centre there
    // buries the bottom of their collision cylinder in the floor and
    // SetLocation refuses outright -- the first version of this function
    // reported BLOCKED for every ground-level landmark. Lift the destination
    // clear of the floor and climb if the first try is still occupied.
    for (attempt = 0; attempt < 4; attempt++)
    {
        tryLoc = dest;
        tryLoc.Z += 50 + (attempt * 50);

        if (SetLocation(tryLoc))
        {
            // Logged as well as shown on the HUD: ClientMessage never reaches
            // the log, so a run driven from the console leaves no trace of
            // where the player went. "cnn log CNN L2" then reads back as a
            // session transcript -- teleports interleaved with the flag
            // changes they caused.
            ClientMessage("CNNGoto: " $ where $ " " $ tryLoc);
            Log("CNN L2 goto: " $ where $ " -> " $ tryLoc);
            return;
        }
    }

    // Every offset refused. By far the most likely cause is being on the
    // wrong map -- these are L2 coordinates, and anywhere else they land in
    // solid geometry. Worth naming, because "blocked" on its own sends you
    // hunting for a collision problem that isn't there. (Found the hard way:
    // running this from a startup -EXEC file executes it before `open`
    // finishes, so it fires in the previous level and always reports blocked.)
    info = GetLevelInfo();
    if ((info != None) && (Caps(info.mapName) != "06_OPHELIAL2"))
    {
        ClientMessage("CNNGoto: these are 06_OpheliaL2 landmarks -- you are on " $ info.mapName);
        Log("CNN L2 goto: " $ where $ " refused, wrong map (" $ info.mapName $ ")");
        return;
    }

    ClientMessage("CNNGoto: " $ where $ " is blocked -- type ghost first, then retry");
    Log("CNN L2 goto: " $ where $ " BLOCKED at " $ dest);
}

defaultproperties
{
    TruePlayerName="Blake Denton"
    BindName=Tantalus
    Credits=0
    MenuThemeName="Tantalus theme"
    HUDThemeName="Tantalus theme"
    strStartMap="05_MoonIntro"
    CarcassType=Class'JCDentonMaleCarcass'
    Mesh=LodMesh'DeusExCharacters.GM_Trench'
    MultiSkins(0)=Texture'CNN.Skins.TantalusFace'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.StantonDowdTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(3)=Texture'CNN.Skins.TantalusFace'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.JockTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.SmugglerTex2'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex4'
    MultiSkins(7)=FireTexture'Effects.Laser.LaserSpot2'
    FamiliarName="Tantalus"
    UnfamiliarName="Tantalus"
    Tag="TantalusTag"
    Energy=100.00
    EnergyMax=100.00
}
