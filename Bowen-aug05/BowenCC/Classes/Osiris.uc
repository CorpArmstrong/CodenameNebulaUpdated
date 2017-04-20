//=============================================================================
// Osiris.	(c) 2003 JimBowen
//=============================================================================
class Osiris expands BowenWeapon;

var (Bowen) float LockTolerance;
var (Bowen) float CheckTime, SatLockTime, SpriteWallOut;
var (Bowen) int NumConfirmRings;
var (Bowen) Texture LockRingTex, LaserTex;
var bool bUsed, bSecondTry;
var BowenSpriteBeam SPR;
var vector LastSpriteLoc, NewSpriteLoc;
var rotator NewSpriteRot;
var float StationaryTime, FireValue;
var actor OrigOwner;

replication
{
	reliable if (Role == ROLE_Authority)
		SPR, NewSpriteLoc, NewSpriteRot;
}

simulated function bool CheckTexture()
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;

	// trace out in front of us
	EndTrace = Location + (Vector(Pawn(Owner).ViewRotation * maxRange));

 	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
			break;
	}
	
//	log("Tex name = " @ TexName);
//	log("Tex group = " @ TexGroup);
//	log("Tex flags = " @ TexFlags);

	if(TexGroup == 'CoreTexSky' || TexGroup == 'CoreTexMisc' || TexGroup == 'Sky')
		return False;
	else return True;
	
}


simulated function tick (float deltatime)
{
	local actor Other;

	Super.Tick(DeltaTime);

		if (Owner == None)	
			return;
		
		if (bUsed)
			CalcSpriteLocation(NewSpriteLoc, NewSpriteRot);
		
		if (bUsed && SPR != None)
		{	
			UpdateSpriteLocation();
			if (CheckTime >= Default.CheckTime) 
			{
				LastSpriteLoc = NewSpriteLoc;
				CheckTime = 0;
			}
			
			CheckTime += deltatime;
			
			if ((VSize(LastSpriteLoc - NewSpriteLoc) <= LockTolerance) && CheckTexture())
				StationaryTime += deltatime;
			else if (StationaryTime > 0) 
				StationaryTime -= 2*deltatime;			
			
			if (StationaryTime >= SatLockTime)
			{
				SpawnThingy();
				PlayAnim('Shoot2',,0.1);
				LifeSpan = 1.0;
			//	Super.Fire(FireValue);
			}
		}
}

simulated function UpdateSpriteLocation()
{
	SPR.SetLocation(NewSpriteLoc);
	SPR.SetRotation(NewSpriteRot);
}

simulated function SpawnThingy()
{
	StationaryTime = 0;
	SpawnRings(NewSpriteLoc, NewSpriteRot);
	Spawn(class'DesignatedPoint',Owner,, SPR.Location, SPR.Rotation);
	PlaySimSound (LockedSound, SLOT_None, TransientSoundVolume, 2048);
	SPR.LifeSpan = 1.5;
	Destroy();	//hack to stop hundreds of osiris balls bug
}

function fire(float value)
{	
	if (Level.NetMode == NM_Standalone || bSecondTry)
	{
		FireValue = Value;
		
		ToggleLaser();
	}
	OrigOwner = Owner;
	bSecondTry = !bSecondTry;
	log ("Osiris:" @ bSecondTry);
	PlayAnim('Shoot',,0.1);
}

simulated function ToggleLaser()
{
		if (!bUsed && pawn(Owner) != None)		
		{
			SpawnSprite();
			bUsed = True;	
			PlaySimSound (FireSound, SLOT_None, TransientSoundVolume, 2048);
			Return;
		}
		else if (bUsed && pawn(Owner) != None)
		{
			SPR.Destroy();
			bUsed = False;
			StationaryTime = 0;
			CheckTime = Default.CheckTime;
			if (Role == ROLE_Authority)
				DeusExPlayer(owner).ClientMessage("Cancelled");
			Return;
		}
}

simulated function CalcSpriteLocation(out vector SpriteLoc, optional out rotator SpriteRot)
{
	local vector StartTrace, EndTrace, TraceNormal, Direction, Start, TargetLocation;
	local actor Other;
	
		if (Owner != None)
		{
			Start = Location;
			Start.Z += Owner.CollisionHeight;
			StartTrace = Start;
			EndTrace = Start;
			EndTrace += vector(Pawn(Owner).ViewRotation)*MaxRange;
			Other = Owner.Trace(TargetLocation,TraceNormal,EndTrace,StartTrace,True);
			SpriteLoc = TargetLocation + (SpriteWallOut*TraceNormal);
		}
		
		SpriteRot = rotator(TraceNormal);
	
}

simulated function SpawnSprite()
{
	local rotator SpriteRot;
	local vector SpriteLoc;
	
		CalcSpriteLocation(SpriteLoc, SpriteRot);
		SPR = Spawn(class'BowenSpriteBeam',Owner,, spriteloc, spriterot);
		if (SPR != None)
		{
			SPR.Texture = LaserTex;
			SPR.DrawScale = 1;
			SPR.LifeSpan = 5;
		}
}

function Destroyed()
{
	local Osiris o;

	if (Level.NetMode == NM_StandAlone && DeusExPlayer(OrigOwner) != None)
	{
		if(DeusExPlayer(OrigOwner).bAdmin)
		{
			o = spawn(class'Osiris',,,OrigOwner.Location);
			//o.Frob(OrigOwner, None);
		}
	}
	Super.Destroyed();
}

simulated function SpawnRings(vector spawnloc, rotator spawnrot)
{
	local ShockRing ring;
	local int i;
	
		for( i=0; i<NumConfirmRings; i++ )
		{
			ring = Spawn(class'ShockRing',Owner,, spawnloc, spawnrot);
			if (ring != None)
			{
				ring.Skin = LockRingTex;
				ring.Size = i;
			}
		}
}

function PostBeginPlay()
{
   Super.PostBeginPlay();
   bWeaponStay=False;
}

state idle
{
	function bool PutDown()
	{
		bUsed=False;
		Super.PutDown();
	}
}

// Muzzle Flash Stuff
// called from the mesh NOTIFY Copied from DeusexWeapons.uc and modified...
//
// Effect used - Effects.Electricity.LaserSpot1
//
simulated function SwapMuzzleFlashTexture()
{
     if (!bHasMuzzleFlash)
     return;
     if (FRand() < 0.5)
         MultiSkins[5] = Texture'BeamTex';
         MultiSkins[4] = Texture'RedLightTex';

     MuzzleFlashLight();
     SetTimer(0.6, False);
}

simulated function EraseMuzzleFlashTexture()
{
     MultiSkins[5] = None;
}

simulated function Timer()
{
     EraseMuzzleFlashTexture();
}

simulated function MuzzleFlashLight()
{
     local Vector offset, X, Y, Z;
     local Effects flash;

      if (!bHasMuzzleFlash)
          return;

     if ((flash != None) && !flash.bDeleteMe)
          flash.LifeSpan = flash.Default.LifeSpan;
     else
     {
          GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
          offset = Owner.Location;
          offset += X * Owner.CollisionRadius * 2;
          flash = spawn(class'Muzzleflash',,, offset);
          if (flash != None)
               flash.SetBase(Owner);
     }
}


//---END-CLASS---

defaultproperties
{
     LockTolerance=30.000000
     checkTime=0.500000
     SatLockTime=0.500000
     SpriteWallOut=5.000000
     NumConfirmRings=5
     LockRingTex=Texture'DeusExItems.Skins.FlatFXTex43'
     LaserTex=Texture'DeusExDeco.Skins.AlarmLightTex2'
     BowenPickupMessage="|P2Hold the spot in the same place for a while to designate a target."
     LowAmmoWaterMark=0
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     NoiseLevel=0.010000
     Concealability=CONC_All
     ShotTime=0.300000
     reloadTime=0.000000
     HitDamage=25
     maxRange=24000
     AccurateRange=14400
     BaseAccuracy=0.000000
     LockedSound=Sound'DeusExSounds.Generic.Beep2'
     bHasMuzzleFlash=False
     bEmitWeaponDrawn=False
     bUseAsDrawnWeapon=False
     AmmoName=Class'DeusEx.AmmoNone'
     ReloadCount=0
     FireOffset=(X=-20.000000,Y=10.000000,Z=16.000000)
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.HideAGunSelect'
     ItemName="Osiris sattelite laser designator"
     RespawnTime=240.000000
     PlayerViewOffset=(X=20.000000,Y=-10.000000,Z=-16.000000)
     PlayerViewMesh=LodMesh'BowenCust.JBWeaponOsiris'
     PlayerViewScale=2.500000
     PickupViewMesh=LodMesh'BowenCust.OsirisPickup'
     ThirdPersonMesh=LodMesh'BowenCust.Osiris3rd'
     ThirdPersonScale=0.500000
     Icon=Texture'BowenCust.Icons.BeltIconOsiris'
     largeIcon=Texture'BowenCust.Icons.LargeIconOsiris'
     largeIconWidth=43
     largeIconHeight=21
     Description="A single-use laser designator unit for the BowenCo Osiris orbital plasma cannon. Point at tatget, and hold in position until locked. Mesh by Phasmatis."
     beltDescription="Osiris"
     Mesh=LodMesh'BowenCust.OsirisPickup'
     CollisionRadius=10.000000
     CollisionHeight=5.000000
     Mass=5.000000
     Buoyancy=2.000000
     bHasScope=True
}
