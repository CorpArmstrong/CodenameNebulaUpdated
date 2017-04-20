//================================================================================
// ListGenerator.
//================================================================================
class ListGenerator extends BowenBasicActor2;

function PostBeginPlay ()
{
	local Actor A;
	local string classes[1024];
	local Vector locs[1024];
	local Rotator rots[1024];
	local int i;

	Spawn(Class'ModController',,,Location);
	foreach AllActors(Class'Actor',A)
	{
		if ( A != None )
		{
			if ( A.IsA('DiscLauncher') || A.IsA('BowenWeapon') || A.IsA('BowenAmmo') || A.IsA('BowenPickup') || A.IsA('ShieldGenerator') )
			{
				if ( A.IsA('Inventory') )
				{
					if (  !A.IsInState('Pickup') || A.IsA('Inventory') && Inventory(A).bTossedOut )
					{
						continue;
						goto JL0191;
					}
					else
					{
						if ( A.IsA('BowenLAM') || A.IsA('BowenGasGrenade') || A.IsA('BowenEMPGrenade') )
						{
							continue;
						}
						else
						{
							classes[i]=string(A.Class);
							locs[i]=A.Location;
							rots[i]=A.Rotation;
							i++;
							continue;
						}
					}
				}
			}
		}
JL0191:
	}
	Log(" ");
	i=0;
JL019E:
	if ( i < 1024 )
	{
		if ( i < 85 )
		{
			if ( classes[i] != "" )
			{
				Log("names[" $ string(i) $ "]=" $ classes[i]);
			}
		}
		else
		{
			if ( i < 169 )
			{
				if ( classes[i] != "" )
				{
					Log("names2[" $ string(i - 85) $ "]=" $ classes[i]);
				}
			}
			else
			{
				if ( i < 253 )
				{
					if ( classes[i] != "" )
					{
						Log("names3[" $ string(i - 169) $ "]=" $ classes[i]);
					}
				}
				else
				{
					if ( i < 337 )
					{
						if ( classes[i] != "" )
						{
							Log("names4[" $ string(i - 253) $ "]=" $ classes[i]);
						}
					}
				}
			}
		}
		i++;
		goto JL019E;
	}
	Log(" ");
	i=0;
JL02EA:
	if ( i < 1024 )
	{
		if ( i < 85 )
		{
			if ( locs[i] != vect(0.00,0.00,0.00) )
			{
				Log("locs[" $ string(i) $ "]=(x=" $ string(locs[i].X) $ ",y=" $ string(locs[i].Y) $ ",z=" $ string(locs[i].Z) $ ")");
			}
		}
		else
		{
			if ( i < 169 )
			{
				if ( locs[i] != vect(0.00,0.00,0.00) )
				{
					Log("locs2[" $ string(i - 85) $ "]=(x=" $ string(locs[i].X) $ ",y=" $ string(locs[i].Y) $ ",z=" $ string(locs[i].Z) $ ")");
				}
			}
			else
			{
				if ( i < 253 )
				{
					if ( locs[i] != vect(0.00,0.00,0.00) )
					{
						Log("locs3[" $ string(i - 169) $ "]=(x=" $ string(locs[i].X) $ ",y=" $ string(locs[i].Y) $ ",z=" $ string(locs[i].Z) $ ")");
					}
				}
				else
				{
					if ( i < 337 )
					{
						if ( locs[i] != vect(0.00,0.00,0.00) )
						{
							Log("locs4[" $ string(i - 253) $ "]=(x=" $ string(locs[i].X) $ ",y=" $ string(locs[i].Y) $ ",z=" $ string(locs[i].Z) $ ")");
						}
					}
				}
			}
		}
		i++;
		goto JL02EA;
	}
	Log(" ");
	i=0;
JL0566:
	if ( i < 1024 )
	{
		if ( i < 85 )
		{
			if ( rots[i] != rot(0,0,0) )
			{
				Log("rots[" $ string(i) $ "]=(pitch=" $ string(rots[i].Pitch) $ ",yaw=" $ string(rots[i].Yaw) $ ",roll=" $ string(rots[i].Roll) $ ")");
			}
		}
		else
		{
			if ( i < 169 )
			{
				if ( rots[i] != rot(0,0,0) )
				{
					Log("rots2[" $ string(i - 85) $ "]=(pitch=" $ string(rots[i].Pitch) $ ",yaw=" $ string(rots[i].Yaw) $ ",roll=" $ string(rots[i].Roll) $ ")");
				}
			}
			else
			{
				if ( i < 253 )
				{
					if ( rots[i] != rot(0,0,0) )
					{
						Log("rots3[" $ string(i - 169) $ "]=(pitch=" $ string(rots[i].Pitch) $ ",yaw=" $ string(rots[i].Yaw) $ ",roll=" $ string(rots[i].Roll) $ ")");
					}
				}
				else
				{
					if ( i < 337 )
					{
						if ( rots[i] != rot(0,0,0) )
						{
							Log("rots4[" $ string(i - 253) $ "]=(pitch=" $ string(rots[i].Pitch) $ ",yaw=" $ string(rots[i].Yaw) $ ",roll=" $ string(rots[i].Roll) $ ")");
						}
					}
				}
			}
		}
		i++;
		goto JL0566;
	}
	Destroy();
}