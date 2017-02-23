//=============================================================================
// RamenNoodles.
//=============================================================================
class RamenNoodles extends SoyFood;

state Activated
{
	function Activate()
	{
		Super.Activate();
	}

	function BeginState()
	{
		local DeusExPlayer player;

		Super.BeginState();

		player = DeusExPlayer(Owner);
		if (player != None)
		{
	
			player.PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);

			player.Energy += 5;
			if (player.Energy > player.EnergyMax)
				player.Energy = player.EnergyMax;
		}

		UseOnce();
	}
Begin:
}

defaultproperties
{
	 rechargeAmount=5
     mpRechargeAmount=50
     msgRecharged="Recharged %d points"
     RechargesLabel="Recharges %d Energy Units"
     healthEffect=5
     maxCopies=10
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Ramen Noodles"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.SoyFood'
     PickupViewMesh=LodMesh'DeusExItems.SoyFood'
     ThirdPersonMesh=LodMesh'DeusExItems.SoyFood'
     Icon=Texture'DeusExUI.Icons.BeltIconSoyFood'
     largeIcon=Texture'DeusExUI.Icons.LargeIconSoyFood'
     largeIconWidth=42
     largeIconHeight=46
     Description="A pack of Chinese Ramen Noodles. Not necessary to cook, just eat it dry. A cheaper alternative to Soy Food packs, it still provides a few calories that can be used by advanced nano bioelectricity batteries inside Agent's augmentation system."
     beltDescription="RAMEN NOODLES"
     Mesh=LodMesh'DeusExItems.SoyFood'
     CollisionRadius=8.000000
     CollisionHeight=0.980000
     Mass=3.000000
     Buoyancy=4.000000
	 MultiSkins[0] = Texture'HK_Signs.HK_Sign_28'
}
