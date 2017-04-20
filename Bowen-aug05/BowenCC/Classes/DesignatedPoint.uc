//=============================================================================
// DesignatedPoint.	(c) 2003 JimBowen
//=============================================================================
class DesignatedPoint expands BowenBasicActor2;

var (Bowen) float maxHeight;
var (Bowen) sound LockedSound, ChargedSound, ChargingSound, FireSound, WarmupSound;
var (Bowen) float ChargeTime, LockTime, FireTime, ChargeRingTime;
var (Bowen) Texture ChargeRingTex, SkySpriteTex, SkySpriteTex2, CentreLockRingTex, OuterLockRingTex;
var bool bLocked, bCharged;
var BowenSpriteFlat Centre, Outer;
var int i;

var (bowen) string MsgSeen, MsgLocked, MsgFiring, MsgNoSky;
/*
replication
{
	reliable if (Role == ROLE_Authority)
		SpawnLockedEffects;
}
*/
simulated function tick (float deltatime)
{
	Local ShockRing ChargeRing;	
	local vector loc;
		
		loc = Location + vector(Rotation);
		if(!bLocked && !bCharged)
		{
			LockTime -= DeltaTime;
			if (LockTime <= 0)
			{
				bLocked = True;
				PlaySimSound (LockedSound, SLOT_None, TransientSoundVolume, 2048);
				Centre = Spawn(class'BowenSpriteFlat',,,(Loc + vector(Rotation)),Rotation);
				Outer = Spawn(class'BowenSpriteFlat',,,Loc,Rotation);
				Centre.bRotate = True;
				Centre.RotationSpeed = 60;
				Centre.Skin = CentreLockRingTex;
				Outer.bRotate = True;
				Outer.RotationSpeed = -60;
				Outer.Skin = OuterLockRingTex;
				PlayerPawn(Owner).ClientMessage(MsgLocked);
			}
			
			ChargeRingTime -= DeltaTime;
			if(ChargeRingTime <= 0)
			{
				ChargeRingTime = Default.ChargeRingTime;
				ChargeRing = Spawn(class'ShockRing',,, Loc, Rotation);
					ChargeRing.Skin = ChargeRingTex;
				PlaySimSound(ChargingSound, SLOT_None, TransientSoundVolume, 2048);
			}
			
		}
		
		if(bLocked && !bCharged)
		{
			ChargeTime -= DeltaTime;
			if (ChargeTime <= 0)
			{
				ChargeTime = Default.ChargeTime;
				bCharged = True;
				PlaySimSound (ChargedSound, SLOT_None, TransientSoundVolume, 2048);
				PlayerPawn(Owner).ClientMessage(MsgFiring);
				GoToState('Firing');
			}
		}	
		
		
		
}


// ----------------------------------------------------------------------
// GetRoofMaterial()
//
// gets the name of the texture group thats above us
// ----------------------------------------------------------------------

simulated function name GetRoofMaterial(out vector RoofNormal)
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;

	// trace out in front of us
	EndTrace = Location + (Vect(0,0,1) * maxHeight);

 	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
			break;
	}

	RoofNormal = HitNormal;
//	log("Tex name = " @ TexName);
//	log("Tex group = " @ TexGroup);
//	log("Tex flags = " @ TexFlags);
	return texGroup;
}

simulated function PostBeginPlay()
{
	local vector RoofNormal;
	local name RoofMaterial;
	local TeleportInhibitor Inhibitor;
	
		RoofMaterial = GetRoofMaterial(RoofNormal);
		
		if(RoofMaterial == 'CoreTexSky' || RoofMaterial == 'CoreTexMisc' || RoofMaterial == 'Sky')
		{
			log ("Accepted - " @ RoofMaterial);
			PlayerPawn(Owner).ClientMessage(MsgSeen);
			SpawnLockedEffects();
			Inhibitor = Spawn(class'TeleportInhibitor',,,Location);
			Inhibitor.LifeSpan = ChargeTime + LockTime + FireTime + 15;
			Inhibitor.EffectRadius = 3000;
			Inhibitor = Spawn(class'TeleportInhibitor',,,Location);
			Inhibitor.LifeSpan = ChargeTime + LockTime + FireTime + 15;
			Inhibitor.EffectRadius = 1000;
			Inhibitor.bNoLOS = True;
		}
		else
		{
			if (Role == ROLE_Authority)
				Pawn(Owner).ClientMessage(MsgNoSky);
			log ("Not SkyBox - " @ RoofMaterial);

			if (Level.NetMode == NM_StandAlone && DeusExPlayer(Owner) != None)
				if(DeusExPlayer(Owner).bAdmin)
					return;
			Destroy();
		}
}

simulated function SpawnLockedEffects()
{
	local ParticleGenerator FlareGen;
		FlareGen = Spawn(class'ParticleGenerator',,,(Location + vect(0,0,3)),Rotator(vect(0,0,1)));
			if (FlareGen != None)
			{
				FlareGen.particleTexture = Texture'Effects.laser.LaserSpot1';
				FlareGen.particleDrawScale = 2;
				FlareGen.bRandomEject = True;
				FlareGen.ejectSpeed = 1000.0;
				FlareGen.bGravity = True;
				FlareGen.bParticlesUnlit = True;
				FlareGen.frequency = 3;
				FlareGen.riseRate = 10;
				FlareGen.spawnSound = Sound'Spark2';
				FlareGen.LifeSpan = 2;
				FlareGen.Checktime = 0;
			}

}

simulated function int PlaySimSound( Sound snd, ESoundSlot Slot, float Volume, float Radius )
{
	if ( Owner != None )
	{
		if ( Level.NetMode == NM_Standalone )
			return ( Owner.PlaySound( snd, Slot, Volume, , Radius ) );
		else
		{
			Owner.PlayOwnedSound( snd, Slot, Volume, , Radius );
			return 1;
		}
	}
	return 0;
}


simulated state Firing
{
	function tick(float deltatime)
	{
	}
	
	begin:
	PlaySimSound(WarmupSound, SLOT_None, TransientSoundVolume, 2048);
	SpawnSkyboxSprite();
	sleep(FireTime/2);
	for (i=0;i<40;i++)
	{
		SpawnPlasma();
		Sleep(0.25);
	}
	if(Centre != None)
		Centre.Destroy();
	if(Outer != None)
		Outer.Destroy();
	Destroy();
}

simulated function SpawnSkyboxSprite()
{
	local SkyZoneInfo Sky;
	local SphereEffect Sph;
	local NukeSphere Nuke;
	local AnimatedSprite spri;
	
		foreach allactors (class'SkyZoneInfo', Sky)
			if (Sky != None)
			{
				Sph = Spawn(class'SphereEffect',,,Sky.Location);
					Sph.Skin = SkySpriteTex;
					Sph.Size = 3;
					Sph.lifeSpan = 15;
					Sph.bAlwaysRelevant = True;
					
				Nuke = Spawn(class'NukeSphere',,,Sky.Location);
					Nuke.Skin = SkySpriteTex2;
					Nuke.lifeSpan = 15;
					Nuke.bAlwaysRelevant = True;
			}
}

simulated function SpawnPlasma()
{
	local vector StartTrace, EndTrace, HitNormal, Direction, Start, HitLocation;
	local actor Other;
	local OsirisPlasmaBall Ball;

		Start = Location;
		StartTrace = Start;
		EndTrace = Start;
		EndTrace += vect(0,0,1)*MaxHeight;
		Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	
		Ball = Spawn(class'OsirisPlasmaBall',Owner,,HitLocation,rotator(vect(0,0,-1)));
		if(i == 0)
			Ball.bDamageSpawner = True;
}

//---END-CLASS---

defaultproperties
{
     maxHeight=65536.000000
     ChargeTime=10.000000
     LockTime=5.000000
     fireTime=5.000000
     ChargeRingTime=2.000000
     ChargeRingTex=Texture'DeusExItems.Skins.FlatFXTex43'
     SkySpriteTex2=Texture'Extension.CheckboxOff'
     MsgSeen="|p2Osiris satellite has seen the target, and is turning to position."
     msgLocked="|p2Osiris satellite is in position and initialising weapon systems."
     MsgFiring="|p2Osiris satellite is firing a plasma stream at the target."
     MsgNoSky="|p2Point untargettable. No sky above designated point."
     bHidden=True
     bAlwaysRelevant=True
}
