//=============================================================================
// AmmoForceRifle. 	(c) 2003 JimBowen
//=============================================================================
class AmmoForceRifle extends BowenAmmo;


//
// SimUseAmmo - Spawns shell casings client side
//
simulated function bool SimUseAmmo()
{
	local vector offset, tempvec, X, Y, Z;
	local FShellCasing shell;
	local DeusExWeapon W;

	if ( AmmoAmount > 0 )
	{
		GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
		offset = Owner.CollisionRadius * X + 0.3 * Owner.CollisionRadius * Y;
		tempvec = 0.8 * Owner.CollisionHeight * Z;
		offset.Z += tempvec.Z;

		W = DeusExWeapon(Pawn(Owner).Weapon);

	        shell = spawn(class'FShellCasing',,, Owner.Location + offset);

		shell.RemoteRole = ROLE_None;

		if (shell != None)
		{
			shell.Velocity = (FRand()*20+90) * Y + (10-FRand()*20) * X;
			shell.Velocity.Z = 0;
		}
		return True;
	}
	return False;
}

function bool UseAmmo(int AmountNeeded)
{
	local vector offset, tempvec, X, Y, Z;
	local FShellCasing shell;
	local DeusExWeapon W;

	if (Super.UseAmmo(AmountNeeded))
	{
		GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
		offset = Owner.CollisionRadius * X + 0.3 * Owner.CollisionRadius * Y;
		tempvec = 0.8 * Owner.CollisionHeight * Z;
		offset.Z += tempvec.Z;

		// use silent shells if the weapon has been silenced
		W = DeusExWeapon(Pawn(Owner).Weapon);
      if ( DeusExMPGame(Level.Game) != None )
      {
			if ( Level.NetMode == NM_ListenServer )
			{
				shell = spawn(class'FShellCasing',,, Owner.Location + offset);
				shell.RemoteRole = ROLE_None;
			}
			else
	         shell = None;
      }
      else
         shell = spawn(class'FShellCasing',,, Owner.Location + offset);
   

		if (shell != None)
		{
			shell.Velocity = (FRand()*20+90) * Y + (10-FRand()*20) * X;
			shell.Velocity.Z = 0;
		}
		return True;
	}

	return False;
}

//---END-CLASS---

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
     CollisionRadius=6.000000
     CollisionHeight=0.750000
     bCollideActors=True
}
