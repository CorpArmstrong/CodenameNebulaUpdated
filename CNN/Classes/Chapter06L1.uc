//-----------------------------------------------------------
// Chapter06L1 - Ring 1
//-----------------------------------------------------------
class Chapter06L1 expands MissionScript;

var() string levelName;

function InitStateMachine()
{
    super.InitStateMachine();
    FirstFrame();
}

function FirstFrame()
{
	Super.FirstFrame();
	PrepareFirstFrame();
}

function PrepareFirstFrame()
{
	local int tantalusSkillLevel;
	
	tantalusSkillLevel = player.SkillSystem.GetSkillLevelValue(class'AiSkillFrench');

	if (tantalusSkillLevel == 2.00)
	{
		flags.SetBool('French_Elementary', true);
	}
}

function Timer()
{
	Super.Timer();
	
	if (player.IsInState('Dying'))
	{
		Level.Game.SendPlayer(player, levelName);
	}
}

defaultproperties
{
	levelName="06_OpheliaL2#HumanServer"
}