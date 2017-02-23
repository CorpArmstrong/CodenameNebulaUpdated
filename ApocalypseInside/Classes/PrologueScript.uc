//=============================================
// PrologueScript. 
//=============================================
class PrologueScript expands MissionScript;

function InitStateMachine()
{


	    // Set the PlayerTraveling flag (always want it set for
		// the intro and endgames)
		flags.SetBool('PlayerTraveling', true, true, 0);
	
}

function FirstFrame()
{
	local JosephManderley Manderley;
	Super.FirstFrame();

	   	if (player != None)
		{
			DeusExRootWindow(Player.rootWindow).ResetFlags();

			foreach AllActors(class'JosephManderley', Manderley)
				break;

			if (Manderley != none) {
				player.StartConversationByName('IntroTalk', Manderley, false, true);
			}

		}
	
}
function Timer()
{
	Super.Timer();

	if (flags.GetBool('isProloguePlayed'))
	{
		if (DeusExRootWindow(Player.rootWindow) != None) {
			DeusExRootWindow(Player.rootWindow).ClearWindowStack();
		}

		Level.Game.SendPlayer(player, "A51_Clones");
	}
}