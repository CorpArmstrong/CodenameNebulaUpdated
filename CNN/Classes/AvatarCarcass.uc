//-----------------------------------------------------------
//  Burning corpse of an avatar
//-----------------------------------------------------------
class AvatarCarcass extends TestFMCarcass;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	self.TakeDamage(10, none, vect(0,0,0), vect(0,0,0), 'Burned');
}

DefaultProperties
{
	 Mesh=LodMesh'DeusExCharacters.GM_DressShirt_Carcass'
	 Fatness=102
	 MultiSkins(0)=Texture'DeusExDeco.Skins.BoneSkullTex1'
	 MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
	 MultiSkins(2)=Texture'DeusExItems.Skins.PinkMaskTex'
	 MultiSkins(3)=Texture'DeusExDeco.Skins.BobPageAugmentedTex4'
	 MultiSkins(4)=Texture'DeusExDeco.Skins.BobPageAugmentedTex4'
	 MultiSkins(5)=Texture'DeusExDeco.Skins.BobPageAugmentedTex4'
	 MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
	 MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
