//================================================================================
// ForceSlug.
//================================================================================
class ForceSlug extends DeusExProjectile;

auto simulated state Flying extends Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local Actor A;
		local Vector VelocityToSet;
		local Vector Dir;
		local float dist;
		local Rotator hitrot;
	
	
}

simulated function DrawExplosionEffects (Vector HitLocation, Vector HitNormal)
{
	local ShockRing ring;

	ring=Spawn(Class'ShockRing',,,HitLocation,rotator(HitNormal));
	if ( ring != None )
	{
		ring.RemoteRole=0;
		ring.size=blastRadius / 30.00;
	}
}

defaultproperties
{
    bExplodes=True
    blastRadius=50.00
    ItemName="Force Rifle"
    speed=3000.00
    MaxSpeed=20000.00
    Damage=1.00
    MomentumTransfer=100000
    ExplosionDecal=Class'DeusEx.BurnMark'
    Mesh=LodMesh'DeusExItems.GreaselSpit'
}