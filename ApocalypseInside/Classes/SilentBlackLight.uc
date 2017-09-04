//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SilentBlackLight extends BlackLight;

function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	for (i = 0; i < ArrayCount(em); i++)
	{
		em[i].AmbientSound = None;
	}
}