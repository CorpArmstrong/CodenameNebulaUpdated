//=============================================================================
// CoffeeMachine.
//=============================================================================
class CoffeeMachine extends ElectronicDevices;

#exec OBJ LOAD FILE=Ambient

var localized String msgDispensed;
var localized String msgNoCredits;
var int numUses;
var localized String msgEmpty;

function Frob(actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;
	local Vector loc;
	local Pickup product;

	Super.Frob(Frobber, frobWith);
	
	player = DeusExPlayer(Frobber);

	if (player != None)
	{
		if (numUses <= 0)
		{
			player.ClientMessage(msgEmpty);
			return;
		}

		if (player.Credits >= 2)
		{
			PlaySound(sound'VendingCoin', SLOT_None);
			loc = Vector(Rotation) * CollisionRadius * 0.6;
			loc.Z -= CollisionHeight * 0.3; 
			loc += Location;

			product = Spawn(class'CoffeeCup', None,, loc);

			if (product != None)
			{
				PlaySound(sound'VendingCan', SLOT_None);
				product.Velocity = Vector(Rotation);
			}

			player.Credits -= 2;
			player.ClientMessage(msgDispensed);
			numUses--;
		}
		else
			player.ClientMessage(msgNoCredits);
	}
}

defaultproperties
{
     msgDispensed="2 credits deducted from your account"
     msgNoCredits="Costs 2 credits..."
     numUses=20
     msgEmpty="It's empty"
     bCanBeBase=True
     ItemName="Coffee Machine"
     Mesh=LodMesh'ApocalypseInside.CoffeeMachine'
     SoundRadius=8
     SoundVolume=96
     AmbientSound=Sound'Ambient.Ambient.HumLow3'
     CollisionRadius=32.350000
     CollisionHeight=50.000000
     Mass=150.000000
     Buoyancy=100.000000
}