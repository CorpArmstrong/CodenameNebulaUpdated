//-----------------------------------------------------------
//  Test cop carcass to demonstate corpse burning effect
//-----------------------------------------------------------
class MJ12TroopFMCarcass extends MJ12TroopCarcass;

var() float Flammability;			// How long does the object burn?
var FlagBase flags;
var DeusExPlayer player;
var bool isBurning;
var Fire f;
var int i;
var vector loc;
var() float MinScaleGlow;
var() float GlowFadeDownSpeed;

function PostBeginPlay()
{
    player = DeusExPlayer(GetPlayerPawn());
    flags = player.FlagBase;
}

function Tick(float deltaSeconds)
{
	if (isBurning)
	{
		if (ScaleGlow > MinScaleGlow)
		{
			ScaleGlow = ScaleGlow - GlowFadeDownSpeed*deltaSeconds;
		}
		else
		{
			ScaleGlow = MinScaleGlow;
		}
	}

	super.Tick(deltaSeconds);
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if (((DamageType == 'Burned') || (DamageType == 'Flamed')) && !isBurning)
    {
		StartFire();
	}

	if (DamageType == 'HalonGas' && isBurning)
	{
		StopFire(true);
	}
}

// Continually burn.
function Timer()
{
    if(!flags.GetBool('LaserSecurityWorks'))
    {
       StopFire(false);
    }
    else
    {
       if(isBurning)
       {
		   StartFire();
	   }
    }
}

function StartFire()
{
    isBurning = true;
    StillBurn();
    SetTimer(Flammability - 5, false);
}

function StopFire(bool bExtinguishFire)
{
    isBurning = false;

    if (bExtinguishFire)
    {
        ExtinguishFire();
    }
}

function StillBurn()
{
	for (i = 0; i < 8; i++)
	{
		loc.X = 0.9*CollisionRadius * (1.0-2.0*FRand());
		loc.Y = 0.9*CollisionRadius * (1.0-2.0*FRand());
		loc.Z = 0.9*CollisionHeight * (1.0-2.0*FRand());
		loc += Location;
		f = Spawn(class'Fire', Self,, loc);

        if (f != None)
		{
			f.DrawScale = FRand() + 1.0;
			f.LifeSpan = Flammability;

			// turn off the sound and lights for all but the first one
			if (i > 0)
			{
				f.AmbientSound = None;
				f.LightType = LT_None;
			}

			// turn on/off extra fire and smoke
			if (FRand() < 0.5)
				f.smokeGen.Destroy();
			if (FRand() < 0.5)
				f.AddFire(1.5);
		}
    }
}

function ExtinguishFire()
{
	local Fire f;

    foreach BasedActors(class'Fire', f)
        f.Destroy();
}

DefaultProperties
{
     MinScaleGlow=0.07
	 GlowFadeDownSpeed=0.1
     Flammability=30.000000
     isBurning=false
}

