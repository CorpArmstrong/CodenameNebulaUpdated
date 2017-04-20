//================================================================================
// DisarmGrenade.
//================================================================================
class DisarmGrenade extends ThrownProjectile;

var float mpBlastRadius;
var float mpProxRadius;
var float mpDamage;
var float mpFuselength;
var float Force;
var float mpForce;

state Exploding extends Exploding
{
	function DamageRing ()
	{
		local Pawn P;
		local Inventory Inv;
		local Vector Dir;
		local Vector Loc;
	
		foreach VisibleActors(Class'Pawn',P,blastRadius)
		{
			if ( (P != None) && (P.ReducedDamageType != 'All') )
			{
				foreach AllActors(Class'Inventory',Inv)
				{
					if ( Inv != None )
					{
						if ( (Inv.Owner == P) && (Inv.PickupViewMesh != None) && (Inv.PickupViewMesh != LodMesh'TestBox') &&  !Inv.IsA('NanoKey') &&  !Inv.IsA('NanoKeyRing') &&  !Inv.IsA('WeaponNPCRanged') &&  !Inv.IsA('WeaponNPCMelee') )
						{
							if ( (VSize(Location - P.Location) < blastRadius / 3) || (VSize(Location - P.Location) < blastRadius / 2) && (FRand() < 0.15) || (FRand() < 0.05) )
							{
								Dir=VRand();
								if ( Dir.Z < 0 )
								{
									Dir.Z= -Dir.Z;
								}
								Loc=P.Location;
								Loc += Dir * P.CollisionHeight;
								Inv.DropFrom(Loc);
								Inv.Velocity=Dir * Force;
							}
						}
					}
					continue;
				}
			}
			continue;
		}
	}
	
}

simulated function DrawExplosionEffects (Vector HitLocation, Vector HitNormal)
{
	local SphereEffect Sph;

	Sph=Spawn(Class'SphereEffect',,,HitLocation);
	Sph.Skin=FireTexture'LaserBeam1';
	Sph.size=blastRadius / 20;
	Sph.LifeSpan=0.50;
}

simulated function PreBeginPlay ()
{
	Super.PreBeginPlay();
	if ( Level.NetMode != 0 )
	{
		blastRadius=mpBlastRadius;
		proxRadius=mpProxRadius;
		Damage=mpDamage;
		fuseLength=mpFuselength;
		bIgnoresNanoDefense=True;
		Force=mpForce;
	}
}

defaultproperties
{
    mpBlastRadius=512.00
    mpProxRadius=128.00
    mpFuselength=1.00
    Force=1024.00
    mpForce=512.00
    fuseLength=1.50
    proxRadius=128.00
    AISoundLevel=0.00
    bBlood=False
    bDebris=False
    blastRadius=768.00
    DamageType=None
    spawnWeaponClass=Class'DeusEx.WeaponGasGrenade'
    ItemName="Disarm Grenade"
    speed=1000.00
    MaxSpeed=1000.00
    MomentumTransfer=50000
    ImpactSound=Sound'DeusExSounds.Weapons.GasGrenadeExplode'
    LifeSpan=0.00
    Mesh=LodMesh'DeusExItems.GasGrenadePickup'
    CollisionRadius=4.30
    CollisionHeight=1.40
    Mass=5.00
    Buoyancy=2.00
}