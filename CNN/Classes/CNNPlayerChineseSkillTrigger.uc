//-----------------------------------------------------------------
//  Class:    CNNPlayerChineseSkillTrigger
//  Author:   CorpArmstrong
//-----------------------------------------------------------------
class CNNPlayerChineseSkillTrigger extends Trigger;

//var() name ChineseSkillNameFlag;
//var() int SkillValueToCheck;

function PostBeginPlay()
{
    local TantalusDenton player;
    local int skillValue;
    super.PostBeginPlay();

    player = TantalusDenton(GetPlayerPawn());

    if (player != none &&
        player.SkillSystem.GetSkillLevelValue(class'AiSkillChinese') == 2)
    {
        player.flagBase.SetBool('Chinese_Elementary', true);
    }

    if (player != none &&
        player.SkillSystem.GetSkillLevelValue(class'AiSkillChinese') == 3)
    {
        player.flagBase.SetBool('Chinese_Elementary', true);
        player.flagBase.SetBool('Chinese_Intermediate', true);
    }

    if (player != none &&
        player.SkillSystem.GetSkillLevelValue(class'AiSkillChinese') == 4)
    {
        player.flagBase.SetBool('Chinese_Elementary', true);
        player.flagBase.SetBool('Chinese_Intermediate', true);
        player.flagBase.SetBool('Chinese_Advanced', true);
    }
}

defaultproperties
{
    //ChineseSkillNameFlag=Chinese_Elementary
    //SkillValueToCheck=2
}
