//================================================================================
// Beans.
//================================================================================
class Beans extends BowenWeapon;

const ShortRange= 200;
const LongRange= 300;
var(bowen) float AmbientFallDamping;
var(bowen) float Liftpower;
var(bowen) float FlameInterval;
var(bowen) float ACMult;
var(bowen) float ASMult;
var(bowen) float DampAmt;
var(bowen) float FlameAngle;
var(bowen) Sound PopSound;
var bool bUsed;
var float FlameTime;
var float FlamesUsed;

simulated function PreBeginPlay ()
{
	if ( Level.NetMode != 0 )
	{
		Liftpower *= 1.30;
		AmbientFallDamping *= 1.30;
	}
}

function DropFrom (Vector startLocation)
{
	Pawn(Owner).AirControl=Pawn(Owner).Default.AirControl;
	Pawn(Owner).AirSpeed=Pawn(Owner).Default.AirSpeed;
	bUsed=False;
	LifeSpan=2.00;
	Super.DropFrom(startLocation);
}

simulated function Tick (float DeltaTime)
{
	if ( DeusExPlayer(Owner) != None )
	{
		if ( bUsed && Owner.IsA('Pawn') )
		{
			Pawn(Owner).Velocity += vect(0.00,0.00,1.00) * AmbientFallDamping * DeltaTime;
			Pawn(Owner).AirControl=Pawn(Owner).Default.AirControl * ACMult;
			Pawn(Owner).AirSpeed=Pawn(Owner).Default.AirSpeed * ASMult;
			FlameTime += DeltaTime;
			FlamesUsed += DeltaTime;
		}
		FlameInterval=Default.FlameInterval + FRand();
		if ( (FlameTime >= FlameInterval) && (Owner.Physics == 2) && (FlamesUsed <= DampAmt) )
		{
			FlameTime=0.00;
			Fart(200.00);
			PlaySimSound(PopSound,0,TransientSoundVolume,2048.00);
		}
		if ( (FlamesUsed > DampAmt) || (Owner.Physics != 2) )
		{
			Pawn(Owner).AirControl=Pawn(Owner).Default.AirControl;
			Pawn(Owner).AirSpeed=Pawn(Owner).Default.AirSpeed;
			bUsed=False;
		}
		if ( (AmmoType.AmmoAmount == 0) && bUsed )
		{
			DropFrom(Location);
		}
	}
	Super.Tick(DeltaTime);
}

simulated function int PlaySimSound (Sound snd, ESoundSlot Slot, float Volume, float Radius)
{
	local float Modpitch;

	Modpitch=80.00 + FRand() * 40;
	if ( Owner != None )
	{
		if ( Level.NetMode == 0 )
		{
			Owner.PlaySound(snd,Slot,Volume,,Radius,Modpitch);
		}
		else
		{
			Owner.PlayOwnedSound(snd,Slot,Volume,,Radius,Modpitch);
			return 1;
		}
	}
	return 0;
}

simulated function playReloading ();

simulated function PlaySelectiveFiring ();

simulated function Projectile ProjectileFire (Class<Projectile> ProjClass, float projSpeed, bool bWarn)
{
	bUsed=True;
	FlamesUsed=0.00;
	Pawn(Owner).SetPhysics(2);
	if ( Pawn(Owner).Velocity.Z < 0 )
	{
		Pawn(Owner).Velocity.Z /= 3;
	}
	Pawn(Owner).Velocity += vect(0.00,0.00,1.00) * Liftpower;
	Fart(300.00);
}

simulated function Fart (float range)
{
	local FlatulentFlame F;
	local Actor A;
	local float fangle;
	local Vector vvect;
	local Vector dvect;

	F=Spawn(Class'FlatulentFlame',Owner,,Owner.Location,rotator(vect(0.00,0.00,-10.00) + VRand()));
	F.maxRange=range;
	F.LifeSpan=range / 100;
	F.maxDrawScale *= range / 15;
	F.MinDrawScale *= range / 30;
	if ( Role == 4 )
	{
		foreach RadiusActors(Class'Actor',A,range / 2)
		{
			if ( A != Owner )
			{
				vvect=Normal(vect(0.00,0.00,-1.00));
				dvect=Normal(A.Location - Location);
				fangle=ACos(vvect Dot dvect);
				if ( fangle < FlameAngle )
				{
					A.TakeDamage(range / 60,Pawn(Owner),A.Location,vect(0.00,0.00,0.00),'Flamed');
				}
			}
			continue;
		}
	}
}

static final function float ACos (float A)
{
	if ( (A > 1) || (A < -1) )
	{
		return 0.00;
	}
	if ( A == 0 )
	{
		return 3.14 / 2.00;
	}
	A=Atan(Sqrt(1.00 - Square(A)) / A);
	if ( A < 0 )
	{
		A += 3.14;
	}
	return A;
}

defaultproperties
{
    AmbientFallDamping=400.00
    Liftpower=175.00
    FlameInterval=0.25
    ACMult=30.00
    ASMult=10.00
    DampAmt=5.00
    FlameAngle=1.50
    PopSound=Sound'DeusExSounds.Generic.PaperHit1'
    ShotTime=0.00
    reloadTime=0.00
    AmmoName=Class'AmmoBean'
    ReloadCount=1
    PickupAmmoCount=30
    shakemag=0.00
    InventoryGroup=108
    ItemName="A can of bean vindaloo"
    ItemArticle=""
    PlayerViewOffset=(X=30.00, Y=0.00, Z=-12.00)
    PlayerViewMesh=LodMesh'DeusExItems.Sodacan'
    PickupViewMesh=LodMesh'DeusExItems.Sodacan'
    ThirdPersonMesh=LodMesh'DeusExItems.Sodacan'
    LandSound=Sound'DeusExSounds.Generic.MetalHit1'
    Icon=Texture'DeusExUI.Icons.BeltIconSodaCan'
    largeIcon=Texture'DeusExUI.Icons.LargeIconSodaCan'
    largeIconWidth=24
    largeIconHeight=45
    Description="NEW! from BowenCo Food Indistries! The BowenCo beans vindaloo is guaranteed to give you that extra kick of energy you needed! (BowenCo Food Industries may not be held responsible for any injury caused by excessive flatulence)"
    beltDescription="BEANS"
    Mesh=LodMesh'DeusExItems.Sodacan'
    CollisionRadius=3.00
    CollisionHeight=4.50
    Mass=5.00
    Buoyancy=3.00
}