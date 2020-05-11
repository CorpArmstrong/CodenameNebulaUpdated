//-----------------------------------------------------------------------
// Class:    QuestSystem
// Author:   CorpArmstrong
//-----------------------------------------------------------------------
class QuestSystem extends Actor;

struct Quest
{
    var() Name flagName;
    var() bool flagValue;
};

struct QuestPath
{
    var() Quest questList[50];
    var() string endMapName;
    var() int questUsedCount;
};

const QuestCount = 50;
const CompletedGameFlagName = "IsGameCompleted";

var(QuestPaths) QuestPath questPathList[5];

var private DeusExPlayer player;

function ResetQuestSystem()
{
    GetPlayer().flagBase.SetBool(GetCompletedGameFlagName(), false);
}

function bool IsGameCompleted()
{
    return GetPlayer().flagBase.GetBool(GetCompletedGameFlagName());
}

function Update()
{
    local int i;
    local string endMapName;

    if (!IsGameCompleted())
    {
        for (i = 0; i < ArrayCount(questPathList); i++)
        {
            if (IsQuestPathCompleted(questPathList[i]))
            {
                endMapName = questPathList[i].endMapName;
                break;
            }
        }

        if (endMapName != "")
        {
            EndQuestPath(endMapName);
        }
    }
}

function bool IsQuestPathCompleted(QuestPath questPathToCheck)
{
    local Name flagName;
    local bool flagValue;
    local int i;

    if (questPathToCheck.questUsedCount >= 0 && questPathToCheck.questUsedCount <= QuestCount)
    {
        for (i = 0; i < questPathToCheck.questUsedCount; i++)
        {
            flagName = questPathToCheck.questList[i].flagName;
            flagValue = questPathToCheck.questList[i].flagValue;

            if (flagName == '')
            {
                GetPlayer().ClientMessage("Quest can't have empty name! Index = " $ i);
                return false;
            }

            if (!IsQuestCompleted(flagName, flagValue))
            {
                return false;
            }
        }

        return true;
    }
    else
    {
        GetPlayer().ClientMessage("Quest count must be in range of 0-" $ QuestCount $ " ! , actual count: " $ questPathToCheck.questUsedCount);
        return false;
    }
}

function bool IsQuestCompleted(Name flagName, bool flagValue)
{
    return GetPlayer().flagBase.GetBool(flagName) == flagValue;
}

function EndQuestPath(string endMapName)
{
    GetPlayer().flagBase.SetBool(GetCompletedGameFlagName(), true);
    Level.Game.SendPlayer(getPlayer(), endMapName);
}

function DeusExPlayer GetPlayer()
{
    if (player == none)
    {
        player = DeusExPlayer(GetPlayerPawn());
    }

    return player;
}

function Name GetCompletedGameFlagName()
{
    return DeusExRootWindow(GetPlayer().rootWindow).StringToName(CompletedGameFlagName);
}

defaultproperties
{
}
