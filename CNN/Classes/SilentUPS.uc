//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SilentUPS expands CNNUPS;

function PostBeginPlay()
{
	local int i;
	local int a;

	super.PostBeginPlay();

	for (i = 0; i < ArrayCount(em); i ++)
		em[i].AmbientSound = None;

}

defaultproperties
{
}
