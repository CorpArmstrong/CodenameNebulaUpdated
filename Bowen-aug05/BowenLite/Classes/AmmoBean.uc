//=============================================================================
// AmmoBean.
//=============================================================================
class AmmoBean expands BowenAmmo;

var int mpAmmoAmount;

simulated function PreBeginPlay()
{
	if (Level.NetMode != NM_Standalone)
		AmmoAmount = mpAmmoAmount;
	Super.PostBeginPlay();
}

//---END-CLASS---

defaultproperties
{
     mpAmmoAmount=20
     AmmoAmount=50
     MaxAmmo=300
     ItemName="baked bean"
}
