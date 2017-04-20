//================================================================================
// AmmoBean.
//================================================================================
class AmmoBean extends BowenAmmo;

var int mpAmmoAmount;

simulated function PreBeginPlay ()
{
	if ( Level.NetMode != 0 )
	{
		AmmoAmount=mpAmmoAmount;
	}
	PostBeginPlay();
}

defaultproperties
{
    mpAmmoAmount=20
    AmmoAmount=50
    MaxAmmo=300
    ItemName="baked bean"
}