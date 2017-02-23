//================================================================================
// AiSkillComputer.
//================================================================================

class AiSkillComputer extends SkillComputer;

defaultproperties
{
    mpCost1=1000

    mpCost2=1000

    mpCost3=1000

    mpLevel0=0.40

    mpLevel1=0.40

    mpLevel2=1.00

    mpLevel3=5.00

    SkillName="Hacking"

    Description="The covert manipulation of computers and security consoles.|n|nUNTRAINED: An agent can use terminals to read bulletins and news.|n|nTRAINED: An agent can hack ATMs, computers, and security consoles.|n|nADVANCED: An agent achieves a moderate increase in detection countdowns and a moderate decrease in lockout times, as well as gaining the ability to control automated gun turrets.|n|nMASTER: An agent is an elite hacker that few systems can withstand."

    SkillIcon=Texture'DeusExUI.UserInterface.SkillIconComputer'

    cost(0)=1125

    cost(1)=2250

    cost(2)=3750

    LevelValues(0)=1.00

    LevelValues(1)=1.00

    LevelValues(2)=2.00

    LevelValues(3)=4.00

}