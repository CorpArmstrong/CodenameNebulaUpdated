//=============================================================================
// TantalusDenton.uc
//=============================================================================
class TantalusDenton extends JCDentonMale;

var travel ChineseSkillController chinese;
var private QuestSystem questSystem;
// CNNAgentRun's OPEN command re-fires several times on the destination map
// before settling (confirmed 2026-09-23, looped 6-7x both with and without
// the `travel` qualifier below) -- ConsoleCommand("open ...") apparently
// respawns TantalusDenton as a fresh instance rather than a seamless
// travel, so lastAgentSeq starts at 0 regardless and re-reads whatever
// seq is still sitting in CNNAgentCmd.txt as new. Harmless in practice:
// each re-fire just re-issues the same "open" while already loading, and
// it stops once the external writer's next command overtakes it in the
// file. Kept `travel` anyway since it costs nothing and does apply to
// real seamless travels (mission-to-mission, not this raw exec command).
var travel private int lastAgentSeq;

// Gates CNNAgentRun (see below), NOT the bridge's spawn -- a normal
// playthrough spawns CNNAgentBridge same as everyone (cheap: it just execs
// a possibly-empty file once a second) but every command is a no-op until
// this is True. Defaults off. Set it the same way bCheatsEnabled already
// gets set for dev testing -- a startup "-EXEC=<file>" containing:
//     set cnn.tantalusdenton bAgentAutoStart True
// (see tools/cnn_playtest_launch.ps1, which writes and passes that file).
// Not `var config`: this codebase has no existing config-var usage on this
// class to model against, while the `set`-via-exec-file mechanism is
// already proven working here (cheaton.txt/cheatoff.txt in System\).
var bool bAgentAutoStart;
var private CNNAgentBridge agentBridge;

// Diagnostic-only (2026-09-23): when True, CNNConverse() skips its own
// self-heal block (forced EndConversation()/InterruptConversation()/
// TerminateConversation() on a stale bark) entirely. Added to isolate
// whether that self-heal is what leaves the REAL conversation's
// conPlay.currentEvent looking empty afterward -- see CNNConverse's header
// comment and memory/project_agent_bridge.md. Set the same way
// bAgentAutoStart is, via console: `set cnn.tantalusdenton
// bAgentSkipSelfHeal True` (or the bridge's RAW passthrough). Defaults
// False so normal CNNConverse behavior is unchanged.
var bool bAgentSkipSelfHeal;

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

    // Always spawns CNNAgentBridge (cheap -- it just execs a possibly-empty
    // file once a second) instead of requiring `CNNAgentStart` typed at the
    // console. The actual on/off gate for a normal playthrough is
    // bAgentAutoStart, checked in CNNAgentRun, NOT here -- see the comment
    // there for why a PostBeginPlay-time check cannot work.
    CNNAgentStart();
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
// CNNProbe()
//
// Traces forward and reports what is actually there.
//
// Written after chasing L2's invisible wall through the .t3d export and
// getting it wrong: a bounding-box query named a rotated 2D-lofted pipe
// brush as the blocker, because the maths ignored brush rotation. Asking
// the engine at runtime removes the guesswork entirely.
//
// The distinction that matters: Trace() returns the LevelInfo when the ray
// hits world BSP, and the actual Actor otherwise. An Actor -- a mover, a
// decoration -- can be repositioned or have its collision cleared from
// script, so it is fixable on this branch. BSP cannot: that needs UnrealEd.
//
// Two traces are fired. A zero-extent ray finds the exact surface and its
// normal; an extent trace uses a box roughly the size of the player's
// collision cylinder, which is what actually decides whether the player can
// walk through. They can disagree -- a thin blocker or a gap narrower than
// the player will stop movement while a ray slips past.
// ----------------------------------------------------------------------

exec function CNNProbe()
{
    local vector start, dir, endPoint, hitLoc, hitNorm;
    local Actor rayHit, boxHit;

    start    = Location;
    dir      = vector(Rotation);
    endPoint = start + (dir * 500.0);

    // Zero-extent ray: exact surface and normal.
    rayHit = Trace(hitLoc, hitNorm, endPoint, start, true);
    ReportProbeHit("ray", rayHit, hitLoc, hitNorm, start);

    // Box trace approximating the player cylinder: what blocks movement.
    boxHit = Trace(hitLoc, hitNorm, endPoint, start, true, vect(20, 20, 40));
    ReportProbeHit("box", boxHit, hitLoc, hitNorm, start);
}

function ReportProbeHit(string label, Actor hit, vector hitLoc, vector hitNorm,
                        vector start)
{
    local string what;
    local int dist;

    if (hit == None)
    {
        ClientMessage("CNNProbe " $ label $ ": nothing within 500");
        Log("CNN L2 probe: " $ label $ " -> nothing within 500");
        return;
    }

    dist = int(VSize(hitLoc - start));

    if (hit == Level)
        what = "WORLD BSP (needs UnrealEd -- script cannot change it)";
    else
        what = "ACTOR " $ string(hit.Class.Name) $ " name=" $ string(hit.Name) $
               " tag=" $ string(hit.Tag) $ " (fixable from script)";

    ClientMessage("CNNProbe " $ label $ ": " $ what $ " at " $ dist);

    Log("CNN L2 probe: " $ label $ " -> " $ what $
        " dist=" $ dist $
        " hitLoc=(" $ int(hitLoc.X) $ ", " $ int(hitLoc.Y) $ ", " $ int(hitLoc.Z) $ ")" $
        " normal=(" $ hitNorm.X $ ", " $ hitNorm.Y $ ", " $ hitNorm.Z $ ")");
}

// ----------------------------------------------------------------------
// CNNFire()
//
// Triggers every actor carrying the given Tag, as a Dispatcher or trigger
// would.
//
// Needed because several L2 beats are fired by dispatchers, not by walking
// into something. MagdaleneInsideTube -- the conversation that sets
// FinalGoodbyePlayed, the gate every ending waits on -- is fired by
// MiniGameDispatcher, whose OutEvents are CNNMoverTube and
// ConversationTriggerTube. Teleporting onto that trigger does nothing and
// its coordinates are outside walkable space, so there was no way to reach
// the ending from the console at all.
//
// Useful tags on L2:
//   MiniGameDispatcher          fires the tube sequence -> FinalGoodbyePlayed
//   CommCenterDispatcher        doors + alliances + orders for the battle
//   OpenLabs                    lab clearance; also moves Magdalene up
//   LabEndingSuccessDispatcher  ShakeTriggerS + CNNMoverTube
// ----------------------------------------------------------------------

exec function CNNFire(name eventTag)
{
    local Actor a;
    local int count;

    if (eventTag == '')
    {
        ClientMessage("CNNFire <tag> -- e.g. MiniGameDispatcher, CommCenterDispatcher, OpenLabs");
        return;
    }

    foreach AllActors(class'Actor', a, eventTag)
    {
        a.Trigger(self, self);
        count++;
        Log("CNN L2 fire: triggered " $ string(a.Class.Name) $ " tag=" $ string(eventTag));
    }

    ClientMessage("CNNFire: " $ string(eventTag) $ " -> " $ count $ " actor(s)");
    Log("CNN L2 fire: " $ string(eventTag) $ " matched " $ count $ " actor(s)");
}

// ----------------------------------------------------------------------
// CNNFrob()
//
// Frobs the first actor with the given Tag, exactly as if the player had
// aimed at it and pressed the frob key -- same underlying call
// DeusExPlayer.DoFrob() makes (FrobTarget.Frob(Frobber, frobWith)), just
// without needing crosshair/line-of-sight. Added 2026-09-23 to expand
// player-action emulation beyond GOTO/FIRE/CONVERSE: terminals, switches,
// pickups, and other non-conversation interactables that CNNFire's
// Trigger() call doesn't reach (Trigger() is for dispatchers/triggers
// specifically; Frob() is the general "player interacted with this
// object" entry point most map objects actually implement).
//
// Known limitation, same class as CONVERSE's: frobbing something that
// opens its own UWindow-based screen (ComputerUIWindow, PersonaScreen,
// etc.) will likely get stuck the same way third-person conversations do
// -- see memory/project_agent_bridge.md. Simple binary-state objects
// (doors, switches, non-UI pickups) don't have that dependency and should
// work cleanly.
// ----------------------------------------------------------------------

exec function CNNFrob(name targetTag)
{
    local Actor a;
    local int count;

    if (targetTag == '')
    {
        ClientMessage("CNNFrob <tag> -- frobs the first actor with this Tag");
        return;
    }

    foreach AllActors(class'Actor', a, targetTag)
    {
        a.Frob(self, None);
        count++;
        Log("CNN L2 frob: frobbed " $ string(a.Class.Name) $ " tag=" $ string(targetTag) $
            " dist=" $ int(VSize(Location - a.Location)));
        break; // Frob() can destroy/move/reparent the actor -- unsafe to keep iterating the same foreach
    }

    ClientMessage("CNNFrob: " $ string(targetTag) $ " -> " $ count $ " actor(s)");
    Log("CNN L2 frob: " $ string(targetTag) $ " matched " $ count $ " actor(s)");
}

// ----------------------------------------------------------------------
// CNNDamage()
//
// Applies damage directly to the player via TakeDamage(), added
// 2026-09-23 to test player-death-gated flags/endings (PlayerDied,
// PlayerDiedOnL2, PlayerDiedDuringUpload -- see CNNFlags()) without
// needing a real combat encounter. Uses the same TakeDamage(amount, none,
// Location, vect(0,0,0), 'Shot') shape already used throughout this
// codebase (CNNDetonationTrigger, DamageLaserTrigger, etc.) for a generic,
// no-instigator hit.
// ----------------------------------------------------------------------

exec function CNNDamage(int amount)
{
    if (amount <= 0)
    {
        ClientMessage("CNNDamage <amount> -- e.g. CNNDamage 999 to test death-gated flags");
        return;
    }

    TakeDamage(amount, none, Location, vect(0, 0, 0), 'Shot');
    Log("CNN L2 damage: applied " $ amount $ " -- health now " $ Health);
    ClientMessage("CNNDamage: " $ amount $ " -> health=" $ Health);
}

// ----------------------------------------------------------------------
// CNNConverse()
//
// Starts a named conversation with Magdalene, exactly as if the player had
// frobbed her -- the only way to test an ending's ORGANIC route (real
// conversation content setting the flag) rather than CNNTestEnding's
// shortcut of setting the flag directly. Needed for Hijacking: the gate is
// CanArmMagdalene, set inside MagdaleneHijackTheStation, which is
// owner-bound to her (no map trigger reaches it -- see
// CNNDocs/L2_WalkthroughMap.md).
//
// Finds her the same way BringFollowers() below does: by class, not
// BindName/Tag, since L2 has exactly one Magdalene instance. StartConversat
// ionByName refuses outright past 800 units (see BringFollowers' comment),
// so GOTO magdalene first.
//
// Only Magdalene for now -- generalize to "find by BindName" if a future
// test needs a different NPC.
//
// ROOT-CAUSED (2026-09-23): the "UI setup skipped" theory below was wrong
// and is kept only as a note not to re-chase it. StartConversationByName
// DOES genuinely start the conversation the same way a real frob would --
// GotoState('Conversation'), conPlay spawned, conPlay.StartConversation()
// called, all confirmed live. The actual bug: ConPlay.StartConversation()
// does `currentEvent = con.eventList`, and Magdalene's live conListItems
// entry for MagdaleneHijackTheStation (the one Chapter06L2.DedupeOneActor
// keeps after dropping duplicates) has eventList == None -- a conversation
// with ZERO events. State PlayEvent's Begin: label sees currentEvent ==
// None and immediately TerminateConversation()s, before a single line
// plays, which is why conPlay goes back to None within one CNNAgentBridge
// poll and CNNAdvance() always finds "no active conPlay". The subtitle
// that appears to "freeze" is leftover HUD text from the auto-greeting
// bark this function force-terminates a few lines below, not this
// conversation's own output.
//
// This is NOT a StartConversationByName/UI bug. Chapter06L2.DedupeOneActor
// was rewritten (2026-09-23) to prefer whichever duplicate has a non-empty
// eventList over "last wins", which is strictly more correct and left
// every other deduped conversation unaffected (OpheliaHallway, SamGivesQuest,
// SocialBoss verified still correct) -- kept regardless of the paragraph
// below, since it degrades to identical "last wins" behavior whenever it
// can't tell copies apart, so it cannot have regressed anything.
//
// CORRECTION (2026-09-23, same day): the "ConEdit-level data problem, both
// copies genuinely empty" conclusion above was WRONG. The user directly
// confirmed hearing/seeing this exact conversation (MagdaleneHijackTheStation
// on L2) play correctly in normal gameplay -- so con.eventList is NOT
// actually empty in the real game data; `currentEvent is None` was an
// artifact of THIS testing path specifically. The two candidates, in order
// of suspicion: (1) the self-heal block a few lines below, which forcibly
// EndConversation()/InterruptConversation()/TerminateConversation()s a
// stale auto-greeting bark immediately before calling
// StartConversationByName -- TerminateConversation() calls
// `con.ClearBindEvents()` on the BARK's Conversation object, and if that
// native/ConSys call has any cross-conversation side effect this is the
// prime suspect; (2) GOTO-teleporting next to Magdalene rather than
// walking up naturally may leave her in a different precondition state
// than a real approach does (the bark firing at all is itself a symptom of
// the teleport). Not yet re-investigated -- next session should test
// WITHOUT the self-heal block (accepting that a stuck bark will make
// StartConversationByName legitimately refuse) to isolate which of the two
// it is, rather than trusting the "empty eventList" diagnosis further.
// ----------------------------------------------------------------------

exec function CNNConverse(name conName)
{
    local Magdalene mag;
    local bool bStarted;
    local ConListItem conListItem;
    local Conversation con;

    foreach AllActors(class'Magdalene', mag)
    {
        break;
    }

    if (mag == None)
    {
        ClientMessage("CNNConverse: no Magdalene on this map");
        Log("CNN L2 converse: " $ conName $ " -- no Magdalene found");
        return;
    }

    if (bAgentSkipSelfHeal)
    {
        Log("CNN L2 converse: bAgentSkipSelfHeal is True -- self-heal skipped, calling StartConversationByName as-is");
    }
    else
    {
    // Self-heal: confirmed live 2026-09-23 that walking up to Magdalene
    // auto-starts a short greeting bark that leaves her GetStateName()==
    // 'Conversation' indefinitely (nothing was ever there to close it --
    // CNNAdvance()/conPlay.PlayNextEvent() does NOT clear this; it's her
    // own AI state, not the player's conPlay), which then makes
    // StartConversationByName refuse silently. Force her out of it first.
    if (mag.GetStateName() == 'Conversation')
    {
        mag.EndConversation();
        Log("CNN L2 converse: Magdalene was stuck in 'Conversation' state -- called EndConversation() first");
    }

    // Clearing HER state wasn't enough -- StartConversation() (DeusExPlayer.uc)
    // separately refuses outright while the PLAYER's own conPlay still
    // references that same stale bark (conPlay.invokeActor == Magdalene,
    // first-person, player has a speaking part -- exact match for what an
    // unclosed greeting leaves behind). The engine self-cleans this same
    // way, but only *after* those earlier refusal checks -- do it
    // proactively first so we never hit them.
    if (conPlay != None)
    {
        conPlay.InterruptConversation();
        conPlay.TerminateConversation();
        // Confirmed live 2026-09-23: TerminateConversation() does NOT null
        // the reference out. CanStartConversation() refuses whenever
        // conPlay is non-None with con.bFirstPerson != True (true for the
        // stale bark, a third-person conversation) -- so the leftover
        // object alone keeps blocking every future attempt regardless of
        // its internal state. Null it explicitly.
        conPlay = None;
        Log("CNN L2 converse: player conPlay was stale -- interrupted+terminated+cleared");
    }

    // Confirms the explicit `conPlay = None` above actually worked --
    // CanStartConversation() (DeusExPlayer.uc) refuses whenever conPlay is
    // non-None with con.bFirstPerson != True, and TerminateConversation()
    // alone does NOT null the reference out, which is what made this take
    // three iterations to find. Left in as a cheap sanity check.
    if (conPlay == None)
    {
        Log("CNN L2 converse: conPlay is None after cleanup (good)");
    }
    else if (conPlay.con == None)
    {
        Log("CNN L2 converse: conPlay still non-None after cleanup -- CanInterrupt=" $
            conPlay.CanInterrupt() $ " conPlay.con is None");
    }
    else
    {
        Log("CNN L2 converse: conPlay still non-None after cleanup -- CanInterrupt=" $
            conPlay.CanInterrupt() $ " conFirstPerson=" $ conPlay.con.bFirstPerson);
    }
    } // !bAgentSkipSelfHeal

    // Diagnostic (2026-09-23): look up the target conversation's
    // bFirstPerson/interactive flags the same way the engine's own
    // StartConversationByName walks conListItems, so we know BEFORE the
    // call whether we should expect a first-person (GotoState stays put,
    // conPlay.StartConversation() called directly) or third-person
    // (GotoState('Conversation') on the player, conPlay.StartConversation()
    // deferred to that state's Begin: label) playback path.
    conListItem = ConListItem(mag.conListItems);
    while (conListItem != None)
    {
        if (conListItem.con.conName == conName)
        {
            con = conListItem.con;
            break;
        }
        conListItem = conListItem.next;
    }

    if (con == None)
    {
        Log("CNN L2 converse: " $ conName $ " not found in Magdalene's conListItems");
    }
    else
    {
        Log("CNN L2 converse: " $ conName $ " lookup -- bFirstPerson=" $ con.bFirstPerson $
            " bNonInteractive=" $ con.bNonInteractive $
            " bCannotBeInterrupted=" $ con.bCannotBeInterrupted $
            " radiusDistance=" $ con.radiusDistance);
    }

    bStarted = StartConversationByName(conName, mag, false, false);

    ClientMessage("CNNConverse: " $ conName $ " -> " $ bStarted);
    Log("CNN L2 converse: " $ conName $ " owner=Magdalene started=" $ bStarted $
        " magPhysics=" $ mag.Physics $ " magCanConverse=" $ mag.bCanConverse $
        " magInterruptState=" $ mag.bInterruptState $
        " magOrders=" $ mag.Orders $ " magState=" $ mag.GetStateName() $
        " dist=" $ int(VSize(Location - mag.Location)) $
        " playerCanStartConv=" $ CanStartConversation() $
        " playerState=" $ GetStateName() $
        " playerConPlayNone=" $ (conPlay == None));

    // Diagnostic (2026-09-23): the conversation terminates and returns
    // conPlay to None within a single CNNAgentBridge poll (~1s) even after
    // fixing DedupeConversations, well before CNNAdvance can ever act on
    // it. Log the first event queued up so we can tell whether it's really
    // one long ET_Speech (WaitForSpeech auto-advancing on missing/instant
    // audio) versus something branching straight to ET_End.
    if (conPlay != None)
    {
        if (conPlay.currentEvent != None)
        {
            Log("CNN L2 converse: currentEvent.EventType=" $ conPlay.currentEvent.EventType);
        }
        else
        {
            Log("CNN L2 converse: currentEvent is None");
        }
    }
}

// ----------------------------------------------------------------------
// CNNAdvance()
//
// Advances the current conversation exactly like a real player pressing
// Enter/Space or clicking -- see ConWindow.VirtualKeyPressed() /
// MouseButtonReleased() in the reference source, both of which just call
// conPlay.PlayNextEvent(). Needed because CONVERSE starts a conversation
// but nothing ever progresses it without this: confirmed live 2026-09-23
// that walking up to Magdalene alone auto-starts a greeting bark that
// left her GetStateName()=='Conversation' indefinitely (nothing was ever
// there to advance it), which then blocked a later CNNConverse attempt
// outright -- CanStartConversation() refuses while the player's own
// conPlay is already mid-conversation.
// ----------------------------------------------------------------------

exec function CNNAdvance()
{
    if (conPlay == None)
    {
        ClientMessage("CNNAdvance: no active conversation");
        Log("CNN L2 advance: no active conPlay");
        return;
    }

    conPlay.PlayNextEvent();
    ClientMessage("CNNAdvance: advanced");
    Log("CNN L2 advance: PlayNextEvent called");
}

// ----------------------------------------------------------------------
// CNNStatus()
//
// Diagnostic-only (2026-09-23): cheap one-line snapshot of conversation
// state, meant to be polled repeatedly (once per CNNAgentBridge Timer
// tick, ~1s apart) right after CNNConverse to catch the exact tick
// conPlay flips back to None -- CNNConverse's own log confirms conPlay is
// NOT None immediately after StartConversationByName returns, but by the
// time the first CNNAdvance lands (one bridge poll later) it already is.
// Does not touch state, safe to call at any time.
// ----------------------------------------------------------------------

exec function CNNStatus()
{
    local bool bConPlayHasCon;

    if (conPlay != None)
    {
        bConPlayHasCon = (conPlay.con != None);
    }

    Log("CNN L2 status: playerState=" $ GetStateName() $
        " conPlayNone=" $ (conPlay == None) $
        " conPlayHasCon=" $ bConPlayHasCon $
        " nextState=" $ NextState $
        " physics=" $ Physics);
}

// ----------------------------------------------------------------------
// CNNConDump()
//
// Diagnostic-only (2026-09-23): dumps every conversation bound to a named
// actor (found by BindName) with its bFirstPerson/bNonInteractive/
// radiusDistance, the same fields CNNConverse's own pre-call lookup logs
// for Magdalene, generalized to any actor. Built to find a bFirstPerson=
// True candidate elsewhere on L2 -- CNNConverse's target,
// MagdaleneHijackTheStation, is bFirstPerson=False (third-person,
// ConWindowActive), and that window never completed correctly through the
// headless agent bridge (see memory/project_agent_bridge.md). CNNFrob
// proved simple ComputerUIWindow-style UI DOES render fine through the
// bridge, so the open question is whether a first-person conversation
// (no ConWindowActive, subtitle-only) fares better than third-person did.
// ----------------------------------------------------------------------

exec function CNNConDump(string targetTag)
{
    local Actor a;
    local ConListItem item;

    foreach AllActors(class'Actor', a)
    {
        if (a.BindName == targetTag)
        {
            break;
        }
    }

    if (a == None)
    {
        Log("CNN L2 condump: no actor with BindName " $ targetTag);
        return;
    }

    item = ConListItem(a.conListItems);
    while (item != None)
    {
        if (item.con != None)
        {
            Log("CNN L2 condump: " $ targetTag $ " con=" $ item.con.conName $
                " bFirstPerson=" $ item.con.bFirstPerson $
                " bNonInteractive=" $ item.con.bNonInteractive $
                " radiusDistance=" $ item.con.radiusDistance);
        }
        item = item.next;
    }
}

// ----------------------------------------------------------------------
// CNNMagState()
//
// Diagnostic-only (2026-09-23): polls Magdalene's GetStateName() without
// touching anything, meant to be called repeatedly after GOTO magdalene to
// characterize whether the auto-greeting bark clears on its own over real
// time (and how long that takes) versus staying stuck in 'Conversation'
// indefinitely without CNNConverse's self-heal forcing it closed. Needed
// to isolate whether that self-heal (vs. the GOTO teleport itself) is what
// leaves the real conversation looking empty afterward -- see
// CNNConverse's header comment.
// ----------------------------------------------------------------------

exec function CNNMagState()
{
    local Magdalene mag;

    foreach AllActors(class'Magdalene', mag)
    {
        break;
    }

    if (mag == None)
    {
        Log("CNN L2 magstate: no Magdalene found");
        return;
    }

    Log("CNN L2 magstate: magState=" $ mag.GetStateName() $
        " magOrders=" $ mag.Orders $
        " magInterruptState=" $ mag.bInterruptState $
        " dist=" $ int(VSize(Location - mag.Location)));
}

// ----------------------------------------------------------------------
// BringFollowers()
//
// Moves Magdalene to the player after a teleport, when she is following.
//
// vanilla StartConversationByName refuses outright when the player is more
// than 800 units from the conversation's owner:
//
//     dist = VSize(Location - conOwner.Location);
//     if ((dist <= 800) || (bForcePlay))
//
// CNNGoto moves only the player, so after a jump she is left behind and
// every conversation owned by her silently fails. Measured case: player at
// the tube, Magdalene still in the lower labs, 4550 units apart --
// MagdaleneInsideTube fired and was refused, so FinalGoodbyePlayed never
// set and no ending triggered.
//
// Walking there normally is unaffected; she follows on her own. This only
// keeps the teleport shortcut faithful to that.
// ----------------------------------------------------------------------

function BringFollowers(vector playerLoc)
{
    local Magdalene mag;
    local vector dest;

    foreach AllActors(class'Magdalene', mag)
    {
        if (mag.Orders != 'Following')
            continue;

        dest = playerLoc;
        dest.X += 90;

        if (mag.SetLocation(dest))
            Log("CNN L2 goto: brought Magdalene to " $ dest);
        else
            Log("CNN L2 goto: could not place Magdalene near " $ dest);

        break;
    }
}

// ----------------------------------------------------------------------
// CNNFlags()
//
// Dumps the same L2 ending-relevant flags Chapter06L2.LogChangedFlags()
// already tracks (see its trackedFlag[] array), on demand instead of only
// on change. Needed to tell an ORGANIC playthrough (walking the real
// route, talking to NPCs) apart from CNNTestEnding's shortcut -- both end
// up on the same ending map, but only this shows whether the flag that
// actually gates it (e.g. CanArmMagdalene for Hijacking) was set by real
// conversation/trigger content along the way, not by the test harness.
// ----------------------------------------------------------------------

exec function CNNFlags()
{
    Log("CNN L2 flags: MikeWongExposed=" $ FlagBase.GetBool('MikeWongExposed') $
        " MetReedAndWong=" $ FlagBase.GetBool('MetReedAndWong') $
        " IsArrivalPlayed=" $ FlagBase.GetBool('IsArrivalPlayed') $
        " OnLevel2=" $ FlagBase.GetBool('OnLevel2') $
        " CanArmMagdalene=" $ FlagBase.GetBool('CanArmMagdalene') $
        " ReadyForBossFight=" $ FlagBase.GetBool('ReadyForBossFight') $
        " ReadyForSocialBoss=" $ FlagBase.GetBool('ReadyForSocialBoss') $
        " FinalGoodbyePlayed=" $ FlagBase.GetBool('FinalGoodbyePlayed'));
    Log("CNN L2 flags: AllObjectsDestroyed=" $ FlagBase.GetBool('AllObjectsDestroyed') $
        " SeedsOfDoubtPlanted=" $ FlagBase.GetBool('SeedsOfDoubtPlanted') $
        " WongParanoid=" $ FlagBase.GetBool('WongParanoid') $
        " SamUnfriendly=" $ FlagBase.GetBool('SamUnfriendly') $
        " PlayerDied=" $ FlagBase.GetBool('PlayerDied') $
        " PlayerDiedOnL2=" $ FlagBase.GetBool('PlayerDiedOnL2') $
        " PlayerDiedDuringUpload=" $ FlagBase.GetBool('PlayerDiedDuringUpload'));
    Log("CNN L2 flags: TantalusUploadStarted=" $ FlagBase.GetBool('TantalusUploadStarted') $
        " TantalusUploaded=" $ FlagBase.GetBool('TantalusUploaded') $
        " UndockedL2=" $ FlagBase.GetBool('UndockedL2') $
        " StartedBlueFusion=" $ FlagBase.GetBool('StartedBlueFusion') $
        " TookSteeringWheel=" $ FlagBase.GetBool('TookSteeringWheel') $
        " TimerExpired=" $ FlagBase.GetBool('TimerExpired') $
        " IsGameCompleted=" $ FlagBase.GetBool('IsGameCompleted'));

    ClientMessage("CNNFlags: dumped to log");
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
    local vector dest;
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
    else if (where == "WALL")      dest = vect(  918, -5686,    15);  // reported invisible wall / render artifact spot
    else if (where == "TUBE")      dest = vect(  843, -6084,     8);  // LoadingInTube trigger
    else if (where == "FINAL")     dest = vect( 1487, -6294,     4);  // tube area (medbot) -- the trigger itself is outside walkable space; use CNNFire MiniGameDispatcher
    else bKnown = false;

    if (!bKnown)
    {
        ClientMessage("CNNGoto: start sam samantha magdalene maglab soldiers battle iot wong meph jc tube final wall");
        return;
    }

    if (TryLandNear(dest, where))
        return;

    // Every offset refused. Being on the wrong map is one cause -- these are
    // L2 coordinates and land in solid geometry anywhere else -- but only say
    // so when the map name actually disagrees.
    //
    // L2's DeusExLevelInfo has NO mapName property set, so it reads back
    // empty. The first version of this check compared that empty string
    // against "06_OPHELIAL2", decided every failure was a wrong-map error,
    // and refused CNNGoto final on the correct level. Treat an empty name as
    // "unknown, carry on" rather than as a mismatch.
    info = GetLevelInfo();
    if ((info != None) && (info.mapName != "") &&
        (Caps(info.mapName) != "06_OPHELIAL2"))
    {
        ClientMessage("CNNGoto: these are 06_OpheliaL2 landmarks -- you are on " $ info.mapName);
        Log("CNN L2 goto: " $ where $ " refused, wrong map (" $ info.mapName $ ")");
        return;
    }

    ClientMessage("CNNGoto: " $ where $ " is blocked -- type ghost first, then retry");
    Log("CNN L2 goto: " $ where $ " BLOCKED at " $ dest);
}

// ----------------------------------------------------------------------
// TryLandNear()
//
// Shared landing-spot search extracted from CNNGoto (2026-09-23) so
// CNNGotoVec can reuse it for arbitrary coordinates, not just the named
// landmark table. See CNNGoto's own comment for why the search exists at
// all: landmarks are actor ORIGINS at floor level, so teleporting the
// player's centre there buries their collision cylinder and SetLocation
// refuses outright. Lifts clear of the floor and fans out on a ring at
// each height if the first try is still occupied.
// ----------------------------------------------------------------------

function bool TryLandNear(vector dest, string label)
{
    local vector tryLoc;
    local int attempt, ring;

    Velocity = vect(0, 0, 0);
    Acceleration = vect(0, 0, 0);

    for (attempt = 0; attempt < 20; attempt++)
    {
        tryLoc = dest;
        tryLoc.Z += 50 + ((attempt / 5) * 60);

        // attempt%5 == 0 is the exact spot; 1-4 fan out N/E/S/W by 80 units.
        ring = attempt % 5;
        if (ring == 1)      tryLoc.X += 80;
        else if (ring == 2) tryLoc.X -= 80;
        else if (ring == 3) tryLoc.Y += 80;
        else if (ring == 4) tryLoc.Y -= 80;

        if (SetLocation(tryLoc))
        {
            // Logged as well as shown on the HUD: ClientMessage never reaches
            // the log, so a run driven from the console leaves no trace of
            // where the player went. "cnn log CNN L2" then reads back as a
            // session transcript -- teleports interleaved with the flag
            // changes they caused.
            ClientMessage("CNNGoto: " $ label $ " " $ tryLoc);
            Log("CNN L2 goto: " $ label $ " -> " $ tryLoc);
            BringFollowers(tryLoc);
            return true;
        }
    }

    return false;
}

// ----------------------------------------------------------------------
// CNNGotoVec()
//
// Raw-coordinate teleport, added 2026-09-23 to test approaching Magdalene
// in stages (several waypoints with real waits between, driven externally
// by the agent bridge) instead of one instant point-blank CNNGoto jump --
// see CNNConverse's header comment and memory/project_agent_bridge.md.
// Live testing found her auto-greeting bark never resolves on its own
// after an instant teleport to dist=4; this exists to test whether a
// gradual approach avoids triggering that stuck state in the first place.
// No map/landmark validation beyond TryLandNear's own search -- caller is
// responsible for sane coordinates.
// ----------------------------------------------------------------------

exec function CNNGotoVec(float x, float y, float z)
{
    local vector dest;

    dest.X = x;
    dest.Y = y;
    dest.Z = z;

    if (!TryLandNear(dest, "vec"))
    {
        ClientMessage("CNNGotoVec: blocked at " $ dest);
        Log("CNN L2 goto: vec " $ dest $ " BLOCKED");
    }
}

// ----------------------------------------------------------------------
// CNNAgentStart() / CNNAgentRun()
//
// Lets an external process drive this pawn's own exec functions through
// CNNAgentBridge, which polls CNN\System\CNNAgentCmd.txt once a second via
// "exec" (see CNNAgentBridge.uc for why that poll lives on its own Actor
// instead of here).
//
// CNNAgentRun is the ONLY line that file should ever contain, and it is
// sequence-gated:
//
//     CNNAgentRun <seq> <cmd> <arg>
//
// UnrealScript has no confirmed API in this codebase for a script to
// truncate or delete a file (grepped both this tree and the DeusExPlus
// reference source for FileLog/OpenLog and found nothing), so the file
// cannot be cleared after each read. Without gating, the same line would
// re-fire on every poll until the external side overwrites it -- harmless
// for CNNGoto/CNNWhere/CNNProbe, but CNNFire re-triggers dispatchers and
// CNNTestEnding rewrites ending flags, so a stale re-read must be a no-op.
// The external writer increments seq for every new command and never has
// to touch the file except to write the next one.
//
// <cmd> and <arg> are ONE trailing string parameter (rest), split by hand
// with InStr/Left/Right -- confirmed in-game 2026-09-23 that the console's
// exec-file parser does NOT tokenize two consecutive trailing string
// params on a multi-arg exec function; both received the identical
// leftover text ("GOTO TUBE" landed in both cmd AND arg). A single
// trailing string is the same idiom CNNGoto(string where) already relies
// on and is known good.
//
// From the console, once started:
//     CNNAgentStart
//     CNNAgentRun 1 GOTO TUBE
//     CNNAgentRun 2 FIRE MiniGameDispatcher
//     CNNAgentRun 3 WHERE
//     CNNAgentRun 4 PROBE
//     CNNAgentRun 5 TESTENDING hijack
//     CNNAgentRun 6 SHOT
//     CNNAgentRun 7 OPEN 06_OpheliaL2
//
// GOTO/FIRE/WHERE/PROBE/TESTENDING just call the existing exec functions
// above, so their behaviour (including everything logged) is identical
// whether triggered by hand or by the agent. SHOT calls the engine's own
// screenshot console command -- confirmed working in-game 2026-09-23,
// writes ShotNNNN.bmp into System\. OPEN travels to another map by name
// (ConsoleCommand("open <map>")) -- e.g. to leave the CNNentry/menu level
// (mapName "DXOnly", confirmed 2026-09-23 that CNN boots there even with
// LocalMap=/Map= overridden in a launch INI) and reach 06_OpheliaL2. A
// fresh TantalusDenton spawns on the new map and re-runs CNNAgentStart
// from PostBeginPlay, so the bridge survives the travel.
// ----------------------------------------------------------------------

exec function CNNAgentStart()
{
    if (agentBridge != None)
        return; // already running -- PostBeginPlay always calls this now

    agentBridge = Spawn(class'CNNAgentBridge');
    agentBridge.SetTarget(self);
    ClientMessage("CNNAgentStart: polling CNNAgentCmd.txt every " $
        agentBridge.pollInterval $ "s");
    Log("CNN agent: bridge started");
}

exec function CNNAgentRun(int seq, string rest)
{
    local string cmd, arg;
    local int spacePos;

    // The real gate, not PostBeginPlay: confirmed 2026-09-23 that the
    // engine processes a startup -EXEC file's `set bAgentAutoStart True`
    // AFTER the first level's actors have already spawned and PostBeginPlay
    // has already run (a diagnostic Log() there printed False every time,
    // with the file's own "Execing ..." line appearing later in the same
    // log). CNNAgentBridge is spawned unconditionally now; this check is
    // what actually keeps a normal playthrough inert -- by the time any
    // command reaches here (the bridge's first poll is ~1s after spawn),
    // the -EXEC file has long since run.
    if (!bAgentAutoStart)
        return;

    if (seq <= lastAgentSeq)
        return;

    lastAgentSeq = seq;

    spacePos = InStr(rest, " ");
    if (spacePos == -1)
    {
        cmd = Caps(rest);
        arg = "";
    }
    else
    {
        cmd = Caps(Left(rest, spacePos));
        arg = Right(rest, Len(rest) - spacePos - 1);
    }

    Log("CNN agent: seq=" $ seq $ " cmd=" $ cmd $ " arg=" $ arg);

    if (cmd == "GOTO")
        CNNGoto(arg);
    else if (cmd == "GOTOVEC")
        CNNAgentGotoVec(arg);
    else if (cmd == "FIRE")
        ConsoleCommand("CNNFire " $ arg); // string->name needs the console's own parser; no script-side cast exists
    else if (cmd == "FROB")
        ConsoleCommand("CNNFrob " $ arg); // same string->name reason as FIRE
    else if (cmd == "DAMAGE")
        CNNDamage(int(arg));
    else if (cmd == "OPEN")
        CNNAgentOpen(arg);
    else if (cmd == "CONVERSE")
        ConsoleCommand("CNNConverse " $ arg); // string->name needs the console's own parser, same reason as FIRE
    else if (cmd == "ADVANCE")
        CNNAdvance();
    else if (cmd == "STATUS")
        CNNStatus();
    else if (cmd == "MAGSTATE")
        CNNMagState();
    else if (cmd == "CONDUMP")
        CNNConDump(arg);
    else if (cmd == "NEWGAME")
    {
        // Same call ApocalypseInsideMenuStartNewGame.ApocalypseInsideGo()
        // makes when a real player clicks Begin -- ShowIntro(True) runs
        // the real StartNewGame(strStartMap) path (ResetPlayer,
        // DeleteSaveGameFiles, fresh AugmentationSystem/SkillSystem/
        // inventory), not a raw `open` travel that skips all of that.
        // Added 2026-09-23 for a real New-Game-to-ending playthrough test
        // -- see memory/project_agent_bridge.md.
        Log("CNN L2 newgame: calling ShowIntro(True) -- strStartMap=" $ strStartMap);
        ShowIntro(True);
    }
    else if (cmd == "RAW")
        ConsoleCommand(arg); // generic passthrough for ad hoc `set`/console commands during diagnostics, same trust level as FIRE/OPEN/CONVERSE which already reach ConsoleCommand
    else if (cmd == "WHERE")
        CNNWhere();
    else if (cmd == "FLAGS")
        CNNFlags();
    else if (cmd == "PROBE")
        CNNProbe();
    else if (cmd == "TESTENDING")
        CNNTestEnding(arg);
    else if (cmd == "SHOT")
        ConsoleCommand("shot");
    else if (cmd == "QUIT")
        ConsoleCommand("exit"); // graceful shutdown -- a killed process trips the engine's dirty-shutdown Recovery Mode dialog on next launch, which needs a human click to clear
    else
        ClientMessage("CNNAgentRun: unknown cmd " $ cmd $
            " -- use GOTO/GOTOVEC/FIRE/FROB/DAMAGE/OPEN/CONVERSE/ADVANCE/STATUS/MAGSTATE/CONDUMP/NEWGAME/RAW/WHERE/FLAGS/PROBE/TESTENDING/SHOT/QUIT");
}

// ----------------------------------------------------------------------
// CNNAgentOpen()
//
// Guards CNNAgentRun's OPEN command against the reload storm confirmed
// live 2026-09-23: `open <map>` is NOT a seamless travel here -- it
// respawns TantalusDenton as a completely fresh instance (defaultproperties,
// lastAgentSeq back to 0 despite the `travel` qualifier, which only
// applies to actual seamless travels). CNNAgentCmd.txt still holds the
// same OPEN line until the external writer sends a new command, so every
// single CNNAgentBridge poll after each respawn sees seq > lastAgentSeq(0)
// again and reissues `open`, which respawns again, forever -- observed
// live as 40+ consecutive "Browse: 06_OpheliaL2..." reloads in one run
// (visible to a human watching as the level repeatedly restarting), far
// beyond the "6-7 times, harmless" this was previously measured at.
//
// First fix attempt used DeusExLevelInfo.mapName (the same field CNNGoto's
// wrong-map check trusts) and did NOT work: confirmed live it stayed at
// 15 reloads, unchanged, because L2's DeusExLevelInfo has no mapName
// property authored at all -- it reads back empty, always (documented
// separately in CNNDocs/L2_WalkthroughMap.md, and the exact reason
// CNNMissionEndgame.Timer() already had to use GetURLMap() instead of
// dxInfo.mapName for the M5 fix -- see its own comment). Switched to
// `Level.Game.GetURLMap()`, the same proven-reliable source, which
// returns the actual loaded map filename (e.g. "06_OpheliaL2") regardless
// of whether the per-map DeusExLevelInfo property was ever authored.
// ----------------------------------------------------------------------

function CNNAgentOpen(string targetMap)
{
    local string currentMap;

    currentMap = Caps(Level.Game.GetURLMap());

    if ((currentMap != "") && (currentMap == Caps(targetMap)))
    {
        Log("CNN L2 open: already on " $ targetMap $ " -- skipping redundant open");
        return;
    }

    ConsoleCommand("open " $ targetMap);
}

// ----------------------------------------------------------------------
// CNNAgentGotoVec()
//
// Splits a "<x> <y> <z>" arg string (space-separated, whole numbers or
// decimals) and calls CNNGotoVec. Kept separate from CNNAgentRun's own
// single first-space split (cmd/rest) since this needs two more splits for
// three tokens.
// ----------------------------------------------------------------------

function CNNAgentGotoVec(string arg)
{
    local string xStr, yStr, zStr, rest;
    local int p1, p2;

    p1 = InStr(arg, " ");
    if (p1 == -1)
    {
        Log("CNN L2 goto: GOTOVEC malformed arg (expected \"x y z\"): " $ arg);
        return;
    }
    xStr = Left(arg, p1);
    rest = Right(arg, Len(arg) - p1 - 1);

    p2 = InStr(rest, " ");
    if (p2 == -1)
    {
        Log("CNN L2 goto: GOTOVEC malformed arg (expected \"x y z\"): " $ arg);
        return;
    }
    yStr = Left(rest, p2);
    zStr = Right(rest, Len(rest) - p2 - 1);

    CNNGotoVec(float(xStr), float(yStr), float(zStr));
}

defaultproperties
{
    bAgentAutoStart=False
    bAgentSkipSelfHeal=False
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
