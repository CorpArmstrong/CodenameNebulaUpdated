class Angel extends Bird;

//against hdtp
function bool Facelift(bool bOn)
{
}

function HeardNoise(Name eventName, EAIEventState state, XAIParams params)
	{
		//FleeFromPawn(Pawn(params.bestActor));
	}

	
function Carcass SpawnCarcass()
{
	local Inventory item;

	if (bStunned || DeusExPlayer(GetPlayerPawn()).combatDifficulty <= 4.0)
		return Super.SpawnCarcass();

	item = Inventory;

	while(item != None)
	{
		if(item.Base != Self)
			break;

		if(item.IsA('DeusExWeapon') && DeusExWeapon(item).bNativeAttack)
		{}
		else if(item.IsA('DeusExAmmo') && (item.PickupViewMesh == LodMesh'DeusExItems.TestBox' || item.Description == (class'DeusExAmmo').Default.Description))
		{}
		else
		{
			if(item.IsA('DeusExWeapon'))
			{
				DeusExWeapon(item).AmmoType = None;
				DeusExWeapon(item).PickupAmmoCount = Rand(DeusExWeapon(item).Default.PickupAmmoCount) + 1;
			}

			DeleteInventory(item);
			item.DropFrom(Location + vect(0,0,2));
		}
		item = item.Inventory;

		if(item == Inventory) // looping inventory
			item = None;
	}

	Explode();

	return None;
}

// fake a charge attack using bump
function Bump(actor Other)
{
	local DeusExWeapon dxWeapon;
	local DeusExPlayer dxPlayer;
	local float        damage;

	Super.Bump(Other);

	if (IsInState('Attacking') && (Other != None) && (Other == Enemy))
	{
		// damage both of the player's legs if the karkian "charges"
		// just use Shot damage since we don't have a special damage type for charged
		// impart a lot of momentum, also
		if (VSize(Velocity) > 100)
		{
			dxWeapon = DeusExWeapon(Weapon);
			if ((dxWeapon != None) && dxWeapon.IsA('WeaponKarkianBump') && (FireTimer <= 0))
			{
				FireTimer = DeusExWeapon(Weapon).AIFireDelay;
				damage = VSize(Velocity) / 5;
				Other.TakeDamage(damage, Self, Other.Location+vect(1,1,-1), 100*Velocity, 'Shot');
				Other.TakeDamage(damage, Self, Other.Location+vect(-1,-1,-1), 100*Velocity, 'Shot');
				dxPlayer = DeusExPlayer(Other);
				if (dxPlayer != None)
					dxPlayer.ShakeView(0.15 + 0.002*damage*2, damage*30*2, 0.3*damage*2);
			}
		}
	}
}

function Explode(/*optional vector HitLocation*/)
{
    /*local SphereEffect sphere;
    local ScorchMark s;
    local ExplosionLight light;
    local int i;
    local float explosionDamage;
    local float explosionRadius;

    explosionDamage = 300;
    explosionRadius = 256;

    // alert NPCs that I'm exploding
    AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
    PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

    // draw a pretty explosion
    light = Spawn(class'ExplosionLight',,, Location);
    if (light != None)
        light.size = 4;

    Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);

    sphere = Spawn(class'SphereEffect',,, Location);
    if (sphere != None)
        sphere.size = explosionRadius / 32.0;

    // spawn a mark
    s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
    if (s != None)
    {
        s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
        s.ReattachDecal();
    }

    // spawn some rocks and flesh fragments
    for (i=0; i<explosionDamage/6; i++)
    {
        if (FRand() < 0.3)
            spawn(class'Rockchip',,,Location);
        else
            spawn(class'FleshFragment',,,Location);
    }

    HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);*/
}

defaultproperties
{
	MinHealth=0.000000
	CarcassType=Class'CNN.AvatarCarcass'
	WalkingSpeed=0.200000
	bCanBleed=True
	bShowPain=False
	ShadowScale=1.000000
	InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1.000000,bPermanent=True)
	bSpawnBubbles=False
	bCanSwim=False
	bCanGlide=True
	GroundSpeed=400.000000
	WaterSpeed=110.000000
	AirSpeed=144.000000
	AccelRate=500.000000
	BaseEyeHeight=12.500000
	Health=100
	UnderWaterTime=99999.000000
	AttitudeToPlayer=ATTITUDE_Ignore
	HitSound2=Sound'DeusExSounds.Animal.KarkianPainLarge'
	Die=Sound'DeusExSounds.Animal.KarkianDeath'
	Alliance=Avatar
	DrawType=DT_Mesh
	Fatness=115
    Mesh=LodMesh'DeusExCharacters.Seagull'
    DrawScale=4.0
	MultiSkins(0)=Texture'DeusExDeco.Skins.ReflectionMapTex2'
	Style=STY_Masked
	CollisionRadius=26.000000
	CollisionHeight=64.099998
	ScaleGlow=10.0
	Mass=100.000000
	Buoyancy=500.000000
	RotationRate=(Yaw=30000)
	BindName="Avatar"
	FamiliarName="Angel"
	UnfamiliarName="Angel"
	Cowardice=0.0
	bFleeBigPawns=False
}
