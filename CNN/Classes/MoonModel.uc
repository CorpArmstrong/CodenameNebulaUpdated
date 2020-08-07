class MoonModel extends Poolball;

function bool Facelift(bool bOn)
{
}

function BeginPlay()
{

	Super.BeginPlay();

}


defaultproperties
{
	ItemName="Moon Model"
	DrawScale=0.0500000
	Mesh=LodMesh'DeusExDeco.Moon'
	MultiSkins(0)=Texture'DeusExDeco.Skins.MoonTex1'
	bInvincible=False
}
