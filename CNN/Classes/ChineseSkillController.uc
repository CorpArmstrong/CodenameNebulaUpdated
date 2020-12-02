//-----------------------------------------------------------
// ChineseSkillController.uc
//-----------------------------------------------------------
class ChineseSkillController expands Actor;

var DeusExPlayer _player;

function Tick(float deltaTime)
{
    // First time, assign player.
    if (_player == none)
    {
        _player = DeusExPlayer(GetPlayerPawn());
        self.AttachTag = _player.Tag;
    }

    // Check if player isn't dead
    if (_player != none)
    {
        if (_player.SkillSystem.GetSkillLevelValue(class'AiSkillChinese') == 2)
        {
            _player.flagBase.SetBool('Chinese_Elementary', true);
        }
        else
        if (_player.SkillSystem.GetSkillLevelValue(class'AiSkillChinese') > 2 && _player.SkillSystem.GetSkillLevelValue(class'AiSkillChinese') < 3)
        {
            _player.flagBase.SetBool('Chinese_Elementary', true);
            _player.flagBase.SetBool('Chinese_Intermediate', true);
        }
        else
        if (_player.SkillSystem.GetSkillLevelValue(class'AiSkillChinese') == 3)
        {
            _player.flagBase.SetBool('Chinese_Elementary', true);
            _player.flagBase.SetBool('Chinese_Intermediate', true);
            _player.flagBase.SetBool('Chinese_Advanced', true);
        }
        else
    }

    super.Tick(deltaTime);
}

defaultproperties
{
}
