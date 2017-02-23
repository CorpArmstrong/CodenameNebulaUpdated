//================================================================================
// AiSkillBionics.
//================================================================================

class AiSkillBionics extends Skill;


defaultproperties
{
    mpCost1=1000

    mpCost2=1000

    mpCost3=1000

    mpLevel0=1.00

    mpLevel1=1.00

    mpLevel2=2.00

    mpLevel3=3.00

    SkillName="Bionics"

    Description="Practical knowledge of biohacking can be applied by an agent in the field allowing restoration of bioenergy and physical health through the use of medkits, bioelectric cells, energy drinks/bars and ambrosia vials.|n|nUNTRAINED: An agent can replenish health/bioenergy.|n|nTRAINED: An agent can restore slightly more health/bioenergy and reduce the period of toxic poisoning.|n|nADVANCED: An agent can restore moderately more health/bioenergy and further reduce the period of toxic poisoning.|n|nMASTER: An agent can perform a heart bypass with household materials."

    SkillIcon=Texture'DeusExUI.UserInterface.SkillIconMedicine'

    cost(0)=900

    cost(1)=1800

    cost(2)=3000

    LevelValues(0)=1.00

    LevelValues(1)=2.00

    LevelValues(2)=2.50

    LevelValues(3)=3.00

}