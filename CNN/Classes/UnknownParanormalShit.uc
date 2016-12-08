//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UnknownParanormalShit expands Doberman;

function PlayDogBark()
{
	if (FRand() < 0.5)
		PlaySound(sound'DogLargeBark2', SLOT_None);
	else
		PlaySound(sound'DogLargeBark3', SLOT_None);
}

defaultproperties
{
     Mesh=LodMesh'DeusExDeco.Barrel1'
}
