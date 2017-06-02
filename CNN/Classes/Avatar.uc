class Avatar extends MIB;

//against hdtp
function bool Facelift(bool bOn)
{
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
	CarcassType=Class'DeusEx.KarkianCarcass'
	WalkingSpeed=0.200000
	bCanBleed=True
	bShowPain=False
	ShadowScale=1.000000
	InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1.000000,bPermanent=True)
	InitialInventory(0)=(Inventory=Class'DeusEx.WeaponSword')
	WalkSound=Sound'DeusExSounds.Animal.KarkianFootstep'
	bSpawnBubbles=False
	bCanSwim=True
	bCanGlide=False
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
	Alliance=Karkian
	DrawType=DT_Mesh
	Fatness=115
    Mesh=LodMesh'DeusExCharacters.GM_DressShirt'
    DrawScale=1.10
	MultiSkins(0)=Texture'DeusExDeco.Skins.BobPageAugmentedTex2'
    MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(2)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(3)=Texture'DeusExDeco.Skins.BobPageAugmentedTex1'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.MIBTex1'
    MultiSkins(5)=Texture'DeusExDeco.Skins.BobPageAugmentedTex3'
    MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
	CollisionRadius=22.000000
	CollisionHeight=52.099998
	Mass=100.000000
	Buoyancy=500.000000
	RotationRate=(Yaw=30000)
	BindName="Avatar"
	FamiliarName="Avatar Drone"
	UnfamiliarName="Avatar Drone"
}
