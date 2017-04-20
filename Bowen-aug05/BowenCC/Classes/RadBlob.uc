//=============================================================================
// RadBlob. 	(c) 2003 JimBowen
//=============================================================================
class RadBlob expands DeusExprojectile;

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ExplosionLight light;
	local RadLight RadLight;
	local AnimatedSprite expeffect;
	local ShockRing ring;
	local int i;

		light = Spawn(class'ExplosionLight',,, HitLocation);
		if (light != None)
			light.RemoteRole = ROLE_None;

		RadLight = Spawn(class'RadLight',,, (HitLocation + (HitNormal*50)));
		if (RadLight != None)
			RadLight.RemoteRole = ROLE_None;

		expeffect = Spawn(class'RadExplosion',,, HitLocation);
		light.size = 4;

		for (i=0; i<6; i++)
			Spawn(class'RadComet', None,, HitLocation, Rotator(HitNormal));

		ring = Spawn(class'ShockRing',,, HitLocation, rotator(HitNormal));	
		if (ring != None)
		{
			ring.RemoteRole = ROLE_None;
			ring.size = blastRadius / 28.0;
			ring.skin = Texture;
			ring.bUnLit=True;
			ring.ScaleGlow=255;
		}
}

state Exploding
{
	ignores ProcessTouch, HitWall, Explode;

   function DamageRing()
   {
		local Pawn apawn;
		local float damageRadius;
		local Vector dist;

		if ( Level.NetMode != NM_Standalone )
		{
			damageRadius = (blastRadius / gradualHurtSteps) * gradualHurtCounter;

			for ( apawn = Level.PawnList; apawn != None; apawn = apawn.nextPawn )
			{
				if ( apawn.IsA('DeusExPlayer') )
				{
					dist = apawn.Location - Location;
					if ( VSize(dist) < damageRadius )
					{
						if ( gradualHurtCounter <= 2 )
						{
							if ( apawn.FastTrace( apawn.Location, Location ))
								DeusExPlayer(apawn).myProjKiller = Self;
						}
						else
							DeusExPlayer(apawn).myProjKiller = Self;
					}
				}
			}
		}
      //DEUS_EX AMSD Ignore Line of Sight on the lowest radius check, only in multiplayer
		HurtRadius
		(
			(2 * Damage) / gradualHurtSteps,
			(blastRadius / gradualHurtSteps) * gradualHurtCounter,
			damageType,
			MomentumTransfer / gradualHurtSteps,
			Location,
         ((gradualHurtCounter <= 2) && (Level.NetMode != NM_Standalone))
		);
		HurtRadius
		(
			(0.5*Damage) / gradualHurtSteps,
			(blastRadius / gradualHurtSteps) * gradualHurtCounter,
			'Exploded',
			MomentumTransfer / gradualHurtSteps,
			Location,
         ((gradualHurtCounter <= 2) && (Level.NetMode != NM_Standalone))
		);
   }
}

//---END-CLASS---

defaultproperties
{
     bExplodes=True
     blastRadius=150.000000
     DamageType=Radiation
     bIgnoresNanoDefense=True
     ItemName="Radiation cannon"
     ItemArticle="a"
     speed=3000.000000
     Damage=10.000000
     ExplosionDecal=Class'BowenCC.RadGoo'
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'BowenCust.Effects.RadSpark'
     DrawScale=0.300000
}
