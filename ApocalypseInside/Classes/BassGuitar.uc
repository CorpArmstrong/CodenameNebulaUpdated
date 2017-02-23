//=============================================================================
// BassGuitar.
//=============================================================================
class BassGuitar extends AIDeco;

var bool bUsing;

function Timer()
{
	bUsing = False;
}

function Frob(actor Frobber, Inventory frobWith)
{
	local float rnd;

	Super.Frob(Frobber, frobWith);

	if (bUsing)
		return;

	SetTimer(2.0, False);
	bUsing = True;

	rnd = FRand();
	/*
	if (rnd < 0.5)
		PlaySound(sound'x3sounds.music.x3_thereforyou', SLOT_Misc,,, 256);
	else
		PlaySound(sound'x3sounds.music.x3_thereforyou', SLOT_Misc,,, 256); */
}

defaultproperties
{
     FragType=Class'DeusEx.WoodFragment'
     bCanBeBase=True
     ItemName="Guitar"
     DrawScale=0.003500
     Mesh=LodMesh'ApocalypseInside.Bassein'
     CollisionRadius=25.639999
     CollisionHeight=25.639999
     Mass=750.000000
     Buoyancy=100.000000
     bHighlight=True
     bPushable=False
     Physics=PHYS_None
}
