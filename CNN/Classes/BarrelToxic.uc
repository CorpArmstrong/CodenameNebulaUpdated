//=============================================================================
// BarrelToxic.
//=============================================================================
class BarrelToxic extends Containers;

var ParticleGenerator ToxicDrip;

#exec OBJ LOAD FILE=Effects

function Destroyed()
{
    if (ToxicDrip != none)
    {
        ToxicDrip.DelayedDestroy();
    }

    Super.Destroyed();
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetBase(Owner);

    ToxicDrip = Spawn(class'ParticleGenerator', Self,, Location + vect(0, 0, 1) * CollisionHeight * 0.6, rot(16384, 0, 0));

    if (ToxicDrip != none)
    {
        ToxicDrip.bParticlesUnlit = true;
        ToxicDrip.bTranslucent = true;
        ToxicDrip.particleDrawScale = 0.05;
        ToxicDrip.checkTime = 0.25;
        ToxicDrip.frequency = 0.8;
        ToxicDrip.riseRate = 5.0;
        ToxicDrip.ejectSpeed = 10.0;
        ToxicDrip.particleLifeSpan = 2.0;
        ToxicDrip.bRandomEject = True;
        ToxicDrip.numPerSpawn = 2;
        ToxicDrip.particleTexture = Texture'CNN.Effects.Gen_Green';
        ToxicDrip.SetBase(Self);
    }
}

defaultproperties
{
    HitPoints=30
    bInvincible=true
    bFlammable=false
    bUnlit=true
    ItemName="Helium-3 Barrel"
    bBlockSight=true
    Mesh=LodMesh'CNN.BarrelToxic'
    CollisionRadius=19.000000
    CollisionHeight=28.500000
    LightType=LT_Steady
    LightEffect=LE_FireWeaver
    LightBrightness=96
    LightHue=100
    LightRadius=8
    Mass=80.000000
    Buoyancy=90.000000
}
