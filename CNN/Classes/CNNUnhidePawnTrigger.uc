//-----------------------------------------------------------
//  Class:    CNNUnhidePawnTrigger
//  Author:   CorpArmstrong
//-----------------------------------------------------------

class CNNUnhidePawnTrigger expands CNNTrigger;

var() name pawnTags[8];

function UnhidePawns()
{
    local int i;
	local ScriptedPawn sp;

	for (i = 0; i < ArrayCount(pawnTags); i++)
	{
		if (pawnTags[i] != '')
		{
			foreach AllActors(class 'ScriptedPawn', sp, pawnTags[i])
			{
				if (pawnTags[i] != 'TrapBot')
				{
					sp.bInvincible = false;
				}
				
				sp.bHighlight = true;
				
				sp.SetCollision(true, true, true);
				
				sp.bUnlit = true;
				sp.Style = STY_None;
				sp.ScaleGlow = 1;
			}
		}		
	}
}

function Trigger(Actor Other, Pawn Instigator)
{
    UnhidePawns();
    Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    if (IsRelevant(Other))
    {
        UnhidePawns();
        Super.Touch(Other);
    }
}

DefaultProperties
{
	pawnTags(0)=TrapSoldiers
	pawnTags(1)=TrapBot
}
