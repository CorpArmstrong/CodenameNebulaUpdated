//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SilentUPS expands CNNUPS;

function PostBeginPlay()
{
	local int i;
	local int a;

	super.PostBeginPlay();

	for (i = 0; i < 12+3; i ++)
		em[i].AmbientSound = None;

}

defaultproperties
{
}
