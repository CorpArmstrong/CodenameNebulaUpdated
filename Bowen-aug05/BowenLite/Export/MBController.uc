//================================================================================
// MBController.
//================================================================================
class MBController extends BowenWeapon;

simulated function ProcessTraceHit (Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	if ( Other.IsA('MBDecoration') )
	{
		MBDecoration(Other).Activate(DeusExPlayer(Owner));
	}
	else
	{
		if ( Other.IsA('MiniBot') )
		{
			MiniBot(Other).Deactivate(DeusExPlayer(Owner));
		}
	}
}

state NormalFire extends NormalFire
{
Begin:
	if ( (ClipCount >= ReloadCount) && (ReloadCount != 0) )
	{
		if (  !bAutomatic )
		{
			bFiring=False;
			FinishAnim();
		}
		if ( Owner != None )
		{
			if ( Owner.IsA('DeusExPlayer') )
			{
				bFiring=False;
				if ( DeusExPlayer(Owner).bAutoReload )
				{
					if ( (AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]) )
					{
						CycleAmmo();
					}
					ReloadAmmo();
				}
				else
				{
					if ( bHasMuzzleFlash )
					{
						EraseMuzzleFlashTexture();
					}
					GotoState('Idle');
				}
			}
			else
			{
				if ( Owner.IsA('ScriptedPawn') )
				{
					bFiring=False;
					ReloadAmmo();
				}
			}
		}
		else
		{
			if ( bHasMuzzleFlash )
			{
				EraseMuzzleFlashTexture();
			}
			GotoState('Idle');
		}
	}
	if ( bAutomatic && ((Level.NetMode == 1) || (Level.NetMode == 2) && Owner.IsA('DeusExPlayer') &&  !DeusExPlayer(Owner).PlayerIsListenClient()) )
	{
		GotoState('Idle');
	}
	Sleep(GetShotTime());
	if ( bAutomatic )
	{
		GenerateBullet();
		goto ('Begin');
	}
	bFiring=False;
	FinishAnim();
	ReadyToFire();
Done:
	bFiring=False;
	Finish();
}

defaultproperties
{
    Concealability=3
    bAutomatic=True
    ShotTime=0.10
    reloadTime=0.00
    HitDamage=1
    maxRange=960000
    BaseAccuracy=0.00
    AmmoName=Class'DeusEx.AmmoNone'
    ReloadCount=0
    bInstantHit=True
    shakemag=0.00
    FireSound=Sound'DeusExSounds.Generic.Beep1'
    ItemName="MiniBot controller"
    PlayerViewOffset=(X=20.00, Y=-10.00, Z=-16.00)
    PlayerViewMesh=LodMesh'DeusExItems.MultitoolPOV'
    PickupViewMesh=LodMesh'DeusExItems.Multitool'
    ThirdPersonMesh=LodMesh'DeusExItems.Multitool3rd'
    LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
    Icon=Texture'DeusExUI.Icons.BeltIconMultitool'
    largeIcon=Texture'DeusExUI.Icons.LargeIconMultitool'
    largeIconWidth=28
    largeIconHeight=46
    Description="A remote control device for the BowenCo MiniBot"
    beltDescription="Controller"
    Mesh=LodMesh'DeusExItems.Multitool'
    CollisionRadius=4.80
    CollisionHeight=0.86
    Mass=20.00
    Buoyancy=10.00
}