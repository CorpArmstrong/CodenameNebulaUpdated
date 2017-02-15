//=============================================================================
// Burger.
//=============================================================================
class Burger extends DeusExPickup;

#exec TEXTURE IMPORT NAME=BeltIconBurger FILE=Textures\BeltIconBurger.pcx GROUP=Icons FLAGS=2
#exec TEXTURE IMPORT NAME=LargeIconBurger FILE=Textures\LargeIconBurger.pcx GROUP=Icons FLAGS=2

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
			player.HealPlayer(10, False);

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
     ItemName="Hamburger"
     ItemArticle="a"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'ApocalypseInside.Burger01'
     PickupViewMesh=LodMesh'ApocalypseInside.Burger01'
     ThirdPersonMesh=LodMesh'ApocalypseInside.Burger01'
     Icon=Texture'ApocalypseInside.Icons.BeltIconBurger'
     largeIcon=Texture'ApocalypseInside.Icons.LargeIconBurger'
     largeIconWidth=42
     largeIconHeight=46
     Description="A hamburger (also called a burger) is a sandwich consisting of a cooked patty of ground meat usually placed inside a sliced bread roll."
     beltDescription="BURGER"
     Mesh=LodMesh'ApocalypseInside.Burger01'
     CollisionRadius=11.880000
     CollisionHeight=9.630000
     Mass=3.000000
     Buoyancy=4.000000
}
