//=============================================================================
// ListGenerator. 	(c) 2003 JimBowen
//=============================================================================
class ListGenerator expands BowenBasicActor2;


function PostBeginPlay()
{
	local actor a;
	local string classes[1024];
	local vector locs[1024];
	local rotator rots[1024];
	local int i;
		
		spawn (class'ModController',,,Location); //Unauthorised users cannot have this
			
		foreach allactors (class'actor', a)
		{
			if (a != None)
				if (a.IsA ('DiscLauncher') || a.IsA ('BowenWeapon') || a.IsA ('BowenAmmo') 
				|| a.IsA ('BowenPickup') || a.IsA ('BowenChargedPickup') )
				{
					if (a.IsA('Inventory'))			
						if (!a.IsInState('Pickup') || (a.IsA('Inventory') && Inventory(a).bTossedOut))	// we dont want to detect picked up or tossed out weapons
							continue;
						else if (a.IsA('BowenLAM') || a.IsA('BowenGasGrenade') || a.IsA('BowenEMPGrenade'))
							continue;
							
					classes[i] = string(a.Class);
					locs[i] = a.Location;
					rots[i] = a.Rotation;
					i++;
				}
		}
		
		log(" ");
		for( i=0; i<1024; i++ )
		{
			if (i < 85)
			{
				if (classes[i] != "")
					log("names[" $i$ "]=" $ classes[i]);
			}
			else if (i < 169)
			{
				if (classes[i] != "")
					log("names2[" $(i - 85)$ "]=" $ classes[i]);
			}
			else if (i < 253)
			{
				if (classes[i] != "")
					log("names3[" $(i - 169)$ "]=" $ classes[i]);
			}
			else if (i < 337)
			{
				if (classes[i] != "")
					log("names4[" $(i - 253)$ "]=" $ classes[i]);
			}
		}
		
		log(" ");
		for( i=0; i<1024; i++ )
		{
			if (i < 85)
			{
				if (locs[i] != vect(0,0,0))
					log("locs[" $i$ "]=(x=" $ locs[i].x $ ",y=" $ locs[i].y $ ",z=" $ locs[i].z $ ")");
			}
			else if (i < 169)
			{
				if (locs[i] != vect(0,0,0))
					log("locs2[" $(i - 85)$ "]=(x=" $ locs[i].x $ ",y=" $ locs[i].y $ ",z=" $ locs[i].z $ ")");
			}
			else if (i < 253)
			{
				if (locs[i] != vect(0,0,0))
					log("locs3[" $(i - 169)$ "]=(x=" $ locs[i].x $ ",y=" $ locs[i].y $ ",z=" $ locs[i].z $ ")");
			}
			else if (i < 337)
			{
				if (locs[i] != vect(0,0,0))
					log("locs4[" $(i - 253)$ "]=(x=" $ locs[i].x $ ",y=" $ locs[i].y $ ",z=" $ locs[i].z $ ")");
			}
		}
		
		log(" ");
		for( i=0; i<1024; i++ )
		{
			if (i < 85)
			{
				if (rots[i] != rot(0,0,0))
					log("rots[" $i$ "]=(pitch=" $ rots[i].pitch $ ",yaw=" $ rots[i].yaw $ ",roll=" $ rots[i].roll $ ")");
			}
			else if (i < 169)
			{
				if (rots[i] != rot(0,0,0))
					log("rots2[" $(i - 85)$ "]=(pitch=" $ rots[i].pitch $ ",yaw=" $ rots[i].yaw $ ",roll=" $ rots[i].roll $ ")");
			}
			else if (i < 253)
			{
				if (rots[i] != rot(0,0,0))
					log("rots3[" $(i - 169)$ "]=(pitch=" $ rots[i].pitch $ ",yaw=" $ rots[i].yaw $ ",roll=" $ rots[i].roll $ ")");
			}
			else if (i < 337)
			{
				if (rots[i] != rot(0,0,0))
					log("rots4[" $(i - 253)$ "]=(pitch=" $ rots[i].pitch $ ",yaw=" $ rots[i].yaw $ ",roll=" $ rots[i].roll $ ")");
			}
		}
		
		destroy();
}

//---END-CLASS---

defaultproperties
{
}
