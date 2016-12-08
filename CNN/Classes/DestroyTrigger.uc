//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DestroyTrigger expands CNNTrigger;

var () name ScriptedPawnTag;
var () name AnyActorTag;
var () name DestroyByClassName;

function Trigger(Actor Other, Pawn Instigator)
{
    local DeusExPlayer player;
    local ScriptedPawn P;
    local Actor A;
    local DestroyTriggerExpectant Expectant;

// =================================
        player = DeusExPlayer(GetPlayerPawn());

	if (ScriptedPawnTag != '')
	{
        if ( player != none && player.IsInState('Conversation') )
        {
            Expectant = Spawn(class'DestroyTriggerExpectant', none);
            Expectant.ScriptedPawnTag = ScriptedPawnTag;
            Expectant.TurnOn();
        }
        else
			foreach AllActors( class 'ScriptedPawn', P, ScriptedPawnTag )
   	            P.Destroy();
	}

    if ( AnyActorTag != '' )
    {
		self.MsgBox("AnyActorTag != ''");

		foreach AllActors( class 'Actor', A, AnyActorTag )
		{
			self.MsgBox("one finded");
			A.Destroy();
		}

	}

    if ( DestroyByClassName != '' )
    {
		self.MsgBox("DestroyByClassName != ''");

		foreach AllActors( class 'Actor', A )
		{
			if (A.IsA(DestroyByClassName))
			{
				A.Destroy();
			}
		}
	}

// =================================
	Super.Trigger(Other, Instigator);
}

function Touch(Actor Other)
{
    local DeusExPlayer player;
    local ScriptedPawn A;
    local DestroyTriggerExpectant Expectant;

	if (IsRelevant(Other))
	{

        player = DeusExPlayer(GetPlayerPawn());

        if (player != none && player.IsInState('Conversation'))
        {
            Expectant = Spawn(class'DestroyTriggerExpectant', none);
            Expectant.ScriptedPawnTag = ScriptedPawnTag;
            Expectant.TurnOn();
        }
        else
            foreach AllActors( class 'ScriptedPawn', A, ScriptedPawnTag )
                A.Destroy();

		Super.Touch(Other);
	}
}

defaultproperties
{
}
