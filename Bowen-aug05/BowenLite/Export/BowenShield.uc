//================================================================================
// BowenShield.
//================================================================================
class BowenShield extends InvulnSphere;

var DeusExPlayer AttachedPlayer2;

replication
{
	reliable if ( Role == 4 )
		FollowPlayer,AttachedPlayer2;
}

simulated function Tick (float DeltaTime)
{
	if ( AttachedPlayer2 == None )
	{
		Destroy();
		return;
	}
	else
	{
		if ( LifeSpan < 0.50 )
		{
			AttachedPlayer2.ReducedDamageType='None';
		}
		FollowPlayer();
	}
}

simulated function FollowPlayer ()
{
	SetLocation(AttachedPlayer2.Location);
	DrawScale=size * 1.50;
}

defaultproperties
{
    Skin=Texture'DeusExDeco.Skins.AlarmLightTex7'
    ScaleGlow=0.10
}