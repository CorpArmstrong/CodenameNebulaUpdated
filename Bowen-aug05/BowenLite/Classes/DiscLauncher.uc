//=============================================================================
// DiscLauncher. 	(c) 2003 JimBowen
//=============================================================================
class DiscLauncher extends WeaponMiniCrossbow;

var(Bowen) string BowenPickupMessage;
var modController Controller;
var bool bChecked;
var float ConTime, DiscTimer;

replication
{
	reliable if (Role == ROLE_Authority)
		DoSound;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		HitDamage = mpHitDamage;
		BaseAccuracy = mpBaseAccuracy;
		ReloadTime = mpReloadTime;
		AccurateRange = mpAccurateRange;
		MaxRange = mpMaxRange;
		ReloadCount = mpReloadCount;
      PickupAmmoCount = mpReloadCount;
	}
}

// pinkmask out the arrow when we're out of ammo or the clip is empty
state NormalFire
{
	function BeginState()
	{
		if (ClipCount >= ReloadCount)
			MultiSkins[3] = Texture'PinkMaskTex';

		if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
			MultiSkins[3] = Texture'PinkMaskTex';
	
		Super.BeginState();
	}
}


function tick (float deltatime)
{
	ConTime += DeltaTime;
	
	if (!bChecked && ConTime > 10)
	{
		if(Controller == None)
			Controller = Spawn (class'ModController',,,Location);
		bChecked = True;
	}

	Super.Tick(deltaTime);
}


function ScopeToggle()
{
	// hack so that players without configured ini files can still use the weapon
	// yes i know its ugly, but you think of a better way!
	DetonateDiscs();
}

function LaserOn()
{
	switch DiscTimer
	{
		Case 0:
			DiscTimer = 1;
			Break;
		Case 1:
			DiscTimer = 3;
			Break;
		Case 3:
			DiscTimer = 5;
			Break;
		Case 5:
			DiscTimer = 0;
			Break;
	}
	if(DiscTimer > 0)
		Pawn(Owner).ClientMessage("Timer set:" @ DiscTimer @ "seconds.");
	else
		Pawn(Owner).ClientMessage("Timer deactivated.");
}

function DetonateDiscs()
{
	local ExplosiveDisc Disc;
	DoSound();
	foreach allactors (Class'ExplosiveDisc', Disc)
		if(Disc != None)
		{	if(Disc.Owner == Owner && (Disc.bWaiting || Disc.IsA('BounceDisc')))
			{
				Disc.Detonate();
			}

		//	if (!Disc.bWaiting)
		//		log ("Disc not exploded - not stuck to wall or actor");
		}
}

simulated function DoSound()
{
	Owner.PlaySound (Sound'DeusExSounds.Generic.Beep1', SLOT_None, 1024);
}

function GiveTo( pawn Other )
{	
	if (Other.IsA('DeusExPlayer'))
		DeusExPlayer(Other).ClientMessage(BowenPickupMessage);
	Super.GiveTo(Other);
}

//---END-CLASS---

defaultproperties
{
     BowenPickupMessage="|p2Use the scope key, |p1[|p2 to detonate the discs, Laser sight key to activate the disc timer."
     LowAmmoWaterMark=6
     ShotTime=0.400000
     bHasScope=True
     AmmoNames(0)=Class'BowenLite.AmmoDisc'
     AmmoNames(1)=Class'BowenLite.AmmoProxDisc'
     AmmoNames(2)=Class'BowenLite.AmmoBounceDisc'
     ProjectileNames(0)=Class'BowenLite.ExplosiveDisc'
     ProjectileNames(1)=Class'BowenLite.ProxDisc'
     ProjectileNames(2)=Class'BowenLite.BounceDisc'
     mpHitDamage=10
     mpReloadCount=32
     mpPickupAmmoCount=24
     AmmoName=Class'BowenLite.AmmoDisc'
     ReloadCount=24
     PickupAmmoCount=12
     ProjectileClass=Class'BowenLite.ExplosiveDisc'
     shakemag=0.000000
     InventoryGroup=134
     ItemName="Bowen Explosive Disc Launcher"
     Description="The BowenCo Explosive disc launcher fires a spinning disc that can be detonated using the remote detonator unit underneath the weapon. The disc launcher can use three different types of disc: remote detonated exolosive discs, proximity activated explosive discs, and remote detonated incendiary discs."
     beltDescription="DISC"
     bHasLaser=True
}
