//=============================================================================
// HandDry.
//=============================================================================
class HandDry extends DeusExDecoration;

enum ESkinColor
{
	SC_Clean,
	SC_Filthy
};

var() ESkinColor SkinColor;
var bool bUsing;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_Clean:	Skin = Texture'HandDryTex1'; break;
		case SC_Filthy:	Skin = Texture'HandDryTex2'; break;
	}
}

function Timer()
{
	bUsing = False;
}

function Frob(actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);

	if (bUsing)
		return;

	SetTimer(4.0, False);
	bUsing = True;

	PlaySound(sound'AirBreath',,,, 128);
}

defaultproperties
{
     HitPoints=50
     minDamageThreshold=50
     bInvincible=False
     FragType=Class'CNN.AiMetalFragment'
     ItemName="Automatic HandDry"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'CNN.HandDry'
     CollisionRadius=11.200000
     CollisionHeight=8.000000
     Mass=25.000000
     Buoyancy=50.000000
}