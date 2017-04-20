//================================================================================
// GODZTurret.
//================================================================================
class GODZTurret extends DeusExDecoration;

var AutoTurretGun gun;
var() localized string titleString;
var() bool bTrackPawnsOnly;
var() bool bTrackPlayersOnly;
var() bool bActive;
var() int maxRange;
var() float fireRate;
var() float gunAccuracy;
var() int gunDamage;
var() int AmmoAmount;
var Actor curTarget;
var Actor prevTarget;
var Pawn safeTarget;
var float FireTimer;
var bool bConfused;
var float confusionTimer;
var float confusionDuration;
var Actor LastTarget;
var float pitchLimit;
var Rotator origRot;
var bool bPreAlarmActiveState;
var bool bDisabled;
var float TargetRefreshTime;
var int Team;
var int mpTurretDamage;
var int mpTurretRange;
var bool bComputerReset;
var bool bSwitching;
var float SwitchTime;
var float beepTime;
var Pawn savedTarget;

replication
{
	un?reliable if ( Role == 4 )
		titleString,bActive,safeTarget,bDisabled,Team;
}

function Actor AcquireMultiplayerTarget ()
{
	local Pawn aPawn;
	local DeusExPlayer aPlayer;
	local Vector dist;
	local Actor noActor;

	if ( bSwitching )
	{
		noActor=None;
		return noActor;
	}
	if ( (prevTarget != None) && (prevTarget != safeTarget) && (Pawn(prevTarget) != None) )
	{
		if ( Pawn(prevTarget).UnknownFunction705(self,1.00,False,False,False,True) > 0 )
		{
			if ( (DeusExPlayer(prevTarget) == None) &&  !DeusExPlayer(prevTarget).bHidden )
			{
				dist=DeusExPlayer(prevTarget).Location - gun.Location;
				if ( VSize(dist) < maxRange )
				{
					curTarget=prevTarget;
					return curTarget;
				}
			}
			else
			{
				dist=DeusExPlayer(prevTarget).Location - gun.Location;
				if ( VSize(dist) < maxRange )
				{
					curTarget=prevTarget;
					return curTarget;
				}
			}
		}
	}
	aPawn=gun.Level.PawnList;
JL0149:
	if ( aPawn != None )
	{
		if ( aPawn.bDetectable &&  !aPawn.bIgnore && aPawn.IsA('DeusExPlayer') )
		{
			aPlayer=DeusExPlayer(aPawn);
			dist=aPlayer.Location - gun.Location;
			if ( VSize(dist) < maxRange )
			{
				if ( aPlayer.FastTrace(aPlayer.Location,gun.Location) )
				{
					if ( (aPlayer.Alliance != 'GODZ') && (aPlayer != prevTarget) )
					{
						if ( aPawn.Alliance == 'GODZ' )
						{
							goto JL027F;
						}
						curTarget=aPawn;
						PlaySound(Sound'TurretLocked',3,1.00,,maxRange);
					}
					else
					{
						aPawn=aPawn.nextPawn;
JL027F:
						goto JL0149;
					}
				}
			}
		}
	}
	return curTarget;
}

function Tick (float DeltaTime)
{
	local Pawn Pawn;
	local ScriptedPawn SP;
	local DeusExDecoration deco;
	local float near;
	local Rotator destRot;
	local bool bSwitched;

	Super.Tick(DeltaTime);
	if ( bActive &&  !bDisabled )
	{
		curTarget=None;
		if (  !bConfused )
		{
			if ( (Level.NetMode != 0) && (Role == 4) )
			{
				if ( TargetRefreshTime < 0 )
				{
					TargetRefreshTime=0.00;
				}
				TargetRefreshTime=TargetRefreshTime + DeltaTime;
				if ( TargetRefreshTime >= 0.30 )
				{
					TargetRefreshTime=0.00;
					curTarget=AcquireMultiplayerTarget();
					if ( (curTarget != prevTarget) && (curTarget == None) )
					{
						PlaySound(Sound'TurretUnlocked',3,1.00,,maxRange);
					}
					prevTarget=curTarget;
				}
				else
				{
					curTarget=prevTarget;
				}
			}
			else
			{
				if ( bTrackPlayersOnly ||  !bTrackPlayersOnly &&  !bTrackPawnsOnly )
				{
					foreach gun.VisibleActors(Class'Pawn',Pawn,maxRange,gun.Location)
					{
						if ( Pawn.bDetectable &&  !Pawn.bIgnore )
						{
							if ( Pawn.IsA('DeusExPlayer') )
							{
								if ( DeusExPlayer(Pawn).AugmentationSystem.GetAugLevelValue(Class'AugRadarTrans') == -1.00 )
								{
									curTarget=Pawn;
								}
								else
								{
									goto JL0201;
									if ( Pawn.IsA('ScriptedPawn') && (ScriptedPawn(Pawn).UnknownFunction2107(UnknownFunction720()) != 2) )
									{
										curTarget=Pawn;
									}
									else
									{
JL0201:
										continue;
									}
								}
							}
						}
					}
				}
				if (  !bTrackPlayersOnly )
				{
					if (  !bTrackPawnsOnly )
					{
						foreach gun.VisibleActors(Class'DeusExDecoration',deco,maxRange,gun.Location)
						{
							if (  !deco.IsA('ElectronicDevices') &&  !deco.IsA('AutoTurret') &&  !deco.bInvincible && deco.bDetectable &&  !deco.bIgnore )
							{
								curTarget=deco;
							}
							else
							{
								continue;
							}
						}
					}
					foreach gun.VisibleActors(Class'ScriptedPawn',SP,maxRange,gun.Location)
					{
						if ( SP.bDetectable &&  !SP.bIgnore && (SP.UnknownFunction2107(UnknownFunction720()) == 2) )
						{
							curTarget=SP;
						}
						else
						{
							continue;
						}
					}
				}
			}
			if ( curTarget != None )
			{
				destRot=rotator(curTarget.Location - gun.Location);
				gun.DesiredRotation=destRot;
				near=pitchLimit / 2;
				gun.DesiredRotation.Pitch=FClamp(gun.DesiredRotation.Pitch,origRot.Pitch - near,origRot.Pitch + near);
			}
			else
			{
				gun.DesiredRotation=origRot;
			}
		}
	}
	else
	{
		if (  !bConfused )
		{
			gun.DesiredRotation=origRot;
		}
	}
	near=Abs(gun.Rotation.Pitch - gun.DesiredRotation.Pitch) % 65536;
	near += Abs(gun.Rotation.Yaw - gun.DesiredRotation.Yaw) % 65536;
	if ( bActive &&  !bDisabled )
	{
		if ( (curTarget != None) && (curTarget != LastTarget) )
		{
			PlaySound(Sound'Beep6',,,,1280.00);
		}
		if ( curTarget != None )
		{
			gun.MultiSkins[1]=Texture'RedLightTex';
			if ( (near < 4096) && (Abs(gun.Rotation.Pitch - destRot.Pitch) % 65536 < 8192) )
			{
				if ( FireTimer > fireRate )
				{
					Fire();
					FireTimer=0.00;
				}
			}
		}
		else
		{
			if ( gun.IsAnimating() )
			{
				gun.PlayAnim('Still',10.00,0.00);
			}
			if ( bConfused )
			{
				gun.MultiSkins[1]=Texture'YellowLightTex';
			}
			else
			{
				gun.MultiSkins[1]=Texture'GreenLightTex';
			}
		}
		FireTimer += DeltaTime;
		LastTarget=curTarget;
	}
	else
	{
		if ( gun.IsAnimating() )
		{
			gun.PlayAnim('Still',10.00,0.00);
		}
		gun.MultiSkins[1]=None;
	}
	if ( near > 64 )
	{
		gun.AmbientSound=Sound'AutoTurretMove';
		if ( bConfused )
		{
			gun.SoundPitch=128;
		}
		else
		{
			gun.SoundPitch=64;
		}
	}
	else
	{
		gun.AmbientSound=None;
	}
}

auto state Active extends Active
{
	function TakeDamage (int Damage, Pawn EventInstigator, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
}

function Fire ()
{
	local Vector HitLocation;
	local Vector HitNormal;
	local Vector StartTrace;
	local Vector EndTrace;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local Rotator Rot;
	local Actor hit;
	local ShellCasing shell;
	local Spark Spark;
	local Pawn attacker;

	if (  !gun.IsAnimating() )
	{
		gun.LoopAnim('Fire');
	}
	GetAxes(gun.Rotation,X,Y,Z);
	StartTrace=gun.Location;
	EndTrace=StartTrace + gunAccuracy * (FRand() - 0.50) * Y * 1000 + gunAccuracy * (FRand() - 0.50) * Z * 1000;
	EndTrace += 10000 * X;
	hit=Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	if ( (DeusExMPGame(Level.Game) != None) &&  !DeusExMPGame(Level.Game).bSpawnEffects )
	{
		shell=None;
	}
	else
	{
		shell=Spawn(Class'ShellCasing',,,gun.Location);
	}
	if ( shell != None )
	{
		shell.Velocity=vector((gun.Rotation - rot(0,16384,0))) * 100 + VRand() * 30;
	}
	MakeNoise(1.00);
	PlaySound(Sound'PistolFire',0);
	UnknownFunction713('LoudNoise',1);
	gun.LightType=1;
	gun.MultiSkins[2]=Texture'FlatFXTex34';
	SetTimer(0.10,False);
	if ( FRand() < 0.50 )
	{
		if ( VSize(HitLocation - StartTrace) > 250 )
		{
			Rot=rotator(EndTrace - StartTrace);
			Spawn(Class'Tracer',,,StartTrace + 96 * vector(Rot),Rot);
		}
	}
	if ( hit != None )
	{
		if ( (DeusExMPGame(Level.Game) != None) &&  !DeusExMPGame(Level.Game).bSpawnEffects )
		{
			Spark=None;
		}
		else
		{
			Spark=Spawn(Class'Spark',,,HitLocation + HitNormal,rotator(HitNormal));
		}
		if ( Spark != None )
		{
			Spark.DrawScale=0.05;
			PlayHitSound(Spark,hit);
		}
		attacker=None;
		if ( (curTarget == hit) &&  !curTarget.IsA('PlayerPawn') )
		{
			attacker=UnknownFunction720();
		}
		if ( Level.NetMode != 0 )
		{
			attacker=safeTarget;
		}
		if ( hit.IsA('DeusExPlayer') && (Level.NetMode != 0) )
		{
			DeusExPlayer(hit).myTurretKiller=self;
		}
		hit.TakeDamage(gunDamage,attacker,HitLocation,1000.00 * X,'AutoShot');
		if ( hit.IsA('Pawn') &&  !hit.IsA('Robot') )
		{
			SpawnBlood(HitLocation,HitNormal);
		}
		else
		{
			if ( (hit == Level) || hit.IsA('Mover') )
			{
				SpawnEffects(HitLocation,HitNormal,hit);
			}
		}
	}
}

function SpawnBlood (Vector HitLocation, Vector HitNormal)
{
	local Rotator Rot;

	Rot=rotator(Location - HitLocation);
	Rot.Pitch=0;
	Rot.Roll=0;
	if ( (DeusExMPGame(Level.Game) != None) &&  !DeusExMPGame(Level.Game).bSpawnEffects )
	{
		return;
	}
	Spawn(Class'BloodSpurt',,,HitLocation + HitNormal,Rot);
	Spawn(Class'BloodDrop',,,HitLocation + HitNormal);
	if ( FRand() < 0.50 )
	{
		Spawn(Class'BloodDrop',,,HitLocation + HitNormal);
	}
}

simulated function SpawnEffects (Vector HitLocation, Vector HitNormal, Actor Other)
{
	local SmokeTrail Puff;
	local int i;
	local BulletHole hole;
	local Rotator Rot;

	if ( (DeusExMPGame(Level.Game) != None) &&  !DeusExMPGame(Level.Game).bSpawnEffects )
	{
		return;
	}
	if ( FRand() < 0.50 )
	{
		Puff=Spawn(Class'SmokeTrail',,,HitLocation + HitNormal,rotator(HitNormal));
		if ( Puff != None )
		{
			Puff.DrawScale *= 0.30;
			Puff.OrigScale=Puff.DrawScale;
			Puff.LifeSpan=0.25;
			Puff.OrigLifeSpan=Puff.LifeSpan;
		}
	}
	if (  !Other.IsA('BreakableGlass') )
	{
		i=0;
JL00F8:
		if ( i < 2 )
		{
			if ( FRand() < 0.80 )
			{
				Spawn(Class'Rockchip',,,HitLocation + HitNormal);
			}
			i++;
			goto JL00F8;
		}
	}
	hole=Spawn(Class'BulletHole',Other,,HitLocation,rotator(HitNormal));
	if ( GetWallMaterial(HitLocation,HitNormal) == 'Glass' )
	{
		if ( FRand() < 0.50 )
		{
			hole.Texture=Texture'FlatFXTex29';
		}
		else
		{
			hole.Texture=Texture'FlatFXTex30';
		}
		hole.DrawScale=0.10;
		hole.ReattachDecal();
	}
}

function name GetWallMaterial (Vector HitLocation, Vector HitNormal)
{
	local Vector EndTrace;
	local Vector StartTrace;
	local Actor NewTarget;
	local int texFlags;
	local name texName;
	local name texGroup;

	StartTrace=HitLocation + HitNormal * 16;
	EndTrace=HitLocation - HitNormal;
	foreach UnknownFunction1000(Class'Actor',NewTarget,texName,texGroup,texFlags,StartTrace,HitNormal,EndTrace)
	{
		if ( (NewTarget == Level) || NewTarget.IsA('Mover') )
		{
			goto JL0080;
		}
		continue;
JL0080:
	}
	return texGroup;
}

function PlayHitSound (Actor destActor, Actor HitActor)
{
	local float rnd;
	local Sound snd;

	rnd=FRand();
	if ( rnd < 0.25 )
	{
		snd=Sound'Ricochet1';
	}
	else
	{
		if ( rnd < 0.50 )
		{
			snd=Sound'Ricochet2';
		}
		else
		{
			if ( rnd < 0.75 )
			{
				snd=Sound'Ricochet3';
			}
			else
			{
				snd=Sound'Ricochet4';
			}
		}
	}
	if ( HitActor != None )
	{
		if ( HitActor.IsA('DeusExDecoration') && (DeusExDecoration(HitActor).minDamageThreshold > 10) )
		{
			snd=Sound'ArmorRicochet';
		}
		else
		{
			if ( HitActor.IsA('Robot') )
			{
				snd=Sound'ArmorRicochet';
			}
		}
	}
	if ( destActor != None )
	{
		destActor.PlaySound(snd,0,,,1024.00,1.10 - 0.20 * FRand());
	}
}

simulated function Timer ()
{
	gun.LightType=0;
	gun.MultiSkins[2]=None;
}

function AlarmHeard (name Event, EAIEventState State, XAIParams params)
{
	if ( State == 0 )
	{
		if (  !bActive )
		{
			bPreAlarmActiveState=bActive;
			bActive=True;
		}
	}
	else
	{
		if ( State == 1 )
		{
			if ( bActive )
			{
				bActive=bPreAlarmActiveState;
			}
		}
	}
}

function PreBeginPlay ()
{
	local Vector v1;
	local Vector v2;
	local Class<AutoTurretGun> gunClass;
	local Rotator Rot;

	Super.PreBeginPlay();
	gunClass=Class'GODZTurretGun';
	Rot=Rotation;
	Rot.Pitch=0;
	Rot.Roll=0;
	origRot=Rot;
	gun=Spawn(gunClass,self,,Location,Rot);
	if ( gun != None )
	{
		v1.X=0.00;
		v1.Y=0.00;
		v1.Z=CollisionHeight + gun.Default.CollisionHeight;
		v2=v1 >> Rotation;
		v2 += Location;
		gun.SetLocation(v2);
		gun.SetBase(self);
	}
	UnknownFunction710('alarm','AlarmHeard');
	if ( Level.NetMode != 0 )
	{
		maxRange=mpTurretRange;
		gunDamage=mpTurretDamage;
		bInvincible=True;
		bDisabled= !bActive;
	}
}

function PostBeginPlay ()
{
	safeTarget=None;
	prevTarget=None;
	TargetRefreshTime=0.00;
	Super.PostBeginPlay();
}

defaultproperties
{
    titleString="GODZ Turret"
    bTrackPlayersOnly=True
    bActive=True
    maxRange=2048
    fireRate=0.05
    gunAccuracy=1.00
    gunDamage=5
    AmmoAmount=1000
    confusionDuration=10.00
    pitchLimit=11000.00
    Team=-1
    mpTurretDamage=20
    mpTurretRange=1024
    HitPoints=50
    minDamageThreshold=50
    bHighlight=False
    ItemName="Turret Base"
    bPushable=False
    Physics=0
    Mesh=LodMesh'DeusExDeco.AutoTurretBase'
    SoundRadius=48
    SoundVolume=192
    AmbientSound=Sound'DeusExSounds.Generic.AutoTurretHum'
    CollisionRadius=14.00
    CollisionHeight=20.20
    Mass=50.00
    Buoyancy=10.00
    bVisionImportant=True
}