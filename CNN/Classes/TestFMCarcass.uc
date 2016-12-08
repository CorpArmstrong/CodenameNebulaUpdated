//-----------------------------------------------------------
//  Test cop carcass to demonstate corpse burning effect
//-----------------------------------------------------------
class TestFMCarcass extends CopCarcass;

var() float Flammability;			// how long does the object burn?
var FlagBase flags;
var DeusExPlayer player;
var bool isBurning;
var Fire f;
var int i;
var vector loc;
var() float MinScaleGlow;
var() float GlowFadeDownSpeed;

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
	if ((DamageType == 'Burned') || (DamageType == 'Flamed'))
    {
		if (!isBurning)
    	{
			StillBurn();
			isBurning = true;
    	    SetTimer(Flammability-5, false);
    	}
	}

	if (DamageType == 'HalonGas')
	{
		if (isBurning)
		{
			ExtinguishFire();
			isBurning = false;
		}
	}
}


function ExtinguishFire()
{
	local Fire f;

		foreach BasedActors(class'Fire', f)
			f.Destroy();
}



// continually burn
function Timer()
{
    player = DeusExPlayer(GetPlayerPawn());
    flags = player.FlagBase;

    if(!flags.GetBool('LaserSecurityWorks'))
    {
       isBurning = false;

    }
    else
    {
       if(isBurning==true)
       {
		   StillBurn();
	       SetTimer(Flammability-5, false);
	   }
    }
}

function StillBurn()
{
	for (i=0; i<8; i++)
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

DefaultProperties
{
     MinScaleGlow=0.07
	 GlowFadeDownSpeed=0.1
     Flammability=30.000000
     isBurning=false
}
