//-----------------------------------------------------------------------
// Class:    QuestSystem
// Author:   CorpArmstrong
//-----------------------------------------------------------------------
class QuestSystem extends Actor;

struct Quest
{
    var() name flagName;
    var() bool flagValue;
};

struct QuestPath
{
    var() Quest questList[50];
    var() string endMapName;
    var() int questUsedCount;
};

const QuestCount = 50;
var(QuestPaths) QuestPath questPathList[5];

var private DeusExPlayer player;
var private bool isQuestGameCompleted;

function ResetQuestSystem()
{
    isQuestGameCompleted = false;
}

// Called when player completes another goal
function OnQuestUpdated()
{
    local int i;
    local string endMapName;

    if (!isQuestGameCompleted)
    {
        for (i = 0; i < ArrayCount(questPathList); i++)
        {
            if (IsQuestPathCompleted(questPathList[i]))
            {
                isQuestGameCompleted = true;
                endMapName = questPathList[i].endMapName;
                break;
            }
        }

        if (isQuestGameCompleted)
        {
            EndQuestPath(endMapName);
        }
    }
}

function bool IsQuestPathCompleted(QuestPath questPathToCheck)
{
    local name flagName;
    local bool flagValue;
    local int i;

    if (questPathToCheck.questUsedCount >= 0 && questPathToCheck.questUsedCount <= QuestCount)
    {
        for (i = 0; i < questPathToCheck.questUsedCount; i++)
        {
            flagName = questPathToCheck.questList[i].flagName;
            flagValue = questPathToCheck.questList[i].flagValue;

            if (flagName == '' || !IsQuestCompleted(flagName, flagValue))
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

function bool IsQuestCompleted(name flagName, bool flagValue)
{
    return GetPlayer().flagBase.GetBool(flagName) == flagValue;
}

function EndQuestPath(string endMapName)
{
    Level.Game.SendPlayer(GetPlayer(), endMapName);
}

function DeusExPlayer GetPlayer()
{
    if (player == none)
    {
        player = DeusExPlayer(GetPlayerPawn());
    }

    return player;
}

defaultproperties
{
}