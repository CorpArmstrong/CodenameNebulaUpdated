//=============================================================================
// DamageLaserTrigger.
//=============================================================================
class DamageLaserTrigger extends CNNTrigger;

var CNNLaserEmitter emitter;
var() bool bIsOn;
var() bool bNoAlarm;			// if True, does NOT sound alarm

var() float decorationDamage;
var() float pawnDamage;
var() bool bConstantDamage;
var() float damageInterval;
var() name damageType;

var actor LastHitActor;
var bool bConfused;				// used when hit by EMP
var float confusionTimer;		// how long until trigger resumes normal operation
var float confusionDuration;	// how long does EMP hit last?
var int HitPoints;
var int minDamageThreshold;
var float lastAlarmTime;		// last time the alarm was sounded
var int alarmTimeout;			// how long before the alarm silences itself
var actor triggerActor;			// actor which last triggered the alarm
var vector actorLocation;		// last known location of actor that triggered alarm

singular function Touch(Actor Other)
{
	// does nothing when touched
}

function BeginAlarm()
{
	AmbientSound = Sound'Klaxon2';
	SoundVolume = 128;
	SoundRadius = 64;
	lastAlarmTime = Level.TimeSeconds;
	AIStartEvent('Alarm', EAITYPE_Audio, SoundVolume/255.0, 25*(SoundRadius+1));

	// make sure we can't go into stasis while we're alarming
	bStasis = False;
}

function EndAlarm()
{
	AmbientSound = None;
	lastAlarmTime = 0;
	AIEndEvent('Alarm', EAITYPE_Audio);

	// reset our stasis info
	bStasis = Default.bStasis;
}

function Tick(float deltaTime)
{
	local Actor A;
	local AdaptiveArmor armor;
	local bool bTrigger;

	if (emitter != None)
	{
		// shut off the alarm if the timeout has expired
		if (lastAlarmTime != 0)
		{
			if (Level.TimeSeconds - lastAlarmTime >= alarmTimeout)
				EndAlarm();
		}

		// if we've been EMP'ed, act confused
		if (bConfused && bIsOn)
		{
			confusionTimer += deltaTime;

			// randomly turn on/off the beam
			if (FRand() > 0.95)
				emitter.TurnOn();
			else
				emitter.TurnOff();

			if (confusionTimer > confusionDuration)
			{
				bConfused = False;
				confusionTimer = 0;
				emitter.TurnOn();
			}

			return;
		}

		emitter.SetLocation(Location);
		emitter.SetRotation(Rotation);

		if (!bNoAlarm)
		{
			if ((emitter.HitActor != None) && (LastHitActor != emitter.HitActor))
			{
				// TT_PlayerProximity actually works with decorations, too
				if (IsRelevant(emitter.HitActor) ||
					((TriggerType == TT_PlayerProximity) && emitter.HitActor.IsA('Decoration')))
				{
					bTrigger = True;

					if (emitter.HitActor.IsA('DeusExPlayer'))
					{
						// check for adaptive armor - makes the player invisible
						foreach AllActors(class'AdaptiveArmor', armor)
							if ((armor.Owner == emitter.HitActor) && armor.bActive)
							{
								bTrigger = False;
								break;
							}
					}

					if (bTrigger)
					{
						// now, the trigger sounds its own alarm
						if (AmbientSound == None)
						{
							triggerActor = emitter.HitActor;
							actorLocation = emitter.HitActor.Location - vect(0,0,1)*(emitter.HitActor.CollisionHeight-1);
							BeginAlarm();
						}

						// play "beam broken" sound
						PlaySound(sound'Beep2',,,, 1280, 3.0);
					}
				}
			}
		}


		//if ( emitter.HitActor != LastHitActor )
        //{
        //   if ( emitter.HitActor.IsA('Decoration') || emitter.HitActor.IsA('Pawn') != None )
        //      SetTimer(damageInterval, bConstantDamage);
        //   else
        //      SetTimer(0.1, false);
        //}



		LastHitActor = emitter.HitActor;
	}
}

function Timer()
{
local CNNUPS ups;
local DeusExMover DxMover;

	if (!bIsOn)
	{
		SetTimer(0.1, False);
		return;
	}

	if (emitter.HitActor != None)
	{
		if ( emitter.HitActor.IsA('DeusExMover') )
		{
			DxMover = DeusExMover(emitter.HitActor);
			if (DxMover.bBreakable)
				DxMover.BlowItUp(none);
		}

		if ( emitter.HitActor.IsA('Decoration') )
		{
           emitter.HitActor.TakeDamage(decorationDamage, None, emitter.HitActor.Location, vect(0,0,0), damageType );
        }

        if ( emitter.HitActor.IsA('Pawn') )
		{
			emitter.HitActor.TakeDamage(pawnDamage, None, emitter.HitActor.Location, vect(0,0,0), damageType );
        }

		if( emitter.HitActor.IsA('CNNUPS') )
		{
			ups = CNNUPS(emitter.HitActor);
			ups.SelfDestruction();
		}

   		//damagee.TakeDamage(damageAmount, None, Location, vect(0,0,0), damageType);
    }
}

// if we are triggered, turn us on
function Trigger(Actor Other, Pawn Instigator)
{


	if (bConfused)
		return;

	if (emitter != None)
	{
		if (!bIsOn)
		{
			emitter.TurnOn();
			bIsOn = True;
			SetTimer(damageInterval, bConstantDamage);
			LastHitActor = None;
			MultiSkins[1] = Texture'LaserSpot1';
		}
	}

	Super.Trigger(Other, Instigator);

}

// if we are untriggered, turn us off
function UnTrigger(Actor Other, Pawn Instigator)
{
	if (bConfused)
		return;

	if (emitter != None)
	{
		if (bIsOn)
		{
			emitter.TurnOff();
			bIsOn = False;
			SetTimer(0.1, false);
			LastHitActor = None;
			MultiSkins[1] = Texture'BlackMaskTex';
			EndAlarm();
		}
	}

	Super.UnTrigger(Other, Instigator);
}

function BeginPlay()
{
	Super.BeginPlay();

	LastHitActor = None;
	emitter = Spawn(class'CNNLaserEmitter');

	if (emitter != None)
	{
		emitter.TurnOn();
		bIsOn = True;

		// turn off the sound if we should
		if (SoundVolume == 0)
			emitter.AmbientSound = None;

		SetTimer(damageInterval, bConstantDamage);
	}
	else
		bIsOn = False;
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	local MetalFragment frag;

	if (DamageType == 'EMP')
	{
		confusionTimer = 0;
		if (!bConfused)
		{
			bConfused = True;
			PlaySound(sound'EMPZap', SLOT_None,,, 1280);
		}
	}
	else if ((DamageType == 'Exploded') || (DamageType == 'Shot'))
	{
		if (Damage >= minDamageThreshold)
			HitPoints -= Damage;

		if (HitPoints <= 0)
		{
			frag = Spawn(class'MetalFragment', Owner);
			if (frag != None)
			{
				frag.Instigator = EventInstigator;
				frag.CalcVelocity(Momentum,0);
				frag.DrawScale = 0.5*FRand();
				frag.Skin = GetMeshTexture();
			}

			Destroy();
		}
	}
}

function Destroyed()
{
	if (emitter != None)
	{
		emitter.Destroy();
		emitter = None;
	}

	Super.Destroyed();
}

defaultproperties
{
     bIsOn=True
     decorationDamage=1.000000
     pawnDamage=1024.000000
     bConstantDamage=True
     damageInterval=0.100000
     DamageType=Burned
     confusionDuration=10.000000
     HitPoints=50
     minDamageThreshold=50
     alarmTimeout=30
     TriggerType=TT_AnyProximity
     bHidden=False
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'DeusExDeco.LaserEmitter'
     CollisionRadius=2.500000
     CollisionHeight=2.500000
}
