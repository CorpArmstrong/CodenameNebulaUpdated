//-----------------------------------------------------------
// CNNMilitary - just like HumanMilitary
//-----------------------------------------------------------
class CNNMilitary extends ScriptedPawn abstract;

function PostBeginPlay()
{
    super.PostBeginPlay();

    // change the sounds for chicks
    if (bIsFemale)
    {
        HitSound1 = Sound'FemalePainMedium';
        HitSound2 = Sound'FemalePainLarge';
        Die = Sound'FemaleDeath';
    }
}

function bool WillTakeStompDamage(actor stomper)
{
    return !(stomper.IsA('PlayerPawn') && (GetPawnAllianceType(Pawn(stomper)) != ALLIANCE_Hostile));
}

defaultproperties
{
    BaseAccuracy=0.200000
    maxRange=1000.000000
    MinHealth=20.000000
    bPlayIdle=true
    bCanCrouch=true
    bSprint=True
    CrouchRate=1.000000
    SprintRate=1.000000
    bReactAlarm=true
    EnemyTimeout=5.000000
    bCanTurnHead=true
    WaterSpeed=80.000000
    AirSpeed=160.000000
    AccelRate=500.000000
    BaseEyeHeight=40.000000
    UnderWaterTime=20.000000
    AttitudeToPlayer=ATTITUDE_Ignore
    HitSound1=Sound'DeusExSounds.Player.MalePainSmall'
    HitSound2=Sound'DeusExSounds.Player.MalePainMedium'
    Die=Sound'DeusExSounds.Player.MaleDeath'
    VisibilityThreshold=0.010000
    DrawType=DT_Mesh
    Mass=150.000000
    Buoyancy=155.000000
    BindName="HumanMilitary"
}
