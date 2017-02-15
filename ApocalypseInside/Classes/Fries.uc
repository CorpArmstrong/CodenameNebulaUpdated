//=============================================================================
// Fries.
//=============================================================================
class Fries extends DeusExPickup;

#exec TEXTURE IMPORT NAME=BeltIconFries FILE=Textures\BeltIconFries.pcx GROUP=Icons FLAGS=2
#exec TEXTURE IMPORT NAME=LargeIconFries FILE=Textures\LargeIconFries.pcx GROUP=Icons FLAGS=2

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
			player.HealPlayer(8, False);

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
     ItemName="French Fries"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'ApocalypseInside.fries01'
     PickupViewMesh=LodMesh'ApocalypseInside.fries01'
     ThirdPersonMesh=LodMesh'ApocalypseInside.fries01'
     Icon=Texture'ApocalypseInside.Icons.BeltIconFries'
     largeIcon=Texture'ApocalypseInside.Icons.LargeIconFries'
     largeIconWidth=42
     largeIconHeight=46
     Description="French fries or chips (United Kingdom) are batons of deep-fried potato. They are an integral part of fast food menus and their popularity extends all over the world."
     beltDescription="FRIES"
     Mesh=LodMesh'ApocalypseInside.fries01'
     CollisionRadius=11.880000
     CollisionHeight=9.630000
     Mass=3.000000
     Buoyancy=4.000000
}
