class Mars extends Poolball;

function bool Facelift(bool bOn)
{
}

function BeginPlay()
{

	Super.BeginPlay();

}


defaultproperties
{
	ItemName="Mars Model"
	DrawScale=0.0500000
	Mesh=LodMesh'DeusExDeco.Earth'
	MultiSkins(0)=Texture'X3tex.MarsEast'
	MultiSkins(1)=Texture'X3tex.MarsWest'
	bInvincible=False
}
