//-----------------------------------------------------------
// That trigger needs when we must Call event at level start
//-----------------------------------------------------------
class PostBeginTrigger expands CNNSimpleTrigger;

var(Trigger) enum ECallAtEvent
{
	ECAE_PostPostBeginPlay,
	ECAE_PostBeginPlay,
}CallAtEvent;

function PostBeginPlay()
{
	if ( CallAtEvent == ECAE_PostBeginPlay )
	{
		if(!bEnabled)
			return;
		DebugInfo("PostBeginPlay()");
		ActivatedON();
	}
}

function PostPostBeginPlay()
{
	if ( CallAtEvent == ECAE_PostPostBeginPlay )
	{
		if(!bEnabled)
			return;
		DebugInfo("PostPostBeginPlay()");
		ActivatedON();
	}
}

//var (Event) name OnPostBeginPlay;
//var (Event) name OnPostPostBeginPlay;

DefaultProperties
{
	bOnlyOnce=true
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	bCollideActors=False
}
