//================================================================================
// AiSkillPiloting.
//================================================================================

class AiSkillPiloting extends Skill;

defaultproperties
{
    mpCost1=1000

    mpCost2=1000

    mpCost3=1000

    mpLevel0=1.00

    mpLevel1=1.00

    mpLevel2=2.00

    mpLevel3=3.00

    SkillName="Piloting"

    Description="Learn how to pilot an aircraft in order to be independent from pilots-for-hire.|n|nUNTRAINED: An agent cannot pilot aircrafts.|n|nTRAINED: An agent can remotely pilot a UAV (Unmanned Aerial Vehicle) and drones, but will likely crash anything else.|n|nADVANCED: An agent can pilot a helicopter.|n|nMASTER: An agent knows how to start a launch sequence of a space shuttle all by him/herself."

    SkillIcon=Texture'ApocalypseInside.SkillIcons.skilliconPiloting'

    cost(0)=900

    cost(1)=1800

    cost(2)=3000

    LevelValues(0)=1.00

    LevelValues(1)=2.00

    LevelValues(2)=2.50

    LevelValues(3)=3.00

}
