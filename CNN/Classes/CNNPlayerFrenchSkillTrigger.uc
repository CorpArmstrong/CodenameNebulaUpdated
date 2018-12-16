//-----------------------------------------------------------------
//  Class:    CNNPlayerFrenchSkillTrigger
//  Author:   CorpArmstrong
//-----------------------------------------------------------------
class CNNPlayerFrenchSkillTrigger extends Trigger;

var() name FrenchSkillNameFlag;
var() int SkillValueToCheck;

function PostBeginPlay()
{
    local TantalusDenton player;
    local int skillValue;
    super.PostBeginPlay();

    player = TantalusDenton(GetPlayerPawn());

    if (player != none &&
        player.SkillSystem.GetSkillLevelValue(class'AiSkillFrench') == SkillValueToCheck)
    {
        player.flagBase.SetBool(FrenchSkillNameFlag, true);
    }
}

defaultproperties
{
    FrenchSkillNameFlag=French_Elementary
    SkillValueToCheck=2
}
