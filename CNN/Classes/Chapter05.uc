//=============================================================================
// Chapter05.
//=============================================================================
class Chapter05 expands CNNBaseIngameCutscene;

var(ChangeLevelOnDeath) string levelName;

var bool PlayerGotMuscleAug;
var bool HasMuscleAug;
var bool hasCombatAug;
var bool HasLethalAug;
var bool hasNonLethalAug;
var bool HasAquaAug;
var bool HasPowerAug;
var bool HasHeartAug;
var bool HasSpeedAug;
var bool HasStealthAug;
var bool HasCloakAug;
var bool HasRadarAug;
var bool HasRegenAug;
var bool HasEnergyAug;
var bool HasSpyAug;
var bool HasBallisticAug;
var bool HasDefenseAug;
var bool HasEMPAug;
var bool HasEnviroAug;
var bool HasTargetAug;
var bool HasVisionAug;

function DoLevelStuff()
{
    local UberAlles Uber;
    local Magdalene Magdalene;
    local Ship1 ship;

    GivePlayerHisAugs();

    if (player.IsInState('Dying'))
    {
        Level.Game.SendPlayer(player, levelName);
    }

    if (flags.GetBool('LeftMoon'))
    {
        foreach allactors(class'UberAlles', Uber, 'UberAllesInRoom')
        {
            Uber.EnterWorld();
        }
    }

    if (flags.GetBool('LeftMoon'))
    {
        foreach allactors(class'Magdalene', Magdalene, 'MagdaleneDenton')
        {
            Magdalene.LeaveWorld();
        }
    }

    if (flags.GetBool('SpacecraftLanded'))
    {
        foreach allactors(class'Ship1', ship, 'Spacecraft')
        {
            ship.EnterWorld();
        }
    }
}

function GivePlayerHisAugs()
{
    if (flags.GetBool('HasMuscleAug') && !flags.GetBool('PlayerGotMuscleAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugMuscle');
        flags.SetBool('PlayerGotMuscleAug', true, true, 0);
    }
    if (flags.GetBool('HasCombatAug') && !flags.GetBool('PlayerGotCombatAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugCombat');
        flags.SetBool('PlayerGotCombatAug', true, true, 0);
    }
    if (flags.GetBool('HasAquaAug') && !flags.GetBool('PlayerGotAquaAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugAqualung');
        flags.SetBool('PlayerGotAquaAug', true, true, 0);
    }
    if (flags.GetBool('HasPowerAug') && !flags.GetBool('PlayerGotPowerAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugPower');
        flags.SetBool('PlayerGotPowerAug', true, true, 0);
    }
    if (flags.GetBool('HasHeartAug') && !flags.GetBool('PlayerGotHeartAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugHeartLung');
        flags.SetBool('PlayerGotHeartAug', true, true, 0);
    }
    if (flags.GetBool('HasSpeedAug') && !flags.GetBool('PlayerGotSpeedAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugSpeed');
        flags.SetBool('PlayerGotSpeedAug', true, true, 0);
    }
    if (flags.GetBool('HasStealthAug') && !flags.GetBool('PlayerGotStealthAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugStealth');
        flags.SetBool('PlayerGotStealthAug', true, true, 0);
    }
    if (flags.GetBool('HasBallisticAug') && !flags.GetBool('PlayerGotBallisticAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugBallistic');
        flags.SetBool('PlayerGotBallisticAug', true, true, 0);
    }
    if (flags.GetBool('HasCloakAug') && !flags.GetBool('PlayerGotCloakAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugCloak');
        flags.SetBool('PlayerGotCloakAug', true, true, 0);
    }
    if (flags.GetBool('HasDefenseAug') && !flags.GetBool('PlayerGotDefenseAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugDefense');
        flags.SetBool('PlayerGotDefenseAug', true, true, 0);
    }
    if (flags.GetBool('HasEMPAug') && !flags.GetBool('PlayerGotEMPAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugEMP');
        flags.SetBool('PlayerGotEMPAug', true, true, 0);
    }
    if (flags.GetBool('HasEnergyAug') && !flags.GetBool('PlayerGotEnergyAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugShield');
        flags.SetBool('PlayerGotEnergyAug', true, true, 0);
    }
    if (flags.GetBool('HasEnviroAug') && !flags.GetBool('PlayerGotEnviroAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugEnviro');
        flags.SetBool('PlayerGotEnviroAug', true, true, 0);
    }
    if (flags.GetBool('HasHeartAug') && !flags.GetBool('PlayerGotHeartAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugHeartLung');
        flags.SetBool('PlayerGotHeartAug', true, true, 0);
    }
    if (flags.GetBool('HasRadarAug') && !flags.GetBool('PlayerGotRadarAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugRadarTrans');
        flags.SetBool('PlayerGotRadarAug', true, true, 0);
    }
    if (flags.GetBool('HasRegenAug') && !flags.GetBool('PlayerGotRegenAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugHealing');
        flags.SetBool('PlayerGotRegenAug', true, true, 0);
    }
    if (flags.GetBool('HasSpyAug') && !flags.GetBool('PlayerGotSpyAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugDrone');
        flags.SetBool('PlayerGotSpyAug', true, true, 0);
    }
    if (flags.GetBool('HasTargetAug') && !flags.GetBool('PlayerGotTargetAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugTarget');
        flags.SetBool('PlayerGotTargetAug', true, true, 0);
    }
    if (flags.GetBool('HasLethalAug') && !flags.GetBool('PlayerGotLethalAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugSkullGunLethal');
        flags.SetBool('PlayerGotLethalAug', true, true, 0);
    }
    if (flags.GetBool('HasNonLethalAug') && !flags.GetBool('PlayerGotNonLethalAug'))
    {
        Player.AugmentationSystem.GivePlayerAugmentation(Class'DeusEx.AugSkullGunNonLethal');
        flags.SetBool('PlayerGotNonLethalAug', true, true, 0);
    }
}

defaultproperties
{
    sendToLocation="05_MoonIntro#TwoWeeksLater"
    conversationName=InExile
    convNamePlayed=InExile_Played
    actorTag=MagdaleneDenton
    levelName="06_OpheliaL2#HumanServer"
}
