//=============================================================================
// BowenShield. 	(c) 2003 JimBowen
//=============================================================================
class BowenShield expands InvulnSphere;

var DeusExPlayer AttachedPlayer2;

replication
{
	Reliable if (Role == ROLE_Authority)
		FollowPlayer, AttachedPlayer2;
}


simulated function Tick(float deltaTime)
{
	if (AttachedPlayer2 == None)
	{
		Destroy();
		return;
	}
	else
	{
		if (LifeSpan < 0.5)
			AttachedPlayer2.ReducedDamageType = '';
		FollowPlayer();
	}
}

simulated function FollowPlayer()
{
	SetLocation(AttachedPlayer2.Location);
	DrawScale = size * 1.5;
}

//---END-CLASS---

defaultproperties
{
     Skin=Texture'DeusExDeco.Skins.AlarmLightTex7'
     ScaleGlow=0.100000
     bAlwaysRelevant=True
}
