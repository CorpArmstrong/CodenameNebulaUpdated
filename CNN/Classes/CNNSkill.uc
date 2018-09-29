class CNNSkill extends Skill;

var int mpCost1;
var int mpCost2;
var int mpCost3;

var float mpLevel0;
var float mpLevel1;
var float mpLevel2;
var float mpLevel3;

simulated function PreBeginPlay()
{
    super.PreBeginPlay();

    if (Level.NetMode != NM_Standalone)
    {
        cost[0] = mpCost1;
        cost[1] = mpCost2;
        cost[2] = mpCost3;

        LevelValues[0] = mpLevel0;
        LevelValues[1] = mpLevel1;
        LevelValues[2] = mpLevel2;
        LevelValues[3] = mpLevel3;
    }
}
