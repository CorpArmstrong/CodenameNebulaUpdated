//-----------------------------------------------------------
// TestFMCarcass
// Test cop carcass to demonstate corpse burning effect
//-----------------------------------------------------------
class TestFMCarcass extends CopCarcass;

var() float Flammability;              // how long does the object burn?
var bool isBurning;
var() float MinScaleGlow;
var() float GlowFadeDownSpeed;

function Tick(float deltaSeconds)
{
    if (isBurning)
    {
        // Adjust scale glow
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
        StopFire();
    }
}

// Burns once, for Flammability seconds
function StartFire()
{
    isBurning = true;
    Inflammation();
    SetTimer(Flammability, false);
}

function StopFire()
{
    isBurning = false;
    ExtinguishFire();
}

function Inflammation()
{
    local int i;
    local vector loc;
    local Fire f;

    for (i = 0; i < 8; i++)
    {
        loc.X = 0.9 * CollisionRadius * (1.0 - 2.0 * FRand());
        loc.Y = 0.9 * CollisionRadius * (1.0 - 2.0 * FRand());
        loc.Z = 0.9 * CollisionHeight * (1.0 - 2.0 * FRand());
        loc += Location;

        f = Spawn(class'Fire', self, , loc);

        if (f != none)
        {
            f.DrawScale = FRand() + 1.0;
            f.LifeSpan = Flammability;

            // turn off the sound and lights for all but the first one
            if (i > 0)
            {
                f.AmbientSound = none;
                f.LightType = LT_None;
            }

            // turn on/off extra fire and smoke
            if (FRand() < 0.5)
            {
                f.smokeGen.Destroy();
            }
            if (FRand() < 0.5)
            {
                f.AddFire(1.5);
            }
        }
    }
}

function ExtinguishFire()
{
    local Fire f;

    foreach BasedActors(class'Fire', f)
    {
        f.Destroy();
    }
}

// Burn time is up
function Timer()
{
    StopFire();
}

defaultproperties
{
    MinScaleGlow=0.07
    GlowFadeDownSpeed=0.1
    Flammability=30.000000
    isBurning=false
}
