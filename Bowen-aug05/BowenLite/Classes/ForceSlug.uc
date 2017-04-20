//=============================================================================
// ForceSlug. 	(c) 2003 JimBowen
//=============================================================================
class ForceSlug extends DeusExProjectile;

auto simulated state Flying
{
	simulated function ProcessTouch(Actor Other, vector HitLocation)
	{
		local actor a;
		local vector VelocityToSet, dir;
		local float dist;
		local rotator hitrot;
		
			foreach VisibleActors (class'Actor', a, BlastRadius)
			{
				if (a.IsA('DeusExPlayer') && TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
					if (DeusExPlayer(a).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team)
						return;

	/*			hitrot = rotator(HitLocation - Owner.Location);
				hitrot.pitch = 5461;
				dir = vector(hitrot);
				VelocityToSet = (-dir * Blastradius) * 1000;
				VelocityToSet.z += 10; */   //	BAH screw it!
				if (Other == Owner)
					return;
				VelocityToSet = VRand() * 800;
				if (VelocityToSet.z < 0)
					VelocityToSet.z = -velocity.z;
				VelocityToSet.z += 100;
				if (a != None)
				{
					if (a.IsA('PlayerPawn'))
					{
						a.setPhysics(PHYS_Falling);
						a.Velocity += VelocityToSet * 2;
					}
					else if (a.IsA('ScriptedPawn'))
					{
						a.SetPhysics(PHYS_Falling);
						ScriptedPawn(a).ImpartMomentum((VelocityToSet * 3000), Pawn(Owner));
						a.GoToState('FallingState');
					}
					else if (a.isA('DeusExDecoration'))
					{
						if (DeusExDecoration(a).bPushable)
						{
							a.SetPhysics(PHYS_Falling);
							a.Velocity += (VelocityToSet * 60)/a.Mass;
						}
					}
					else if (a.IsA('Carcass'))
					{	a.SetPhysics(PHYS_Falling);
						a.Velocity += (VelocityToSet * 60)/a.Mass;
					}
				}
			}
		Super.ProcessTouch(Other, HitLocation);
	}
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ShockRing ring;

	 ring = Spawn(class'ShockRing',,, HitLocation, rotator(HitNormal));
      if (ring != None)
      {
         ring.RemoteRole = ROLE_None;
         ring.size = blastRadius / 30.0;
      }
}

//---END-CLASS---

defaultproperties
{
     bExplodes=True
     blastRadius=50.000000
     ItemName="Force Rifle"
     speed=3000.000000
     MaxSpeed=20000.000000
     Damage=1.000000
     MomentumTransfer=100000
     ExplosionDecal=Class'DeusEx.BurnMark'
     Mesh=LodMesh'DeusExItems.GreaselSpit'
}
