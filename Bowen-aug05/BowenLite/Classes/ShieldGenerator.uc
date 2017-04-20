//=============================================================================
// ShieldGenerator. 	(c) 2003 JimBowen
//=============================================================================
class ShieldGenerator expands BowenChargedPickup;

var BowenShield S;
var BowenShield S2;
//var teleportInhibitor InH;
var modcontroller controller;
var int Team;
var float AliveTime;
var bool bDoneDestroy;
var Actor oOwner;

replication
{
	reliable if (Role == ROLE_Authority)
		DrawEffect, KillEffect, S, S2;
}

simulated function ChargedPickupBegin(DeusExPlayer Player)
{

	if(owner.IsA('DeusExPlayer') && owner != None)
	{
	//	DrawEffect();
		ServerDrawEffect();
		DeusExPlayer(Owner).ReducedDamageType = 'ALL';
		SetCollision(True, True, False);
		SetCollisionSize(0,0); // unfourtunately we can't draw a box around the user to 
		// intercept projectiles because it would intercept outgoing projectiles aswell
		//bPojTarget = True;
		Team = DeusExPlayer(Owner).PlayerReplicationInfo.Team;
	}
		
	Super.ChargedPickupBegin(Player);
	
}


simulated function Tick(float deltatime)
{	
	if (Owner != None && oOwner == None)
		oOwner = Owner;

	if (Owner == None || !Owner.IsA('DeusExPlayer'))
		Return;

	if (bActive)
		AliveTime += DeltaTime;
	

	if ((DeusExPlayer(Owner).Health == 0) ||(DeusExPlayer(Owner).IsInState('Dying') || DeusExPlayer(Owner).bHidden))
	{	
		DeusExplayer(Owner).ReducedDamageType = '';
		KillEffect();
		ServerKillEffect();
		Destroy();
	}
	
	SetLocation(Owner.Location);
	if (bIsActive)
	{
		DeusExPlayer(Owner).ReducedDamageType = 'ALL';
		if(DeusExPlayer(Owner).bOnFire)
			DeusExPlayer(Owner).ExtinguishFire();
	}
	if (DeusExPlayer(Owner) != None)
		if (DeusExPlayer(Owner).PlayerReplicationInfo.Team != Team && AliveTime > 0.5)
		{
			if(DeusExPlayer(Owner) != None)
				DeusExPlayer(Owner).ReducedDamageType = '';
			UsedUp();
		}

	super.tick(deltatime);
}

simulated function UsedUp()
{
	local DeusExPlayer Player;

	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		
	}
	Player = DeusExPlayer(Owner);

	if (Player != None)
	{
		if (Player.inHand == Self)
			ChargedPickupEnd(Player);
	}
	
	if(oOwner.IsA('DeusExPlayer') && oowner != None)
		DeusExPlayer(oOwner).ReducedDamageType = '';
	else log ("owner is none");
		
	KillEffect();
	ServerKillEffect();
	if (!bDoneDestroy)
		Destroy();
}

simulated function DrawEffect()
{
	S = Spawn(Class'BowenShield', Owner,, Owner.Location);
	S.SetBase(Owner);
	S.Lifespan = 160;
	if(Owner.IsA('DeusExPlayer'))
		S.AttachedPlayer2 = DeusExPlayer(Owner);
}

simulated function destroyed()
{
	if(DeusExPlayer(oOwner) != None)
		DeusExPlayer(oOwner).ReducedDamageType = '';
	bDoneDestroy = True;
	UsedUp();
	Super.Destroyed();
}

function ServerDrawEffect()
{
	S2 = Spawn(Class'BowenShield', Owner,, Owner.Location);
	S2.SetBase(Owner);
	S2.Lifespan = 160;
	if(Owner.IsA('DeusExPlayer'))
		S2.AttachedPlayer2 = DeusExPlayer(Owner);
	//InH = Spawn(Class'TeleportInhibitor',Owner,,Owner.Location);
	//InH.LifeSpan=160;
	//InH.SetBase(Owner);
	//InH.EffectRadius=2.5*Owner.CollisionHeight;
}


simulated function KillEffect()
{
	S.Destroy();
}

function ServerKillEffect()
{
	if(oOwner.IsA('DeusExPlayer') && oowner != None)
		DeusExPlayer(oOwner).ReducedDamageType = '';
	else log ("oowner is none");
	S2.Destroy();
	//InH.Destroy();
}

function TakeDamage( int Dam, Pawn instigator, Vector hitlocation, Vector momentum, name damageType)
{
	local int Drain;

		if (Instigator == None || Owner == None)
			return;

		if (DeusExPlayer(Instigator) !=None && Instigator != Owner)
			if ((Owner.IsA('DeusExPlayer')) && TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
				if (DeusExPlayer(Instigator).PlayerReplicationInfo != None && DeusExPlayer(Owner).PlayerReplicationInfo != None) 
					if (DeusExPlayer(Instigator).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerreplicationInfo.Team)
						return;		
	
		if(!bIsActive)
			Return;
		
		Drain = Dam;
		
		if (damageType == 'EMP')
			Drain *= 20;	
		else if (DamageType == 'Exploded')
			Drain *= 1.2;
		else if (DamageType == 'Flamed' || DamageType == 'Shot' || DamageType == 'Burned')
			Drain *= 3;
		else if (DamageType == 'Shocked' || DamageType == 'Radiation')
			Drain *= 0.3;
		else if (DamageType == '')
			Drain *= 1;
		else
			Drain *= 0;
			
			Charge -= Drain;
}


// ----------------------------------------------------------------------
// CalcChargeDrain()
// ----------------------------------------------------------------------

simulated function int CalcChargeDrain(DeusExPlayer Player)
{
	local float skillValue;
	local float drain;

	drain = 15.0;
	skillValue = 1.0;

	if (skillNeeded != None)
		skillValue = Player.SkillSystem.GetSkillLevelValue(skillNeeded);
	drain *= skillValue;

	return Int(drain);
}

auto state pickup
{
	simulated function frob(Actor Other, Inventory FrobWith)
	{
		local ShieldGenerator S;
		local bool bFound;
		
			// Only one shield allowed in multiplayer
			if (Level.NetMode != NM_Standalone)
			{
				if (Other.IsA('DeusExPlayer'))
					if (DeusExPlayer(Other).FindInventoryType(Class) != None)	
						bFound = True;
				if(bFound)
				{
					if (Other.IsA('DeusExPlayer'))
					{
						if(DeusExPlayer(Other).bAdmin || DeusExPlayer(Other).bCheatsEnabled)
							SpawnCopy(Pawn(Other));
						else
						{
							DeusExPlayer(Other).ClientMessage ("You cannot carry more than one shield");
							return;
						}
					}
				}
				else
					Super.Frob(Other, FrobWith);		
			}
			else
				Super.Frob(Other, FrobWith);
	}
}


function PostBeginPlay()
{
	if(Controller == None)
		Controller = Spawn (class'ModController',,,Location);
}

simulated function DropFrom(vector StartLocation)
{
	UsedUp();
	Super.DropFrom(StartLocation);
}

//---END-CLASS---

defaultproperties
{
     skillNeeded=Class'DeusEx.SkillEnviro'
     LoopSound=Sound'DeusExSounds.Pickup.SuitLoop'
     ChargedIcon=Texture'DeusExUI.Icons.ChargedIconArmorBallistic'
     ExpireMessage="Shield Generator power supply used up"
     ItemName="Shield Generator"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.AdaptiveArmor'
     PickupViewMesh=LodMesh'DeusExItems.AdaptiveArmor'
     ThirdPersonMesh=LodMesh'DeusExItems.AdaptiveArmor'
     Charge=1000
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconArmorAdaptive'
     largeIcon=Texture'DeusExUI.Icons.LargeIconArmorAdaptive'
     largeIconWidth=34
     largeIconHeight=49
     Description="The BowenCo shield generator provides total invulnerability for a limited period of time. However it may be deactivated by a strong electromagnetic pulse"
     beltDescription="SHIELD"
     Mesh=LodMesh'DeusExItems.AdaptiveArmor'
     CollisionRadius=11.500000
     CollisionHeight=13.810000
     Mass=40.000000
     Buoyancy=30.000000
}
