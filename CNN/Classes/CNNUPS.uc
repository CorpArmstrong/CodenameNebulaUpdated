//-----------------------------------------------------------
// unknown paranormal shit          komentariy v kot
//-----------------------------------------------------------
class CNNUPS extends CNNDog;

var (UpsDamage) float PawnDamageRadius;
var (UpsDamage) float PawnDamage;
var (UpsDamage) name  PawnDamageType;
var (UpsDamage) bool  bDamagePawns;            // if they are not invincible

var (UpsDamage) float DecorDamageRadius;
var (UpsDamage) float DecorDamage;
var (UpsDamage) name  DecorDamageType;
var (UpsDamage) bool  bDamageDxDecoration;      // if they breakable

var (UpsDamage) float CnnMoverBlowUpRadius;
var (UpsDamage) bool  bBlowUp_CnnMovers;        // if they breakable

var (UpsVisualEffects) bool  bPulsation;
var (UpsVisualEffects) bool  bRotating;

var (UpsVisualEffects) float PulsationTime;
var (UpsVisualEffects) float PulsationRange;

var (UpsVisualEffects) int RotationSpeed;       // one turn around self per thisnumber of seconds

var Pawn pPawn;

var JJElecEmitter em[18];
var CNNSphereFragment spheres[9];
var LAM grenades[4];

function PostBeginPlay()
{
    local int i;

    super.PostBeginPlay();

    // electric emmiters
	for (i = 0; i < ArrayCount(em); i++)
    {
        em[i] = Spawn(class'JJElecEmitter', self);
        em[i].SetLocation(self.Location + vect(0, 0, 25));

        if (i < 12)
        {
           em[i].AttachTag = self.Tag;
           em[i].accumTime = 0.084 * i;
        }
        else
        {
           // attaching later
           em[i].accumTime = 0.0;
           em[i].randomAngle = 0;
        }
    }

    // blue cores-spheres
	for (i = 0; i < 3; i++)
    {
        spheres[i] = Spawn(class'CNNSphereFragment', self);
        spheres[i].SetLocation(self.Location + vect(0, 0, 25));
        spheres[i].AttachTag = self.Tag;
        spheres[i].DrawScale = 0.2f * (i + 1);
    }

    // small balls
	for (i = 3; i < ArrayCount(spheres); i++)
    {
        spheres[i] = Spawn(class'CNNSphereFragment', self);
        spheres[i].DrawScale = 0.05f;
    }

    spheres[3].SetLocation(self.Location + vect(0, 0, 25) + vect(23, 0, 0));
    spheres[3].AttachTag = self.Tag;
    spheres[3].MultiSkins[0] = Texture'Effects.Virus_SFX';

    spheres[4].SetLocation(self.Location + vect(0, 0, 25) + vect(0, 23, 0));
    spheres[4].AttachTag = self.Tag;
    spheres[4].MultiSkins[0] = Texture'Effects.Virus_SFX';

    spheres[5].SetLocation(self.Location + vect(0, 0, 25) + vect(0, 0, 23));
    spheres[5].AttachTag = self.Tag;
    spheres[5].MultiSkins[0] = Texture'Effects.Virus_SFX';

    spheres[6].SetLocation(self.Location + vect(0, 0, 25) + vect(-23, 0, 0));
    spheres[6].AttachTag = self.Tag;
    spheres[6].MultiSkins[0] = Texture'Effects.Virus_SFX';

    spheres[7].SetLocation(self.Location + vect(0, 0, 25) + vect(0, -23, 0));
    spheres[7].AttachTag = self.Tag;
    spheres[7].MultiSkins[0] = Texture'Effects.Virus_SFX';

    spheres[8].SetLocation(self.Location + vect(0, 0, 25) + vect(0, 0, -23));
    spheres[8].AttachTag = self.Tag;
    spheres[8].MultiSkins[0] = Texture'Effects.Virus_SFX';

    spheres[0].Style = STY_Normal;
    spheres[0].bUnlit = true;

    //spheres[0].bCollideActors = true; // for red rays

    // front
    em[0].SetRotation(rot(0, 0, 0));
    em[1].SetRotation(rot(0, 0, 0));

    // left probably
    em[2].SetRotation(rot(0, 16384, 0));
    em[3].SetRotation(rot(0, 16384, 0));

    // back
    em[4].SetRotation(rot(0, 49152, 0));
    em[5].SetRotation(rot(0, 49152, 0));

    // right probably
    em[6].SetRotation(rot(0, 32768, 0));
    em[7].SetRotation(rot(0, 32768, 0));

    // up probably
    em[8].SetRotation(rot(16384, 0, 0));
    em[9].SetRotation(rot(16384, 0, 0));

    // down probably
    em[10].SetRotation(rot(49152, 0, 0));
    em[11].SetRotation(rot(49152, 0, 0));

    em[12].proxy.Skin = Texture'Effects.Virus_SFX';
    em[13].proxy.Skin = Texture'Effects.Virus_SFX';
    em[14].proxy.Skin = Texture'Effects.Virus_SFX';

    em[15].proxy.Skin = Texture'Effects.Virus_SFX';
    em[16].proxy.Skin = Texture'Effects.Virus_SFX';
    em[17].proxy.Skin = Texture'Effects.Virus_SFX';

    SelfDestructionGrenades();
}

function Tick(float deltaTime)
{
    local int i;
    local vector tmpVect;
    local int tmpInt;
    local rotator tmpRotator;

    local float spherePulseValue;
    local float sphereRadius;

    local vector coordsSmallBall, coordsCentralBall;

    local ScriptedPawn sPawn;
    local DeusExDecoration decor;
    local CNNMover mover;

    super.Tick(deltaTime);

    if (bRotating)
    {
        for(i = 0; i < 12; i++)
        {
            tmpRotator.Pitch = 0;
            tmpRotator.Yaw = RotationSpeed;
            tmpRotator.Roll = 0;
            tmpRotator *= deltaTime;
            em[i].SetRotation(em[i].Rotation + tmpRotator);
        }
    }

    if (bPulsation)
    {
        // current puls period
        // output 0.0 - 1.0
        spherePulseValue = (level.TimeSeconds % PulsationTime) / PulsationTime;

        // current puls value
        // input  0.0 - 0.5 - 1.0
        // output 0.0 - 1.0 - 0.0
        if (spherePulseValue > 0.5)
        {
            spherePulseValue = 1 - spherePulseValue;
        }

        spherePulseValue *= 2;

        for (i = 0; i < 3; i ++)
        {
            sphereRadius = 0.2f * (i + 1);

            spheres[i].DrawScale = sphereRadius +
                (sphereRadius * (PulsationRange - 1) * spherePulseValue);
        }
    }

    /*
    ## rotating small red balls
    get a local vector
    rotate local vector
    set local vector

    1) World coord of small ball - world coords of central ball
    2) -
    3) local vector + coords of central ball
    */

    coordsCentralBall = spheres[2].Location;

    // 1
    coordsSmallBall = spheres[3].Location;
    coordsSmallBall -= coordsCentralBall;

    // 2, 3
    tmpRotator = rot(9000, 0, 0);
    tmpVect = coordsSmallBall << (tmpRotator * deltaTime);
    spheres[3].SetLocation(tmpVect + coordsCentralBall);

    em[12].SetLocation(spheres[3].Location);
    tmpVect *= -1;
    em[12].SetRotation(rotator(tmpVect));

    // 1
    coordsSmallBall = spheres[4].Location;
    coordsSmallBall -= coordsCentralBall;

    // 2, 3
    tmpRotator = rot(0, 9000, 0);
    tmpVect = coordsSmallBall << (tmpRotator * deltaTime);
    spheres[4].SetLocation(tmpVect + coordsCentralBall);

    em[13].SetLocation(spheres[4].Location);
    tmpVect *= -1;
    em[13].SetRotation(rotator(tmpVect));

    // 1
    coordsSmallBall = spheres[5].Location;
    coordsSmallBall -= coordsCentralBall;

    // 2, 3
    tmpRotator = rot(0, 0, 9000);
    tmpVect = coordsSmallBall << (tmpRotator * deltaTime);
    spheres[5].SetLocation(tmpVect + coordsCentralBall);

    em[14].SetLocation(spheres[5].Location);
    tmpVect *= -1;
    em[14].SetRotation(rotator(tmpVect));

    // 1
    coordsSmallBall = spheres[6].Location;
    coordsSmallBall -= coordsCentralBall;

    // 2, 3
    tmpRotator = rot(9000, 0, 0);
    tmpVect = coordsSmallBall << (tmpRotator * deltaTime);
    spheres[6].SetLocation(tmpVect + coordsCentralBall);

    em[15].SetLocation(spheres[6].Location);
    tmpVect *= -1;
    em[15].SetRotation(rotator(tmpVect));

    // 1
    coordsSmallBall = spheres[7].Location;
    coordsSmallBall -= coordsCentralBall;

    // 2, 3
    tmpRotator = rot(0, 9000, 0);
    tmpVect = coordsSmallBall << (tmpRotator * deltaTime);
    spheres[7].SetLocation(tmpVect + coordsCentralBall);

    em[16].SetLocation(spheres[7].Location);
    tmpVect *= -1;
    em[16].SetRotation(rotator(tmpVect));

    // 1
    coordsSmallBall = spheres[8].Location;
    coordsSmallBall -= coordsCentralBall;

    // 2, 3
    tmpRotator = rot(0, 0, 9000);
    tmpVect = coordsSmallBall << (tmpRotator * deltaTime);
    spheres[8].SetLocation(tmpVect + coordsCentralBall);

    em[17].SetLocation(spheres[8].Location);
    tmpVect *= -1;
    em[17].SetRotation(rotator(tmpVect));

    //damage to Pawns
    if (bDamagePawns)
    {
        foreach AllActors(class'ScriptedPawn', sPawn)
        {
            if (!sPawn.bInvincible && sPawn.Tag != self.Tag &&
               (VSize(sPawn.Location - self.Location) <= PawnDamageRadius))
            {
                sPawn.TakeDamage(PawnDamage, self, sPawn.Location, vect(0, 0, 0), PawnDamageType);
            }
        }

        if (pPawn == none)
        {
            pPawn = GetPlayerPawn();
        }
        else
        {
            if (VSize(pPawn.Location - self.Location) <= PawnDamageRadius)
            {
                pPawn.TakeDamage(PawnDamage, self, pPawn.Location, vect(0, 0, 0), PawnDamageType);
            }
        }
    }

    //damage to decorations
    if (bDamageDxDecoration)
    {
        foreach AllActors(class'DeusExDecoration', decor)
        {
            if (VSize(decor.Location - self.Location) <= DecorDamageRadius)
            {
                decor.TakeDamage(DecorDamage, self, decor.Location, vect(0, 0, 0), DecorDamageType);
            }
        }
    }

    //destroying movers
    if (bBlowUp_CnnMovers)
    {
        foreach AllActors(class'CNNMover', mover)
        {
            if (VSize(mover.Location - self.Location) <= CnnMoverBlowUpRadius)
            {
                if (mover.bBreakable)
                {
                    mover.BlowItUp(self);
                }
            }
        }
    }

    // call event when trigger in radius
    // will be realized like a collision with CNNSimpleTrigger
}

function SelfDestructionGrenades()
{
    local int i;

    for (i = 0; i < ArrayCount(grenades); i++)
    {
        grenades[i] = Spawn(class'LAM', none);
        grenades[i].SetPhysics(PHYS_None);
        grenades[i].AttachTag = self.Tag;
        grenades[i].bHidden = true;
        grenades[i].fuseLength = 0.01;
        grenades[i].bDisabled = true;
        grenades[i].SetCollision(false, false, false);
    }

    grenades[0].SetLocation(self.Location + vect(+50, 0, -25));
    grenades[1].SetLocation(self.Location + vect(-50, 0, -25));
    grenades[2].SetLocation(self.Location + vect(0, +50, -25));
    grenades[3].SetLocation(self.Location + vect(0, -50, -25));
}

function SelfDestruction()
{
    local int i;

    self.bInvincible = false;
    self.SetCollision(true, true, true);

    for (i = 0; i < ArrayCount(grenades); i++)
    {
        grenades[i].bDisabled = false;
        grenades[i].bDamaged = true;
        grenades[i].Explode(grenades[i].Location, Vector(grenades[i].Rotation));
    }
}

function Destroyed()
{
    local int i;

    for (i = 0; i < ArrayCount(em); i++)
    {
       em[i].Destroy();
    }

    for (i = 0; i < ArrayCount(spheres); i++)
    {
       spheres[i].Destroy();
    }

	super.Destroyed();
}

defaultproperties
{
    PawnDamageRadius=150
    PawnDamage=1000
    PawnDamageType=Exploded
    bDamagePawns=true
    DecorDamageRadius=320
    DecorDamage=1000
    DecorDamageType=Exploded
    bDamageDxDecoration=false // do not use please
    CnnMoverBlowUpRadius=320
    bBlowUp_CnnMovers=true
    bPulsation=true
    bRotating=false
    PulsationTime=2          // number of second is one cycle
    PulsationRange=1.25      // scale from 1 to number and number to 1
    RotationSpeed=20000.0
    bPlayDying=false
    CarcassType=none
    bInvincible=true
    bHidden=true
    bFearIndirectInjury=false
    bHateInjury=false
    DrawType=DT_Sprite
    CollisionHeight=50.000000
    Orders=Guarding
    OrderTag=OpenAirlock
    bAlwaysPatrol=true
}
