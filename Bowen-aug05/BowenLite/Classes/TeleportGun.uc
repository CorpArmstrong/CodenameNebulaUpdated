//=============================================================================
// Teleporter Gun. 	(c) 2003 JimBowen
//=============================================================================
class TeleportGun expands BowenWeapon;

var(Bowen) float BeamDetail;
var(Bowen) Sound LockSound, InvalidSound, TelSound;
var Actor Target;
var bool bLatentMode;
var vector LatentLoc, LatentNorm;

enum EModeNum
{
	MODE_Normal,
	MODE_Inventory,
	MODE_AdminTeleport,
	MODE_AdminDestroy,
};

var EModeNum Mode;

replication
{
	reliable if(Role == ROLE_Authority)
	Target, Mode, bLatentMode, LatentLoc;
}

function Frob(Actor Frobber, Inventory frobWith)
{
	Mode = MODE_Normal;
	Super.Frob(Frobber, FrobWith);
}

simulated function LaserToggle()
{

	bLatentMode = !bLatentMode;
	if (LatentLoc == vect(0,0,0) && bLatentMode)
	{
		if (Role == ROLE_Authority)
			Pawn(Owner).ClientMessage("Teleport memory load.");
	}
	else if (bLatentMode)
	{
		if (Role == ROLE_Authority)
			Pawn(Owner).ClientMessage("Teleport memory recall.");
	}
	else
	{
		if (Role == ROLE_Authority)
			Pawn(Owner).ClientMessage("Cancelled.");
	}
}

simulated function tick(float deltatime)
{
	if (DeusExPlayer(Owner) == None)
	Mode = MODE_Normal;

	super.tick(DeltaTime);
}

simulated function cycleammo()
{
	switch Mode
	{
		case MODE_Normal:
			Mode = MODE_Inventory;
			if (Role == ROLE_Authority)
			Pawn(Owner).Clientmessage("Inventory swap mode activated.");
		break;

		case MODE_Inventory:
			if (DeusExPlayer(Owner).bAdmin)
			{
				Mode = MODE_AdminTeleport;
				if (Role == ROLE_Authority)
					Pawn(Owner).Clientmessage("Admin-Teleport mode activated.");
			}
			else
			{
				Mode = MODE_Normal;
				if (Role == ROLE_Authority)
					Pawn(Owner).Clientmessage("Normal mode activated.");
			}
			break;

	case MODE_AdminTeleport:
		Mode = MODE_AdminDestroy;
		if (Role == ROLE_Authority)
			Pawn(Owner).Clientmessage("Admin-Destroy mode activated");
		break;

	case MODE_AdminDestroy:
		Mode = MODE_Normal;
		if (Role == ROLE_Authority)
			Pawn(Owner).Clientmessage("Normal mode activated.");
		break;
	}

}


simulated function bool CheckTeamFrag(vector HitLocation)   //returns true if its OK to teleport
{
	local DeusExPlayer P;

		//  if (Level.NetMode == NM_Client)
		//       Return True; // always true clientside.

		foreach allactors (class'DeusExPlayer', p) //go through all players in the level and call each one P.
		{
			if (!SameTeam(P))
				Continue;  //skip this player if hes on the other team >:-D
				
			if(IsTelefrag(Hitlocation, P))
			{
				if(Role == ROLE_Authority)
					Pawn(Owner).ClientMessage("You may not telefrag teammates");
					Return False;
			}
		}
		Return True; //if the loop finished without returning false then its OK to teleport.
}

simulated function bool isTelefrag(vector HitLocation, pawn P)
{
	if (P.Location.Z - HitLocation.Z <= Owner.CollisionHeight + P.CollisionHeight)
		if (XYPythag(P, HitLocation)) //run the XYPythag function to see if we are inside P on the XY plane.
			Return True;
	Return False;
}

//use simple 2D pythagoras to see if we are inside the collision cylinder on the XY plane.
final function bool XYPythag(Actor A, vector HitLocation)
{
	local float X, Y, XYDistance;

		X = A.Location.X - HitLocation.X;
		Y = A.Location.Y - HitLocation.Y;
		XYDistance = (X**2 + Y**2)**0.5;

		if (XYDistance*0.95 <= Owner.CollisionRadius + A.CollisionRadius)
				Return True;
		else
				Return False;
}

function bool SameTeam(DeusExPlayer P)
{
	if (P == None || P == Owner)
		Return False;

	if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
		if (P.PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team)
			Return True;

	Return False;
}

function TeleportInventory (Pawn P1, Pawn P2)
{
	local Inventory InvP1[32];
	local Inventory InvP2[32];
	local Inventory TempInv;
	local vector VTemp;
	local int i, n;

		if (P1 == None || P2 == None)
		{
				Log("TeleportInventory:- Invalid input.");
				return;
			}
	
	
			if (SameTeam(DeusExPlayer(P2)))
			{
				P1.ClientMessage("You cannot inventory swap a teammate.");
				return;
			}
	
	
			if (P1.IsA('DeusExPlayer'))
				if (DeusExWeapon(DeusexPlayer(P1).InHand).bZoomed)
					DeusExPlayer(P1).ToggleZoom();
	
			if (P2.IsA('DeusExPlayer'))
				if (DeusExWeapon(DeusexPlayer(P2).InHand).bZoomed)
					DeusExPlayer(P2).ToggleZoom();
	
			foreach allactors (class'Inventory', TempInv)
			{
				if (TempInv.Owner == P1)
				{
					InvP1[i] = TempInv;
					i++;
					if(TempInv.IsA('ChargedPickup'))
						ChargedPickup(TempInv).chargedPickupEnd(DeusExPlayer(P1));
					if(DeusExWeapon(TempInv) != None)
						DeusExWeapon(TempInv).ScopeOff();
					TempInv.DropFrom(TempInv.Location);
				}
				else if (TempInv.Owner == P2)
				{
					InvP2[n] = TempInv;
					n++;
					if(TempInv.IsA('ChargedPickup'))
						ChargedPickup(TempInv).chargedPickupEnd(DeusExPlayer(P2));
					if(DeusExWeapon(TempInv) != None)
						DeusExWeapon(TempInv).ScopeOff();
					TempInv.DropFrom(TempInv.Location);
				}
			}
	
			for (i=0;i<ArrayCount(InvP1);i++)
				if (InvP1[i] != None)
					InvP1[i].Frob(P2, None);
	
			for (i=0;i<ArrayCount(InvP2);i++)
				if (InvP2[i] != None)
					InvP2[i].Frob(P1, None);
	
	/*              VTemp = P1.Location;
			if (P1.SetLocation(P2.Location + P1.CollisionHeight*1.1*vect(0,0,1)))
				P2.SetLocation(VTemp);
			VTemp = P1.Velocity;
			P1.SetPhysics(PHYS_Falling);
			P1.Velocity = P2.Velocity;
			P2.SetPhysics(PHYS_Falling);
			P2.Velocity = VTemp;*/
	}
	
simulated function DrawEffects(Actor Target, Vector HitLocation)
{
	local SphereEffect S;

	if (Mode != MODE_Inventory)
		S = Spawn (class'DeusEx.SphereEffect',,,HitLocation);
		if (S != None)
		{
			S.Size = 4;
			S.LifeSpan = 2;
			if (Mode == MODE_AdminDestroy)
				S.Skin = Texture'DeusExDeco.Skins.AlarmLightTex3';
			else
				S.Skin = Texture'Extension.CheckBoxOff';
		}

	if (Mode != MODE_Inventory && Mode != MODE_AdminDestroy)
	{
		S = Spawn (class'DeusEx.SphereEffect',,,Target.Location);
		If (S != None)
		{
			S.Size = 4;
			S.LifeSpan = 2;
			S.Skin = Texture'Extension.CheckBoxOff';
		}
	}

	if (Target != None)
	{
		if (Target.IsA('DeusExPlayer'))
			DeusExPlayer(Target).ClientFlash(5, vect(800,800,800));
		DrawLineEffect(Target.Location, HitLocation, BeamDetail);
	}
}

static final function float ACos  ( float A )   // thanks to UnrealWiki for this
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

simulated function DestroyTarget()
{
	local actor a;
	local float fangle;
	local vector vvect, dvect;

		if(Pawn(Owner) == None)
			return;
		vvect = normal(vector(Pawn(Owner).ViewRotation));

		foreach RadiusActors (class'actor', a, 300)
		{
			if (a == None || a == Owner)
				continue;

			dvect = normal(a.Location - Location);
			fangle = Acos(vvect dot dvect);
			if (fangle < 0.1)
				if (FastTrace(A.Location, Owner.Location))
					A.Destroy();
		}
}

simulated function bool CheckSpawnLOS(vector HitLocation)
{

	local PlayerStart P;

	foreach allactors (class 'PlayerStart', P)
	{
		if (FastTrace(P.Location, HitLocation) && VSize(P.Location - Location) < 4096)
			return True;
	}
	Return False;
}

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{

	if (DeusExPlayer(Owner) == None)
		return;

	if (Mode == MODE_AdminDestroy)
	{
		DestroyTarget();
		If (Other != None && Other != Level)
		{
			Other.Destroy();
		}
		
		if(DeusExPlayer(Owner).FrobTarget != None)
			DeusExPlayer(Owner).FrobTarget.Destroy();
		DrawEffects(Owner, HitLocation);

		return;
	}
	
	if (bLatentMode && LatentLoc == vect(0,0,0))
	{
		if (CheckSpawnLOS(HitLocation) && Level.NetMode != NM_StandAlone)
		{
			if(Role == ROLE_Authority)
				Pawn(Owner).ClientMessage("You may not store a location within a spawn room.");
			PlaySimSound( InvalidSound, SLOT_None, TransientSoundVolume, 2048 );
			return;
		}
		LatentLoc = HitLocation;
		LatentNorm = HitNormal;
		if(Role == ROLE_Authority)
			Pawn(Owner).ClientMessage("Location acknowledged.");
		PlaySimSound( LockSound, SLOT_None, TransientSoundVolume, 2048);
		bLatentMode = False;
		return;
	}

	if (Mode == MODE_AdminTeleport )
	{
		if(Target == None)
		{
				if (Other != None && Other != Level && (Level.NetMode != NM_Standalone ||
				(Level.NetMode == NM_Standalone && DeusExPlayer(Owner).bCheatsEnabled)))
				{
					Target = Other;
					if(Role == ROLE_Authority)
						DeusExPlayer(Owner).ClientMessage ("|p2Target Locked");
					PlaySimSound( LockSound, SLOT_None, TransientSoundVolume, 2048 );
					return;
				}
				else if (DeusExPlayer(Owner) != None)
				{
					if(Role == ROLE_Authority)
						DeusExPlayer(Owner).ClientMessage ("Invalid target");
					PlaySimSound( InvalidSound, SLOT_None,TransientSoundVolume, 2048 );
					return;
				}
		}
		else
			if (bLatentMode)
				Teleport(Target, LatentLoc, LatentNorm, Other);
	}
	else
		Target = Owner;
		
	if(bLatentMode && LatentLoc != vect(0,0,0))
	{
		Teleport(Target, LatentLoc, LatentNorm, Other);
		LatentLoc = vect(0,0,0);
		if(Role == ROLE_Authority)
			Pawn(Owner).ClientMessage("Location memory recalled.");
		bLatentMode = False;
		return;
	}
	
	Teleport(Target, HitLocation, HitNormal, Other);


	Target = None;
}


simulated function Teleport (Actor TelTarget, vector HitLocation, vector HitNormal, optional Actor Other)
{

	local vector loc, StartLocation;
	local ScriptedPawn P;

	if (CheckInhibitor(HitLocation))
		return;


	loc = HitLocation + HitNormal * TelTarget.CollisionHeight;
	if (HitNormal == Vect(0,0,1) && DeusExPlayer(Other) != None)
		Loc.z += 1.1*Other.CollisionHeight;
	if (!CheckTeamFrag(loc) && Mode == MODE_Normal)
		return;

	if (VSize(TelTarget.Location - HitLocation) <= MaxRange)
	{
		if (Mode != Mode_Inventory || Pawn(Other) != None)
			DrawEffects(TelTarget, HitLocation);

		if (Role == ROLE_Authority && (Mode == MODE_Normal || Mode == MODE_AdminTeleport))
		{
			TelTarget.SetLocation(loc);
			TelTarget.Velocity = Vect(0,0,0);
			if((TelTarget != Owner && TelTarget.IsA('ScriptedPawn')) || TelTarget.IsA('Carcass') || (TelTarget.IsA('DeusExDecoration') && DeusExDecoration(TelTarget).bPushable == True))
				TelTarget.SetPhysics(PHYS_Falling);
			if(Level.NetMode == NM_StandAlone)
				foreach allactors(class'ScriptedPawn', P)
					if(IsTelefrag(loc, P) && !P.IsA('Robot') && P != TelTarget)
						P.TakeDamage(5000, Pawn(Owner), P.Location, vect(0,0,0), 'Exploded');
		}

		else if (Mode == MODE_Inventory && Pawn(Other) != None)
		{
			if (Pawn(Other).ReducedDamageType != 'All')
				TeleportInventory(Pawn(Owner), Pawn(Other));
			else if (Role == ROLE_Authority)
				Pawn(Owner).ClientMessage("Inventory swap failed.");
		}

		PlaySimSound( TelSound, SLOT_None, TransientSoundVolume, 2048 );

		if (TelTarget.IsA('ScriptedPawn'))
		{
			TelTarget.GoToState('FallingState');
		}

		if(Other.IsA('DeusExPlayer'))
			DeusExPlayer(Other).ClientFlash(1, vect(1000,1000,1000));
		if(Other.IsA('ScriptedPawn'))
			Other.TakeDamage(1, Pawn(Owner), Other.Location, vect(0,0,0), 'TearGas');
	}
	else
		if (Owner != None)
			if (Owner.IsA('DeusExPlayer'))
				DeusExPlayer(Owner).ClientMessage ("|p2Out of range - teleport failed");
}

function DrawLineEffect(vector A, vector B, float Detail)
{
	local int i, NumSprites;
	local vector line, increment, loc;
	local float f, Dist;
	local BowenSpriteBeam BeamBit;

	line = A - B;

	Dist = VSize(line);
	f = Dist * Detail;
	NumSprites = int(f);

	increment = line / NumSprites;

	for( i=0; i<NumSprites; i++ )
	{
		loc = A - (increment * i);
		BeamBit = Spawn(class'BowenLite.BowenSpriteBeam',,, loc);
		if (Mode == MODE_AdminDestroy)
			BeamBit.Texture = Texture'DeusExDeco.Skins.AlarmLightTex2';
		else if (Mode == MODE_Inventory)
			BeamBit.Texture = Texture'DeusExItems.Skins.FlatFXTex44';
	}
}

simulated function bool CheckInhibitor(vector HitLocation)
{
	Local TeleportInhibitor Inhibitor;

	if (Mode < MODE_AdminTeleport)
		foreach allactors (class'TeleportInhibitor', Inhibitor)
		{
			if ((Inhibitor.Owner == Owner) || !(FastTrace(Owner.Location, Inhibitor.Location) && !Inhibitor.bNoLOS))
				Continue;

			else if (VSize(Inhibitor.Location - Target.Location) <Inhibitor.EffectRadius)
			{
				if(Role == ROLE_Authority)
					DeusExPlayer(Owner).ClientMessage ("|p2WARNING-- Teleportation failed due to environmental inhibition");
				PlaySimSound( InvalidSound, SLOT_None, TransientSoundVolume, 2048 );
				return True;
			}
			else if (VSize(Inhibitor.Location - HitLocation) < Inhibitor.EffectRadius)
			{
				if(Role == ROLE_Authority)
					DeusExPlayer(Owner).ClientMessage ("|p2WARNING-- Teleportation failed due to environmental inhibition");
				PlaySimSound( InvalidSound, SLOT_None, TransientSoundVolume, 2048 );
				return True;
			}
		}
	Return False;

}


state NormalFire
{
	Begin:
		if ((ClipCount >= ReloadCount) && (ReloadCount != 0))
		{
			if (!bAutomatic)
			{
				bFiring = False;
				FinishAnim();
			}
	
			if (Owner != None)
			{
				if (Owner.IsA('DeusExPlayer'))
				{
					bFiring = False;
	
	
					// should we autoreload?
					if (DeusExPlayer(Owner).bAutoReload)
					{
						// auto switch ammo if we're out of ammo and
						// we're not using the primary ammo
						if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
							CycleAmmo();
						ReloadAmmo();
					}
					else
					{
						if (bHasMuzzleFlash)
							EraseMuzzleFlashTexture();
						GotoState('Idle');
					}
				}
				else if (Owner.IsA('ScriptedPawn'))
				{
					bFiring = False;
					ReloadAmmo();
				}
			}
			else
			{
				if (bHasMuzzleFlash)
					EraseMuzzleFlashTexture();
				GotoState('Idle');
			}
		}
		if ( bAutomatic && (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient())))
			GotoState('Idle');
	
		Sleep(GetShotTime());
		if (bAutomatic)
		{
			GenerateBullet();       // In multiplayer bullets are generated by the client which will let the server know when
			Goto('Begin');
		}
		bFiring = False;
		FinishAnim();
	
	/*      // if ReloadCount is 0 and we're not hand to hand, then this is a
		// single-use weapon so destroy it after firing once
		if ((ReloadCount == 0) && !bHandToHand)
		{
			if (DeusExPlayer(Owner) != None)
				DeusExPlayer(Owner).RemoveItemFromSlot(Self);   // remove it from the inventory grid
			Destroy();
		}
		*/              // Do i REALLY need all that crap JUST for infinite ammo?
		ReadyToFire();
	Done:
		bFiring = False;
		Finish();
}

simulated function bool TestMPBeltSpot(int BeltSpot)
{
	return (BeltSpot == 0);
}

/*//---END-CLASS---*/

defaultproperties
{
	BeamDetail=0.020000
	LockSound=Sound'DeusExSounds.Generic.Beep1'
	InvalidSound=Sound'DeusExSounds.Generic.Buzz1'
	TelSound=Sound'DeusExSounds.Generic.Beep5'
	LowAmmoWaterMark=0
	GoverningSkill=Class'DeusEx.SkillWeaponRifle'
	NoiseLevel=1.000000
	ShotTime=0.300000
	reloadTime=0.500000
	HitDamage=2000
	maxRange=24000
	AccurateRange=14400
	BaseAccuracy=0.000000
	bHasScope=True
	AmmoNames(0)=Class'BowenLite.AmmoTeleport'
	bHasMuzzleFlash=False
	mpHitDamage=100
	mpBaseAccuracy=0.600000
	mpAccurateRange=14400
	mpMaxRange=14400
	AmmoName=Class'BowenLite.AmmoTeleport'
	ReloadCount=0
	SpawnPointCheckRadius=200
	PickupAmmoCount=10
	bInstantHit=True
	bWeaponStay=True
	FireOffset=(X=28.000000,Y=12.000000,Z=4.000000)
	ProjectileClass=Class'DeusEx.RocketLAW'
	shakemag=0.000000
	SelectSound=Sound'DeusExSounds.Weapons.LAWSelect'
	InventoryGroup=56
	ItemName="Bowen Teleporter Gun"
	PlayerViewOffset=(X=18.000000,Y=-18.000000,Z=-7.000000)
	PlayerViewMesh=LodMesh'DeusExItems.LAW'
	PickupViewMesh=LodMesh'DeusExItems.LAWPickup'
	ThirdPersonMesh=LodMesh'DeusExItems.LAW3rd'
	LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
	Icon=Texture'DeusExUI.Icons.BeltIconLAW'
	largeIcon=Texture'DeusExUI.Icons.LargeIconLAW'
	largeIconWidth=166
	largeIconHeight=47
	invSlotsX=4
	Description="The BowenCo teleporter gun allows the user to instantly teleport to anywhere within his line of sight, and now even to any location provided it is stored in memory."
	beltDescription="TELE"
	Mesh=LodMesh'DeusExItems.LAWPickup'
	CollisionRadius=25.000000
	CollisionHeight=6.800000
	Mass=50.000000
	bHasLaser=True
	BowenPickupMessage="|p2Press fire to go somewhere. Use the laser sight key to store/recall a location, and the ammo change key to activate inventory swap."
}
