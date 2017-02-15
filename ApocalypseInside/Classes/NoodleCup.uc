//=============================================================================
// NoodleCup.
//=============================================================================
class NoodleCup extends DeusExPickup;

#exec TEXTURE IMPORT NAME=NoodleCupTex0 FILE=Textures\NoodleCupTex0.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=BeltIconNoodleCup FILE=Textures\BeltIconNoodleCup.pcx GROUP=Icons FLAGS=2
#exec TEXTURE IMPORT NAME=LargeIconNoodleCup FILE=Textures\LargeIconNoodleCup.pcx GROUP=Icons FLAGS=2

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local DeusExPlayer player;

		Super.BeginState();

		player = DeusExPlayer(Owner);
		if (player != None)
			player.HealPlayer(15, False);

		//PlaySound(sound'MaleMunch');
		UseOnce();
	}
Begin:
}

defaultproperties
{
     maxCopies=10
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Noodle Cup"
     ItemArticle="a"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExDeco.Flowers'
     PickupViewMesh=LodMesh'DeusExDeco.Flowers'
     ThirdPersonMesh=LodMesh'DeusExDeco.Flowers'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'ApocalypseInside.Icons.BeltIconNoodleCup'
     largeIcon=Texture'ApocalypseInside.Icons.LargeIconNoodleCup'
     largeIconWidth=42
     largeIconHeight=46
     Description="A cup of noodles. The noodle is a type of staple food made from some type of unleavened dough which is rolled flat and cut into one of a variety of shapes, commonly to long thin strips."
     beltDescription="NOODLES"
     Mesh=LodMesh'DeusExDeco.Flowers'
     MultiSkins(0)=Texture'ApocalypseInside.Skins.NoodleCupTex0'
     CollisionRadius=11.880000
     CollisionHeight=9.630000
     Mass=20.000000
     Buoyancy=10.000000
}
