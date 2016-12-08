//-----------------------------------------------------------
//
//-----------------------------------------------------------
class JJElecEmitter extends ElectricityEmitter;

var () float maxDistanse;
var () float changePosTime;
var () float accumTime;
var rotator rot;
//var rotator rot1;
//var rotator rot2;
//var vector vec1;
//var vector vec2;

function PostBeginPlay()
{
    super.PostBeginPlay();
    DrawScale = 2;
}

function CalcTrace(float deltaTime)
{
	local vector StartTrace, EndTrace, HitLocation, HitNormal, loc, jjV;
	local Rotator r;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	local ScriptedPawn sP;

	if (!bHiddenBeam)
	{
		// set up the random beam stuff

		if ( accumTime >= changePosTime )
		{
            accumTime -= accumTime;
            accumTime += 0.000001;
        ////////////////////
//        vec1 = vect(0,1,0);

//		r.Pitch = Int((0.5 - FRand()) * randomAngle);
//		r.Yaw = Int((0.5 - FRand()) * randomAngle);
//		r.Roll = Int((0.5 - FRand()) * randomAngle);
//		vec2 = vect(0,1,0) >> r;

		rot.Pitch = Int((0.5 - FRand()) * randomAngle);
		rot.Yaw = Int((0.5 - FRand()) * randomAngle);
		rot.Roll = Int((0.5 - FRand()) * randomAngle);

        ////////////////////
        }
        else
        {
            //rot = interpolateRotation( changePosTime / accumTime, rot(0,0,0), rot(0,0,0));

            //jjV = interpolateVector( changePosTime / accumTime, vec1, vec2 );
            //rot = rotator(jjV);

            accumTime += deltaTime;
        }



		StartTrace = Location;
		EndTrace = Location + maxDistanse * vector(Rotation + rot);
		HitActor = None;

		foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace, StartTrace)
		{
			if ((target.DrawType == DT_None) || target.bHidden)
			{
				// do nothing - keep on tracing
			}
			else if ((target == Level) || target.IsA('Mover'))
			{
				break;
			}
			else
			{
				HitActor = target;
				break;
			}
		}

		lastDamageTime += deltaTime;

		// shock whatever gets in the beam
		if ((HitActor != None) && (lastDamageTime >= damageTime))
		{
			sP = ScriptedPawn(HitActor);
			if ( sP != none )
			{
				if ( !sP.bInvincible )
				{
					sP.TakeDamage(damageAmount, Instigator, HitLocation, vect(0,0,0), 'Shocked');
					lastDamageTime = 0;
				}
			}
			else
			{
				HitActor.TakeDamage(damageAmount, Instigator, HitLocation, vect(0,0,0), 'Shocked');
				lastDamageTime = 0;
			}
		}
		//else
		//{
		//	HitLocation = Location + maxDistanse * vector(Rotation + rot);
		//}    // was commented for fix some bugs

		if (LaserIterator(RenderInterface) != None)
			LaserIterator(RenderInterface).AddBeam(0, Location, Rotation + rot, VSize(Location - HitLocation));
	}
}

defaultproperties
{
     maxDistanse=5000.0
     changePosTime=1.000000
     randomAngle=12000.000000
     DamageAmount=1
     damageTime=0.500000
     bFlicker=False
     flickerTime=0.800000
}
