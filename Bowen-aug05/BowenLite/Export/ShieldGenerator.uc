//================================================================================
// ShieldGenerator.
//================================================================================
class ShieldGenerator extends ChargedPickup;

var BowenShield S;
var BowenShield s2;
var ModController Controller;

replication
{
	reliable if ( Role == 4 )
		KillEffect,DrawEffect;
}

simulated function ChargedPickupBegin (DeusExPlayer Player)
{
	if ( Owner.IsA('DeusExPlayer') && (Owner != None) )
	{
		ServerDrawEffect();
		DeusExPlayer(Owner).ReducedDamageType='All';
		SetCollision(True,True,False);
		SetCollisionSize(0.00,0.00);
	}
	Super.ChargedPickupBegin(Player);
}

simulated function Tick (float DeltaTime)
{
	if ( (Owner == None) ||  !Owner.IsA('DeusExPlayer') )
	{
		return;
	}
	if ( (DeusExPlayer(Owner).Health == 0) || DeusExPlayer(Owner).IsInState('Dying') || DeusExPlayer(Owner).bHidden )
	{
		DeusExPlayer(Owner).ReducedDamageType='None';
		KillEffect();
		ServerKillEffect();
		Destroy();
	}
	SetLocation(Owner.Location);
	if ( bIsActive )
	{
		DeusExPlayer(Owner).ReducedDamageType='All';
		if ( DeusExPlayer(Owner).bOnFire )
		{
			DeusExPlayer(Owner).ExtinguishFire();
		}
	}
	Super.Tick(DeltaTime);
}

simulated function UsedUp ()
{
	local DeusExPlayer Player;

	if ( Pawn(Owner) != None )
	{
		bActivatable=False;
	}
	Player=DeusExPlayer(Owner);
	if ( Player != None )
	{
		if ( Player.inHand == self )
		{
			ChargedPickupEnd(Player);
		}
	}
	if ( Owner.IsA('DeusExPlayer') && (Owner != None) )
	{
		DeusExPlayer(Owner).ReducedDamageType='None';
	}
	else
	{
		Log("owner is none");
	}
	KillEffect();
	ServerKillEffect();
	Destroy();
}

simulated function DrawEffect ()
{
	S=Spawn(Class'BowenShield',Owner,,Owner.Location);
	S.SetBase(Owner);
	S.LifeSpan=80.00;
	if ( Owner.IsA('DeusExPlayer') )
	{
		S.AttachedPlayer2=DeusExPlayer(Owner);
	}
}

function ServerDrawEffect ()
{
	s2=Spawn(Class'BowenShield',Owner,,Owner.Location);
	s2.SetBase(Owner);
	s2.LifeSpan=160.00;
	if ( Owner.IsA('DeusExPlayer') )
	{
		s2.AttachedPlayer2=DeusExPlayer(Owner);
	}
}

simulated function KillEffect ()
{
	S.Destroy();
}

function ServerKillEffect ()
{
	if ( Owner.IsA('DeusExPlayer') && (Owner != None) )
	{
		DeusExPlayer(Owner).ReducedDamageType='None';
	}
	else
	{
		Log("owner is none");
	}
	s2.Destroy();
}

function TakeDamage (int Dam, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	local int drain;

	if (  !bIsActive )
	{
		return;
	}
	drain=Dam;
	if ( DamageType == 'EMP' )
	{
		drain *= 10;
	}
	else
	{
		if ( DamageType == 'exploded' )
		{
			drain *= 1.10;
		}
		else
		{
			if ( (DamageType == 'Flamed') || (DamageType == 'shot') || (DamageType == 'Burned') )
			{
				drain *= 1.70;
			}
			else
			{
				if ( (DamageType == 'Shocked') || (DamageType == 'Radiation') )
				{
					drain *= 0.30;
				}
				else
				{
					if ( DamageType == 'None' )
					{
						drain *= 1;
					}
					else
					{
						drain *= 0;
					}
				}
			}
		}
	}
	Charge -= drain;
}

simulated function int CalcChargeDrain (DeusExPlayer Player)
{
	local float skillValue;
	local float drain;

	drain=10.00;
	skillValue=1.00;
	if ( skillNeeded != None )
	{
		skillValue=Player.SkillSystem.GetSkillLevelValue(skillNeeded);
	}
	drain *= skillValue;
	return drain;
}

auto state Pickup extends Pickup
{
	simulated function Frob (Actor Other, Inventory frobWith)
	{
		local ShieldGenerator S;
		local bool bFound;
	
		if ( Level.NetMode != 0 )
		{
			if ( Other.IsA('DeusExPlayer') )
			{
				if ( DeusExPlayer(Other).FindInventoryType(Class) != None )
				{
					bFound=True;
				}
			}
			if ( bFound )
			{
				if ( Other.IsA('DeusExPlayer') )
				{
					if ( DeusExPlayer(Other).bAdmin || DeusExPlayer(Other).bCheatsEnabled )
					{
						SpawnCopy(Pawn(Other));
					}
					else
					{
						DeusExPlayer(Other).ClientMessage("You cannot carry more than one shield");
						return;
					}
				}
			}
			else
			{
				Super.Frob(Other,frobWith);
			}
		}
		else
		{
			Super.Frob(Other,frobWith);
		}
	}
	
}

function PostBeginPlay ()
{
	if ( Controller == None )
	{
		Controller=Spawn(Class'ModController',,,Location);
	}
}

simulated function DropFrom (Vector startLocation)
{
	UsedUp();
	Super.DropFrom(startLocation);
}

defaultproperties
{
    skillNeeded=Class'DeusEx.SkillEnviro'
    LoopSound=Sound'DeusExSounds.Pickup.SuitLoop'
    ChargedIcon=Texture'DeusExUI.Icons.ChargedIconArmorBallistic'
    ExpireMessage="Shield Generator power supply used up"
    ItemName="Shield Generator"
    PlayerViewOffset=(X=30.00, Y=0.00, Z=-12.00)
    PlayerViewMesh=LodMesh'DeusExItems.AdaptiveArmor'
    PickupViewMesh=LodMesh'DeusExItems.AdaptiveArmor'
    ThirdPersonMesh=LodMesh'DeusExItems.AdaptiveArmor'
    LandSound=Sound'DeusExSounds.Generic.PaperHit2'
    Icon=Texture'DeusExUI.Icons.BeltIconArmorAdaptive'
    largeIcon=Texture'DeusExUI.Icons.LargeIconArmorAdaptive'
    largeIconWidth=34
    largeIconHeight=49
    Description="The BowenCo shield generator provides total invulnerability for a limited period of time. However it may be deactivated by a strong electromagnetic pulse"
    beltDescription="SHIELD"
    Mesh=LodMesh'DeusExItems.AdaptiveArmor'
    CollisionRadius=11.50
    CollisionHeight=13.81
    Mass=40.00
    Buoyancy=30.00
}