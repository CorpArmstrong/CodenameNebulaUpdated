//=============================================================================
// AmmoEMGun. 	(c) 2003 JimBowen
//=============================================================================
class AmmoEMGun expands BowenAmmo;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	AmmoAmount = 1;
	MaxAmmo = 10;
}

//---END-CLASS---

defaultproperties
{
     ItemName="Charge Units"
     AmmoAmount=1
     MPMaxAmmo=10
}