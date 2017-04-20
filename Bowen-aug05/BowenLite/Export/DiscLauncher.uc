//================================================================================
// DiscLauncher.
//================================================================================
class DiscLauncher extends WeaponMiniCrossbow;

var(bowen) string BowenPickupMessage;
var ModController Controller;
var bool bChecked;
var float ConTime;

replication
{
	reliable if ( Role == 4 )
		DoSound;
}

simulated function PreBeginPlay ()
{
	Super.PreBeginPlay();
	if ( Level.NetMode != 0 )
	{
		HitDamage=mpHitDamage;
		BaseAccuracy=mpBaseAccuracy;
		reloadTime=mpReloadTime;
		AccurateRange=mpAccurateRange;
		maxRange=mpMaxRange;
		ReloadCount=mpReloadCount;
		PickupAmmoCount=mpReloadCount;
	}
}

state NormalFire extends NormalFire
{
	function BeginState ()
	{
		if ( ClipCount >= ReloadCount )
		{
			MultiSkins[3]=Texture'PinkMaskTex';
		}
		if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
		{
			MultiSkins[3]=Texture'PinkMaskTex';
		}
		Super.BeginState();
	}
	
}

function Tick (float DeltaTime)
{
	ConTime += DeltaTime;
	if (  !bChecked && (ConTime > 10) )
	{
		if ( Controller == None )
		{
			Controller=Spawn(Class'ModController',,,Location);
		}
		bChecked=True;
	}
	Super.Tick(DeltaTime);
}

function ScopeToggle ()
{
	DetonateDiscs();
}

function DetonateDiscs ()
{
	local ExplosiveDisc disc;

	DoSound();
	foreach AllActors(Class'ExplosiveDisc',disc)
	{
		if ( disc != None )
		{
			if ( (disc.Owner == Owner) && disc.bWaiting )
			{
				disc.Detonate();
			}
		}
		continue;
	}
}

simulated function DoSound ()
{
	Owner.PlaySound(Sound'Beep1',0,1024.00);
}

function GiveTo (Pawn Other)
{
	if ( Other.IsA('DeusExPlayer') )
	{
		DeusExPlayer(Other).ClientMessage(BowenPickupMessage);
	}
	Super.GiveTo(Other);
}

defaultproperties
{
    BowenPickupMessage="|p2Use the scope key, |p1[|p2 to detonate the discs"
    LowAmmoWaterMark=6
    ShotTime=0.40
    bHasScope=True
    AmmoNames(0)=Class'AmmoDisc'
    AmmoNames(1)=Class'AmmoProxDisc'
    AmmoNames(2)=Class'AmmoBounceDisc'
    ProjectileNames(0)=Class'ExplosiveDisc'
    ProjectileNames(1)=Class'ProxDisc'
    ProjectileNames(2)=Class'BounceDisc'
    mpHitDamage=10
    mpReloadCount=24
    mpPickupAmmoCount=24
    AmmoName=Class'AmmoDisc'
    ReloadCount=12
    PickupAmmoCount=12
    ProjectileClass=Class'ExplosiveDisc'
    shakemag=0.00
    InventoryGroup=134
    ItemName="Bowen Explosive Disc Launcher"
    Description="The BowenCo Explosive disc launcher fires a spinning disc that can be detonated using the remote detonator unit underneath the weapon. The disc launcher can use three different types of disc: remote detonated exolosive discs, proximity activated explosive discs, and remote detonated incendiary discs."
    beltDescription="DISC"
}