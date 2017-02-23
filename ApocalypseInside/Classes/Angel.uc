//=============================================================================
// Angel.
//=============================================================================
class Angel extends Pigeon;

defaultproperties
{
    CarcassType=Class'AngelCarcass'
    WalkingSpeed=0.67
    GroundSpeed=24.00
    WaterSpeed=8.00
    AirSpeed=150.00
    AccelRate=500.00
    JumpZ=0.00
    BaseEyeHeight=3.00
    Health=20
    UnderWaterTime=20.00
    AttitudeToPlayer=0
    HealthHead=20
    HealthTorso=20
    HealthLegLeft=20
    HealthLegRight=20
    HealthArmLeft=20
    HealthArmRight=20
    Alliance=Pigeon
    DrawType=2
    Mesh=LodMesh'DeusExCharacters.Pigeon'
    CollisionRadius=10.00
    CollisionHeight=3.00
    Mass=2.00
    Buoyancy=2.50
    RotationRate=(Pitch=6000,Yaw=50000,Roll=3072),
    BindName="Angel"
    FamiliarName="Angel"
    UnfamiliarName="Dove"
	MultiSkins(0)=FireTexture'Effects.Laser.LaserBeam2'
}
