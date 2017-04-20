//================================================================================
// MiniBot.
//================================================================================
class MiniBot extends SecurityBot4;

var(bowen) Class<DeusExProjectile> LongProjectile;
var(bowen) Class<DeusExProjectile> ShortProjectile;
var(bowen) float ShortRangeValue;
var(bowen) float MedRangeValue;
var(bowen) float MinLongRange;
var(bowen) int LongShotTime;
var(bowen) int FirePitch;
var(bowen) int BulletDamage;
var(bowen) float FireOffsetX;
var(bowen) float FireOffsetZ;
var(bowen) Sound ShortFireSound;
var(bowen) bool bSentinel;
var DeusExPlayer PlayerOwner;
var int NumTries;

replication
{
	reliable if ( Role == 4 )
		CanAttack,DoSound,FireOffsetX,PlayerOwner,NumTries;
}

simulated function PostBeginPlay ()
{
	if ( Level.NetMode != 0 )
	{
		if ( PlayerOwner == None )
		{
			PlayerOwner=DeusExPlayer(Owner);
		}
		if ( bSentinel )
		{
			bInvincible=True;
			LongShotTime=5;
		}
		LongShotTime *= 2;
	}
	else
	{
		Alliance='Player';
		Orders='Following';
		AttitudeToPlayer=5;
	}
	Super.PostBeginPlay();
}

state Attacking extends Attacking
{
	simulated function bool FireIfClearShot ()
	{
		local bool bShot;
		local Vector Loc;
		local DeusExProjectile proj;
		local Vector NewOffset;
		local Vector ViewVect;
		local Rotator frot;
	
		Loc=Location;
		NumTries++;
		ViewVect=Normal(vector(Rotation));
		NewOffset=Normal(ViewVect Cross vect(0.00,0.00,1.00));
		FireOffsetX= -FireOffsetX;
		Loc += NewOffset * FireOffsetX;
		Loc.Z += FireOffsetZ;
		frot=ViewRotation;
		frot.Pitch += FirePitch;
		if ( Enemy != None )
		{
			ViewRotation=rotator(Enemy.Location - Location);
			if ( FastTrace(Location,Enemy.Location) )
			{
				if ( VSize(Location - Enemy.Location) < ShortRangeValue )
				{
					SpawnShort(Loc);
				}
				else
				{
					if ( VSize(Location - Enemy.Location) < MedRangeValue )
					{
						FireBullets(Loc);
					}
				}
				if ( (NumTries >= LongShotTime) && (VSize(Location - Enemy.Location) > MinLongRange) )
				{
					SpawnLong(Loc,frot);
				}
			}
			bShot=True;
		}
		else
		{
			Log("No Target");
			bShot=False;
		}
		return bShot;
	}
	
}

simulated function SpawnLong (Vector Loc, Rotator Rot)
{
	local DeusExProjectile proj;

	proj=Spawn(LongProjectile,PlayerOwner,,Loc,Rot);
	if ( proj != None )
	{
		proj.Target=Enemy;
		proj.bTracking=True;
	}
	NumTries=0;
}

simulated function SpawnShort (Vector startLocation)
{
	local DeusExProjectile proj;
	local Vector EndTrace;
	local Vector TargetLocation;
	local Vector TraceNormal;
	local Rotator Direction;
	local Actor Other;

	EndTrace=Location;
	EndTrace += vector(ViewRotation) * ShortRangeValue;
	Other=Trace(TargetLocation,TraceNormal,EndTrace,Location,True);
	Direction=rotator(Normal(TargetLocation - startLocation));
	if ( Other != Level )
	{
		proj=Spawn(ShortProjectile,PlayerOwner,,startLocation,Direction);
		DoSound(ShortFireSound);
	}
}

simulated function FireBullets (Vector startLocation)
{
	local Vector EndTrace;
	local Vector TargetLocation;
	local Vector TraceNormal;
	local Rotator Direction;
	local Actor Other;

	EndTrace=Location;
	EndTrace += vector(ViewRotation) * MedRangeValue;
	Other=Trace(TargetLocation,TraceNormal,EndTrace,Location,True);
	Direction=rotator(Normal(TargetLocation - startLocation));
	if ( Other != Level )
	{
		Spawn(Class'Tracer',,,startLocation,Direction);
		DoDamage(Other);
		DoSound(Sound'RobotFireGun');
	}
}

function DoDamage (Actor Other)
{
	Other.TakeDamage(BulletDamage,PlayerOwner,Location,vect(0.00,0.00,0.00),'shot');
}

simulated function DoSound (Sound SoundToPlay)
{
	PlaySound(SoundToPlay,0,,,8192.00);
}

function bool AICanShoot (Pawn Target, bool bLeadTarget, bool bCheckReadiness, optional float throwAccuracy, optional bool bDiscountMinRange)
{
	if ( Level.NetMode != 0 )
	{
		return False;
	}
	else
	{
		Super.AICanShoot(Target,bLeadTarget,bCheckReadiness,throwAccuracy,bDiscountMinRange);
	}
}

function Deactivate (DeusExPlayer deactivator)
{
	local MBDecoration MBD;

	if ( deactivator == PlayerOwner )
	{
		MBD=Spawn(Class'MBDecoration',,,Location,Rotation);
		MBD.bSpawned=True;
		MBD.HitPoints=Health;
		Destroy();
	}
}

simulated function bool CheckEnemyPresence (float DeltaSeconds, bool bCheckPlayer, bool bCheckOther)
{
	local int i;
	local int Count;
	local int checked;
	local Pawn candidate;
	local float candidateDist;
	local DeusExPlayer playerCandidate;
	local bool bCanSee;
	local int lastCycle;
	local float Visibility;
	local Pawn cycleEnemy;
	local bool bValid;
	local bool bPlayer;
	local float surpriseTime;
	local bool bValidEnemy;
	local bool bPotentialEnemy;
	local bool bCheck;

	bValid=False;
	bCanSee=False;
	if ( CanAttack(candidate) )
	{
		if ( bReactPresence && bLookingForEnemy &&  !bNoNegativeAlliances )
		{
			if ( PotentialEnemyAlliance != 'None' )
			{
				bCheck=True;
			}
			else
			{
				i=0;
JL0060:
				if ( i < 16 )
				{
					if ( (AlliancesEx[i].AllianceLevel < 0) || (AlliancesEx[i].AgitationLevel >= 1.00) )
					{
						goto JL00AC;
					}
					i++;
					goto JL0060;
				}
JL00AC:
				if ( i < 16 )
				{
					bCheck=True;
				}
			}
			if ( bCheck )
			{
				bValid=True;
				CyclePeriod += DeltaSeconds;
				Count=0;
				checked=0;
				lastCycle=cycleIndex;
				foreach UnknownFunction1002(Class'Pawn',candidate,cycleIndex)
				{
					bValidEnemy=UnknownFunction2105(candidate);
					if (  !bValidEnemy && (PotentialEnemyTimer > 0) )
					{
						if ( PotentialEnemyAlliance == candidate.Alliance )
						{
							bPotentialEnemy=True;
						}
					}
					if ( bValidEnemy || bPotentialEnemy )
					{
						Count++;
						bPlayer=candidate.IsA('PlayerPawn');
						if ( bPlayer && bCheckPlayer ||  !bPlayer && bCheckOther )
						{
							Visibility=UnknownFunction705(candidate,ComputeActorVisibility(candidate),True,True,True,True);
							if ( Visibility > 0 )
							{
								if ( bPotentialEnemy )
								{
									IncreaseAgitation(candidate,1.00);
									PotentialEnemyAlliance='None';
									PotentialEnemyTimer=0.00;
									bValidEnemy=UnknownFunction2105(candidate);
								}
								if ( bValidEnemy )
								{
									Visibility += VisibilityThreshold;
									candidateDist=VSize(Location - candidate.Location);
									if ( (CycleCandidate == None) || (CycleDistance > candidateDist) )
									{
										CycleCandidate=candidate;
										CycleDistance=candidateDist;
									}
									if (  !bPlayer )
									{
										CycleCumulative += 100000;
									}
									else
									{
										CycleCumulative += Visibility;
									}
								}
							}
						}
						if ( Count >= 1 )
						{
							goto JL02C9;
						}
					}
					checked++;
					if ( checked > 20 )
					{
						goto JL02C9;
					}
					continue;
JL02C9:
				}
				if ( lastCycle >= cycleIndex )
				{
					cycleEnemy=CheckCycle();
					if ( cycleEnemy != None )
					{
						SetDistressTimer();
						SetEnemy(cycleEnemy,0.00,True);
						bCanSee=True;
					}
				}
			}
			else
			{
				bNoNegativeAlliances=True;
			}
		}
		UpdateReactionLevel((EnemyReadiness > 0) || (GetStateName() == 'Seeking') || bDistressed,DeltaSeconds);
		if (  !bValid )
		{
			CycleCumulative=0.00;
			CyclePeriod=0.00;
			CycleCandidate=None;
			CycleDistance=0.00;
			CycleTimer=0.00;
		}
	}
	else
	{
		bCanSee=False;
	}
	return bCanSee;
}

simulated function bool CanAttack (Pawn candidate)
{
	if ( (PlayerOwner != None) && (candidate != None) )
	{
		if ( candidate.IsA('DeusExPlayer') )
		{
			if ( TeamDMGame(PlayerOwner.DXGame) != None )
			{
				if ( DeusExPlayer(candidate).PlayerReplicationInfo.Team == PlayerOwner.PlayerReplicationInfo.Team )
				{
					Enemy=None;
					return False;
				}
			}
			else
			{
				if ( candidate == PlayerOwner )
				{
					Enemy=None;
					return False;
				}
			}
		}
	}
	return True;
}

simulated function bool SetEnemy (Pawn newEnemy, optional float newSeenTime, optional bool bForce)
{
	local bool bValid;

	if (  !CanAttack(newEnemy) )
	{
		Enemy=None;
		return False;
	}
	else
	{
		if ( bForce || UnknownFunction2105(newEnemy) )
		{
			if ( newEnemy != Enemy )
			{
				EnemyTimer=0.00;
			}
			Enemy=newEnemy;
			EnemyLastSeen=newSeenTime;
			bValid=True;
		}
		else
		{
			bValid=False;
		}
		if (  !CanAttack(newEnemy) )
		{
			Enemy=None;
			bValid=False;
			return False;
		}
	}
	return bValid;
}

defaultproperties
{
    ShortRangeValue=300.00
    MedRangeValue=1750.00
    MinLongRange=1000.00
    LongShotTime=25
    FirePitch=2730
    BulletDamage=5
    FireOffsetX=25.00
    FireOffsetZ=-25.00
    ShortFireSound=Sound'DeusExSounds.Weapons.FlamethrowerFire'
    EMPHitPoints=500000
    bHateHacking=True
    bHateWeapon=True
    bHateShot=True
    bHateIndirectInjury=True
    bHateDistress=True
    bReactFutz=True
    bReactLoudNoise=True
    bReactShot=True
    bReactCarcass=True
    bReactDistress=True
    bReactProjectiles=True
    InitialAlliances(0)=~  €¿ 
    InitialAlliances(1)=R  €¿ 
    InitialAlliances(2)=Q  €¿ 
    InitialAlliances(3)=   €¿ 
    InitialAlliances(4)=G     
    InitialAlliances(5)=>  €¿ 
    bTickVisibleOnly=False
    InitialInventory(0)=    
    InitialInventory(1)= 2   
    SightRadius=250000.00
    Health=5000
    AttitudeToPlayer=1
    Intelligence=3
    HealthHead=5000
    HealthTorso=5000
    HealthLegLeft=5000
    HealthLegRight=5000
    HealthArmLeft=5000
    HealthArmRight=5000
    AIHorizontalFov=360.00
    Alliance=BowenBot
    bAlwaysRelevant=True
    bBlockActors=False
    FamiliarName=""
    UnfamiliarName=""
}