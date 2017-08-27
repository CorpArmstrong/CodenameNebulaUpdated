class CNNBurningScientist extends ScientistMale;

var() float Flammability;			// How long does the object burn?
var() float destroyDelay;			// after timer has expired, kill scientist.
var() bool bCanBeBurned;

var bool isBurning;

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if (((DamageType == 'Burned') || (DamageType == 'Flamed'))
			&& bCanBeBurned && !isBurning)
    {
		isBurning = true;
		StartFire();
		//PlayAnimPivot('Jump', 3, 0.1);
		//PlayAnim(Sequence, Rate, TweenTime);
		LoopAnim('Panic', 3, 0.1, Flammability);
		SetTimer(Flammability + destroyDelay, false);
	}
	
	if (DamageType == 'AlmostKilled')
	{
		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, 'Shot');
	}
}

function StartFire()
{
    local Fire f;
    local int i;
    local vector loc;

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
	{
        f.Destroy();
	}
}

function Timer()
{
	ExtinguishFire();
	self.TakeDamage(300, none, vect(0,0,0), vect(0,0,0), 'AlmostKilled');
}

DefaultProperties
{
    Flammability=30.000000
	destroyDelay=0.1
    bCanBeBurned=true
    bAlliancesChanged=False
    Orders=Standing
    HomeTag=Start
    HomeExtent=128.000000
    bHateShot=False
    bHateInjury=False
    bReactFutz=True
    bReactPresence=False
    bReactAlarm=True
    bReactCarcass=True
    bFearHacking=True
    bFearInjury=True
    bFearAlarm=False
    bFearProjectiles=True
    MaxProvocations=2
    InitialAlliances(0)=(AllianceName=Player)
    InitialAlliances(1)=(AllianceName=mj12)
    InitialAlliances(2)=(AllianceName=security)
    InitialAlliances(3)=(AllianceName=Subject)
    InitialAlliances(4)=(AllianceName=bum)
    InitialAlliances(5)=(AllianceName=Researcher,AllianceLevel=1.000000)
    Alliance=Researcher
    Tag=Pagan
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Skin=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_DressShirt_S'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.HarleyFilbenTex0'
    MultiSkins(1)=None
    MultiSkins(2)=None
    MultiSkins(3)=Texture'DeusExCharacters.Skins.PantsTex10'
    MultiSkins(4)=None
    MultiSkins(5)=Texture'DeusExCharacters.Skins.ChefTex1'
    BindName="Pagan"
    BarkBindName="Biotechnitian"
    FamiliarName="Biotechnitian"
    UnfamiliarName="Biotechnitian"
    Name=ScientistMale0
}
