//================================================
//  LocatorDart --- Idea contributed by Batch_File
//================================================

class LocatorDart extends DeusExProjectile;

var float mpDamage;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
		Damage = mpDamage;
		
	if (DeusExPlayer(Owner) != None && !DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay.IsA('LocatorWindow'))
	{
		Pawn(Owner).ClientMessage("Spawning new locatorwindow");
		DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay = ActorDisplayWindow(DeusExRootWindow(DeusExPlayer(Owner).rootWindow).NewChild(Class'LocatorWindow'));
		DeusExRootWindow(DeusExPlayer(Owner).rootWindow).actorDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
	}
	
}

auto simulated state flying
{
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		local LocatorBeacon loc;
		loc = Spawn(class'LocatorBeacon',Owner,,Other.Location);
		loc.setBase(Other);
		Super.ProcessTouch(Other, HitLocation);
	}
	
	simulated function HitWall(vector HitNormal, actor Wall)
	{
		local LocatorBeacon loc;
		loc = Spawn(class'LocatorBeacon',Owner,,Wall.Location);
		loc.setBase(Wall);
		LifeSpan=1;
		Super.HitWall(HitNormal, Wall);
	}
}

defaultproperties
{
     mpDamage=2.000000
     bBlood=True
     bStickToWall=True
     DamageType=shot
     spawnAmmoClass=Class'AmmoLocator'
     bIgnoresNanoDefense=True
     ItemName="Bowen Locator Dart"
     ItemArticle="a"
     speed=2000.000000
     MaxSpeed=3000.000000
     Damage=5.000000
     MomentumTransfer=1000
     ImpactSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
     Mesh=LodMesh'DeusExItems.Dart'
     CollisionRadius=3.000000
     CollisionHeight=0.500000
}