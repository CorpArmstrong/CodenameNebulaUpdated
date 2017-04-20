//=============================================================================
// Beans.	(c) 2003 JimBowen
//=============================================================================
class Beans expands BowenWeapon;

var(Bowen) float AmbientFallDamping, Liftpower, FlameInterval, ACMult, ASMult, DampAmt, FlameAngle;
var(Bowen) Sound PopSound;
var bool bUsed;
var float FlameTime, FlamesUsed;

const LongRange = 200;
const ShortRange = 75;

simulated function PreBeginPlay()
{
	if(Level.NetMode != NM_Standalone)
	{
		LiftPower *= 1.3;
		AmbientFallDamping *= 1.3;
	}
}

function DropFrom(vector StartLocation)
{
	Pawn(Owner).AirControl = Pawn(Owner).Default.AirControl;
	Pawn(Owner).AirSpeed = Pawn(Owner).Default.AirSpeed;
	bUsed = False;
	LifeSpan = 2;
	Super.DropFrom(StartLocation);
}

simulated function tick (float deltatime)
{
	if(DeusExPlayer(Owner) != None)
	{
		if(bUsed && Owner.isA('Pawn'))
		{
			//if(Pawn(Owner).Velocity.Z < 0)
			//	Pawn(owner).Velocity.Z *= 10*DeltaTime;
			Pawn(Owner).Velocity += vect(0,0,1) * AmbientFallDamping * deltaTime;
			Pawn(Owner).AirControl = Pawn(Owner).Default.AirControl * ACMult;
			Pawn(Owner).AirSpeed = Pawn(Owner).Default.AirSpeed * ASMult;
			FlameTime += DeltaTime;
			FlamesUsed += DeltaTime;
		}
				
		FlameInterval = Default.FlameInterval + FRand();
		
		if(FlameTime >= FlameInterval && Owner.Physics == PHYS_Falling && FlamesUsed <= DampAmt)
		{
			FlameTime = 0;
			Fart(ShortRange);
			PlaySimSound( PopSound, SLOT_None, TransientSoundVolume, 2048 );
		}
		
		if(FlamesUsed > DampAmt || Owner.Physics != PHYS_Falling)
		{	
			Pawn(Owner).AirControl = Pawn(Owner).Default.AirControl;
			Pawn(Owner).AirSpeed = Pawn(Owner).Default.AirSpeed;
			bUsed = False;
		}
		
		
		if (AmmoType.AmmoAmount == 0 && bUsed)
			DropFrom(Location);
	}
	Super.Tick(DeltaTime);
}

simulated function int PlaySimSound( Sound snd, ESoundSlot Slot, float Volume, float Radius )
{
	local float Modpitch;
	
		ModPitch = 80 + (FRand() * 40);

		
		if ( Owner != None )
		{
			if ( Level.NetMode == NM_Standalone )
				Owner.PlaySound( snd, Slot, Volume, , Radius, ModPitch );
			else
			{
				Owner.PlayOwnedSound( snd, Slot, Volume, , Radius, ModPitch );
				return 1;
			}
		}
		return 0;
}

simulated function playReloading();
simulated function playSelectiveFiring();

simulated function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	bUsed = True;
	FlamesUsed = 0;
	Pawn(Owner).SetPhysics(PHYS_Falling);
	if(Pawn(Owner).Velocity.Z < 0)
		Pawn(owner).Velocity.Z /= 3;
	Pawn(Owner).Velocity += vect(0,0,1) * LiftPower;
	Fart(LongRange);
}

simulated function Fart(Float Range)
{
	local FlatulentFlame F;
	local actor a;
	local float fangle;
	local vector vvect, dvect;

		
		F = Spawn(class'BowenLite.FlatulentFlame',Owner,,Owner.Location,rotator((vect(0,0,-10) + VRand())));
		F.MaxRange = Range;
		F.LifeSpan = Range / 100;
		F.MaxDrawScale *= range / 30;
		//F.MinDrawScale *= range / 30;
	
		if (Role == ROLE_Authority)
			foreach radiusactors (class'actor', a, (Range/2))
			{
				if (a!= Owner)
				{
					vvect = normal(vect(0,0,-1));
					dvect = normal(a.Location - Location);
					fangle = Acos(vvect dot dvect);
					
					if (fangle < FlameAngle)
					{
						a.TakeDamage((range/60), Pawn(Owner), a.Location, vect(0,0,0), 'Flamed');
					//	log ("did direct damage");
					}
					//else log ("did not do direct damage, fangle ="@fangle@" FlameAngle ="@FlameAngle);	
				}
			
			}
}

static final function float ACos  ( float A )	// thanks to UnrealWiki for this
{
  if (A>1||A<-1) //outside domain!
    return 0;
  if (A==0) //div by 0 check
    return (Pi/2.0);
  A=ATan(Sqrt(1.0-Square(A))/A);
  if (A<0)

    A+=Pi;
  Return A;
}

//---END-CLASS---

defaultproperties
{
     AmbientFallDamping=400.000000
     Liftpower=175.000000
     FlameInterval=0.250000
     ACMult=30.000000
     ASMult=10.000000
     DampAmt=5.000000
     FlameAngle=0.500000
     PopSound=Sound'DeusExSounds.Generic.PaperHit1'
     ShotTime=0.200000
     reloadTime=0.000000
     AmmoName=Class'BowenLite.AmmoBean'
     ReloadCount=1
     PickupAmmoCount=30
     shakemag=0.000000
     InventoryGroup=108
     ItemName="A can of bean vindaloo"
     ItemArticle=""
     PlayerViewOffset=(Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Sodacan'
     PickupViewMesh=LodMesh'DeusExItems.Sodacan'
     ThirdPersonMesh=LodMesh'DeusExItems.Sodacan'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconSodaCan'
     largeIcon=Texture'DeusExUI.Icons.LargeIconSodaCan'
     largeIconWidth=24
     largeIconHeight=45
     Description="NEW! from BowenCo Food Indistries! The BowenCo beans vindaloo is guaranteed to give you that extra kick of energy you needed! (BowenCo Food Industries may not be held responsible for any injury caused by excessive flatulence) |n|nBowenCoBeans - It gives you wings!"
     beltDescription="BEANS"
     Mesh=LodMesh'DeusExItems.Sodacan'
     CollisionRadius=3.000000
     CollisionHeight=4.500000
     Mass=5.000000
     Buoyancy=3.000000
     bAutomatic=True
}
