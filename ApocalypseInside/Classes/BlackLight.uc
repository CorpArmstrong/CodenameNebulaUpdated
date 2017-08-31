//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BlackLight extends CNNDog;

// var int ORBIT_RADIUS = 15;

var (UpsDamage) float PawnDamageRadius;
var (UpsDamage) float PawnDamage;
var (UpsDamage) name  PawnDamageType;
var (UpsDamage) bool  bDamagePawns;            // if they are not invincible

var (UpsDamage) float DecorDamageRadius;
var (UpsDamage) float DecorDamage;
var (UpsDamage) name  DecorDamageType;
var (UpsDamage) bool  bDamageDxDecoration;     // if they breakable

var (UpsDamage) float CnnMoverBlowUpRadius;
var (UpsDamage) bool  bBlowUp_CnnMovers;       // if they breakable

var (UpsVisualEffects) bool  bPulsation;
var (UpsVisualEffects) bool  bRotating;

var (UpsVisualEffects) float PulsationTime;
var (UpsVisualEffects) float PulsationRange;

var (UpsVisualEffects) int RotationSpeed;     // one turn around self per thisnumber of seconds

var (UpsTextures) texture SpheresTexture;
var (UpsTextures) texture ElectroRaysTexture;

var (UpsTextures) ERenderStyle Sphere0Style;
var (UpsTextures) ERenderStyle Sphere1Style;
var (UpsTextures) ERenderStyle Sphere2Style;
var (UpsTextures) ERenderStyle ElectroRaysStyle;




var Pawn pPawn;

//var JJElecEmitter em[15];
var JJElecEmitter em[18];
//var CNNSphereFragment spheres[6];
var CNNSphereFragment spheres[9];
var LAM grenades[4];

function PostBeginPlay()
{
    local int i;

    super.PostBeginPlay();

    //self.DrawType = DT_None;

    // electric emmiters
	for ( i = 0; i < 12; i ++ )
    {
        em[i] = Spawn(class'JJElecEmitter', self);
        em[i].SetLocation(self.Location + vect(0,0,25));
        em[i].AttachTag = self.Tag;
        em[i].accumTime = 0.084 * i;

        em[i].proxy.Skin = ElectroRaysTexture;
        em[i].proxy.Style = STY_Modulated;
    }

    // drunk cores-spheres
	for ( i = 0; i < 3; i ++ )
    {
        spheres[i] = Spawn(class'CNNSphereFragment', self);
        spheres[i].SetLocation(self.Location + vect(0,0,25));
        spheres[i].AttachTag = self.Tag;
        spheres[i].DrawScale = 0.2f * (i+1);

        spheres[i].MultiSkins[0] = SpheresTexture;
    }

/**/
	  // FOR TANTLUS
	  // here you can write style and Unlite parameters for spheres
      spheres[2].Style = STY_Modulated;
      spheres[1].Style = STY_Modulated;
      spheres[0].Style = STY_Normal;
      spheres[0].bUnlit = true;
    //spheres[0].bCollideActors = true; // for red rays


// front
    em[0].SetRotation(rot(0,0,0));
    em[1].SetRotation(rot(0,0,0));
// left probably
    em[2].SetRotation(rot(0,16384,0));
    em[3].SetRotation(rot(0,16384,0));
// back
    em[4].SetRotation(rot(0,49152,0));
    em[5].SetRotation(rot(0,49152,0));
// right probably
    em[6].SetRotation(rot(0,32768,0));
    em[7].SetRotation(rot(0,32768,0));
// up probably
    em[8].SetRotation(rot(16384,0,0));
    em[9].SetRotation(rot(16384,0,0));
// down probably
    em[10].SetRotation(rot(49152,0,0));
    em[11].SetRotation(rot(49152,0,0));

    //em[12].proxy.Skin=Texture'Effects.UserInterface.DrunkFX';
    //em[13].proxy.Skin=Texture'Effects.UserInterface.DrunkFX';
    //em[14].proxy.Skin=Texture'Effects.UserInterface.DrunkFX';

    //em[15].proxy.Skin=Texture'Effects.UserInterface.DrunkFX';
    //em[16].proxy.Skin=Texture'Effects.UserInterface.DrunkFX';
    //em[17].proxy.Skin=Texture'Effects.UserInterface.DrunkFX';

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
			//if (em[i].AttachTag != '')
			//	em[i].AttachTag = '';

			tmpRotator.Pitch = 0;
			tmpRotator.Yaw = RotationSpeed;
			tmpRotator.Roll = 0;

			tmpRotator *= deltaTime;

			em[i].SetRotation(em[i].Rotation+tmpRotator);
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
		if ( spherePulseValue > 0.5 )
			spherePulseValue = 1 - spherePulseValue;
		spherePulseValue *= 2;

		for (i = 0; i < 3; i ++)
		{
			sphereRadius = 0.2f*(i+1);

			spheres[i].DrawScale = sphereRadius +
				( sphereRadius * (PulsationRange-1) * spherePulseValue );
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












/**/



	//damage to Pawns
	if ( bDamagePawns )
	{
		foreach AllActors(class'ScriptedPawn', sPawn)
			if ( !sPawn.bInvincible && sPawn.Tag != self.Tag )
				if (VSize(sPawn.Location - self.Location) <= PawnDamageRadius)
					sPawn.TakeDamage(PawnDamage, self, sPawn.Location, vect(0,0,0), PawnDamageType);

       	if( pPawn == none )
			pPawn = GetPlayerPawn();

		if( pPawn != none )
			if (VSize(pPawn.Location - self.Location) <= PawnDamageRadius)
				pPawn.TakeDamage(PawnDamage, self, pPawn.Location, vect(0,0,0), PawnDamageType);
	}


	//damage to decorations
    if ( bDamageDxDecoration )
    	foreach AllActors(class'DeusExDecoration', decor)
			if (VSize(decor.Location - self.Location) <= DecorDamageRadius)
				decor.TakeDamage(DecorDamage, self, decor.Location, vect(0,0,0), DecorDamageType);

	//destroying movers
	if ( bBlowUp_CnnMovers )
		foreach AllActors(class'CNNMover', mover)
			if (VSize(mover.Location - self.Location) <= CnnMoverBlowUpRadius)
				if ( mover.bBreakable )
					//mover.TakeDamage(DamageToDecors, self, mover.Location, vect(0,0,0), 'Exploded');
					mover.BlowItUp(self);

	// call event when trigger in radius
	// will be realized like a collision with CNNSimpleTrigger
}


function SelfDestructionGrenades()
{
local int i;

	for ( i = 0; i < 4; i ++ )
	{
		grenades[i] = Spawn(class'LAM', none);
		grenades[i].SetPhysics(PHYS_None);
		grenades[i].AttachTag = self.Tag;
//		grenades[i].DrawType = DT_none;
		grenades[i].bHidden = true;
		grenades[i].fuseLength = 0.01;
		grenades[i].bDisabled = true;
		grenades[i].SetCollision( false, false, false);
	}

	grenades[0].SetLocation( self.Location + vect(+50,0,-25) );
	grenades[1].SetLocation( self.Location + vect(-50,0,-25) );
	grenades[2].SetLocation( self.Location + vect(0,+50,-25) );
	grenades[3].SetLocation( self.Location + vect(0,-50,-25) );
}

function SelfDestruction()
{
local int i;

	self.bInvincible = false;
	//self.bCollideActors = true;
	self.SetCollision( true, true, true);

	for ( i = 0; i < 4; i ++ )
	{
		grenades[i].bDisabled = false;
		grenades[i].bDamaged = true;
		grenades[i].Explode(grenades[i].Location, Vector(grenades[i].Rotation));
	}
	//destroy();
}



function Destroyed()
{
    local int i;

    for ( i = 0; i < 12; i ++ )
       em[i].Destroy();

    for ( i = 0; i < 3; i ++ )
       spheres[i].Destroy();

	Super.Destroyed();
}


defaultproperties
{
	SpheresTexture=Texture'Effects.UserInterface.DrunkFX'
	//ElectroRaysTexture=FireTexture'Effects.Electricity.Nano_SFX'
	ElectroRaysTexture=Texture'Effects.UserInterface.DrunkFX'

	PawnDamageRadius=150
	PawnDamage=1000
	PawnDamageType=Exploded
	bDamagePawns=True

	DecorDamageRadius=320
	DecorDamage=1000
	DecorDamageType=Exploded
	bDamageDxDecoration=False // do not use please

	CnnMoverBlowUpRadius=320
	bBlowUp_CnnMovers=True

	bPulsation=true
	bRotating=false

	PulsationTime=2          // number of second is one cycle
	PulsationRange=1.25      // scale from 1 to number and number to 1

	//PulsationTime=0.25
	//PulsationRange=2

	RotationSpeed=20000.0


    bPlayDying=False
    CarcassType=None
    bInvincible=True
    bHidden=True
    DrawType=DT_Sprite
    CollisionHeight=50.000000
}
