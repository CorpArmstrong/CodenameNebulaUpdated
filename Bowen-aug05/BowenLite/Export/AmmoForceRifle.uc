//================================================================================
// AmmoForceRifle.
//================================================================================
class AmmoForceRifle extends BowenAmmo;

simulated function bool SimUseAmmo ()
{
	local Vector Offset;
	local Vector tempvec;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local FShellCasing shell;
	local DeusExWeapon W;

	if ( AmmoAmount > 0 )
	{
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		Offset=Owner.CollisionRadius * X + 0.30 * Owner.CollisionRadius * Y;
		tempvec=0.80 * Owner.CollisionHeight * Z;
		Offset.Z += tempvec.Z;
		W=DeusExWeapon(Pawn(Owner).Weapon);
		shell=Spawn(Class'FShellCasing',,,Owner.Location + Offset);
		shell.RemoteRole=0;
		if ( shell != None )
		{
			shell.Velocity=(FRand() * 20 + 90) * Y + (10 - FRand() * 20) * X;
			shell.Velocity.Z=0.00;
		}
		return True;
	}
	return False;
}

function bool UseAmmo (int AmountNeeded)
{
	local Vector Offset;
	local Vector tempvec;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local FShellCasing shell;
	local DeusExWeapon W;

	if ( Super.UseAmmo(AmountNeeded) )
	{
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		Offset=Owner.CollisionRadius * X + 0.30 * Owner.CollisionRadius * Y;
		tempvec=0.80 * Owner.CollisionHeight * Z;
		Offset.Z += tempvec.Z;
		W=DeusExWeapon(Pawn(Owner).Weapon);
		if ( DeusExMPGame(Level.Game) != None )
		{
			if ( Level.NetMode == 2 )
			{
				shell=Spawn(Class'FShellCasing',,,Owner.Location + Offset);
				shell.RemoteRole=0;
			}
			else
			{
				shell=None;
			}
		}
		else
		{
			shell=Spawn(Class'FShellCasing',,,Owner.Location + Offset);
		}
		if ( shell != None )
		{
			shell.Velocity=(FRand() * 20 + 90) * Y + (10 - FRand() * 20) * X;
			shell.Velocity.Z=0.00;
		}
		return True;
	}
	return False;
}

defaultproperties
{
    AmmoAmount=60
    MaxAmmo=600
    ItemName="force rounds"
    ItemArticle="some"
    PickupViewMesh=LodMesh'DeusExItems.Ammo762mm'
    LandSound=Sound'DeusExSounds.Generic.MetalHit1'
    Icon=Texture'DeusExUI.Icons.BeltIconAmmo762'
    largeIconWidth=46
    largeIconHeight=34
    Description="BowenCo Force rounds are designed to push enemies from the tops of buildings etc."
    beltDescription="F-ROUNDS"
    Mesh=LodMesh'DeusExItems.Ammo762mm'
    CollisionRadius=6.00
    CollisionHeight=0.75
    bCollideActors=True
}