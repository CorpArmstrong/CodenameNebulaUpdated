//=============================================================================
// DisarmGrenade.	(c) 2003 JimBowen
//=============================================================================
class DisarmGrenade expands ThrownProjectile;

var(Bowen) float	mpBlastRadius;
var(Bowen) float	mpProxRadius;
var(Bowen) float	mpDamage;
var(Bowen) float	mpFuselength;
var(Bowen) float	Force;
var(Bowen) float	mpForce;

state exploding
{
	function DamageRing()
	{
		local Pawn p;
		local Inventory Inv;
		local vector dir, loc;

			foreach VisibleActors(class'Pawn', p, BlastRadius)
			{
				if ((p != None) && p.ReducedDamageType != 'All' && !SameTeam(DeusExPlayer(P)))
				foreach AllActors(class'Inventory', Inv)
				{
					if (Inv != None)
						if (Inv.Owner == p && Inv.PickupViewMesh != None && Inv.PickupViewMesh != LodMesh'DeusExItems.TestBox' 
						&& !Inv.IsA('NanoKey') && !Inv.IsA('NanoKeyRing') && !Inv.IsA('WeaponNPCRanged') && !Inv.IsA('WeaponNPCMelee'))
							if ((VSize(Location - p.Location) < BlastRadius / 3 && p != Owner) 
							|| (VSize(Location - p.Location) < BlastRadius / 2 && FRand() < 0.15) || FRand() < 0.05)
							{
								/*if (P.IsA('DeusExPlayer'))
									if (DeusExWeapon(DeusexPlayer(P).InHand).bZoomed)
										DeusExPlayer(P).ToggleZoom();*/
								if (Inv.IsA('DeusExWeapon'))
								{
									DeusExWeapon(Inv).ScopeOff();
									DeusExWeapon(Inv).LaserOff();
								}	
								Dir = VRand();
								if(Dir.Z < 0)
									Dir.Z = -Dir.z;
								loc = p.Location;
									loc += Dir * p.CollisionHeight;
								/*if (P.IsA('DeusExPlayer'))
									DeusExPlayer(P).DropItem(Inv);
								else*/
									Inv.DropFrom(Loc);
								Inv.LifeSpan = 5;
								Inv.Velocity = Dir * Force;
							}
				}
			}
	}
}

function bool SameTeam(DeusExPlayer P)
{
	if (P == None)
		Return False;
	if (P == Owner)
		Return False;

	if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
		if (P.PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team)
			Return True;
	
	Return False;
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local SphereEffect Sph;
		
		Sph = Spawn(class'SphereEffect',,,HitLocation);
		Sph.Skin=Texture'Effects.Laser.LaserBeam1';
		Sph.Size = BlastRadius / 20;
		Sph.LifeSpan = 0.5;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
	{
		blastRadius=mpBlastRadius;
		proxRadius=mpProxRadius;
		Damage=mpDamage;
		fuseLength=mpFuseLength;
		bIgnoresNanoDefense=True;
		Force=mpForce;
	}
}

//---END-CLASS---

defaultproperties
{
     mpBlastRadius=768.000000
     mpProxRadius=128.000000
     mpFuselength=1.000000
     Force=1024.000000
     mpForce=512.000000
     fuseLength=1.500000
     proxRadius=128.000000
     AISoundLevel=0.000000
     bBlood=False
     bDebris=False
     blastRadius=1024.000000
     DamageType=None
     spawnWeaponClass=Class'WRG'
     ItemName="Disarm Grenade"
     speed=1000.000000
     MaxSpeed=1000.000000
     MomentumTransfer=50000
     ImpactSound=Sound'DeusExSounds.Weapons.GasGrenadeExplode'
     LifeSpan=0.000000
     Mesh=LodMesh'DeusExItems.GasGrenadePickup'
     CollisionRadius=4.300000
     CollisionHeight=1.400000
     Mass=5.000000
     Buoyancy=2.000000
}
