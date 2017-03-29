//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AMutator expands Mutator;

var bool bHUDMutator;
var AMutator NextMessageMutator;
var Mutator NextHUDMutator;

function bool MutatorTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
	if ( NextMessageMutator != None )
		return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
	else
		return true;
}

// Registers the current mutator on the client to receive PostRender calls.
simulated function RegisterHUDMutator()
{
	local Pawn P;

	ForEach AllActors(class'Pawn', P)
		if ( P.IsA('PlayerPawn') && (PlayerPawn(P).myHUD != None) )
		{
			NextHUDMutator = PlayerPawn(P).myHUD.HUDMutator;
			PlayerPawn(P).myHUD.HUDMutator = Self;
			bHUDMutator = True;
		}
}

DefaultProperties
{

}
