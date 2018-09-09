//-----------------------------------------------------------------------
// Class:    CNNDetonationTrigger
// Author:   CorpArmstrong
//-----------------------------------------------------------------------
class CNNDetonationTrigger extends CNNTrigger;

const OBJECTS_COUNT = 16;

struct ObervableObject
{
    var() name tag;
    var Actor actr;
	var bool bDestroyed;
};

var(ObjectsToDetonate) ObervableObject objects[16];

function DestroyObjects()
{
    local Actor actr;
    local int i;

    for (i = 0; i < ArrayCount(objects); i++)
    {
        if (objects[i].tag != '')
        {
            foreach AllActors(class'Actor', actr, objects[i].tag)
            {
                BroadcastMessage("Object: " $ actr.tag);
                objects[i].tag = '';
                actr.TakeDamage(300, none, vect(0, 0, 0), vect(0, 0, 0), 'Shot');
            }
        }
    }

    BroadcastMessage("All objects destroyed!");
    DeusExPlayer(GetPlayerPawn()).flagbase.SetBool('AllObjectsDestroyed', true);
}

function Trigger(Actor Other, Pawn Instigator)
{
    DestroyObjects();
    super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        DestroyObjects();
        super.Touch(Other);
    }
}
