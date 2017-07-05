//=============================================================================
// Button1A.
//=============================================================================
class Button1A extends DeusExDecoration;

enum EButtonType
{
	BT_Up,
	BT_Down,
	BT_1,
	BT_2,
	BT_3,
	BT_4,
	BT_5,
	BT_6,
	BT_7,
	BT_8,
	BT_9,
	BT_Blank,
	BT_Doors
};

var() EButtonType ButtonType;
var() float buttonLitTime;
var() sound buttonSound1;
var() sound buttonSound2;
var() bool bLit;
var() bool bWaitForEvent;
var bool isPressed;

var Vector	lastLoc, rpcLocation;
var bool	bIsMoving;

replication 
{
	reliable if ( Role == ROLE_Authority )
		rpcLocation;
}

function SetSkin(EButtonType type, bool lit)
{
	switch (type)
	{
		case BT_Up:			if (lit)
							{
								Skin = Texture'Button1ATex2';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex1';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_Down:			if (lit)
							{
								Skin = Texture'Button1ATex4';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex3';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_1:			if (lit)
							{
								Skin = Texture'Button1ATex6';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex5';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_2:			if (lit)
							{
								Skin = Texture'Button1ATex8';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex7';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_3:			if (lit)
							{
								Skin = Texture'Button1ATex10';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex9';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_4:			if (lit)
							{
								Skin = Texture'Button1ATex12';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex11';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_5:			if (lit)
							{
								Skin = Texture'Button1ATex14';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex13';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_6:			if (lit)
							{
								Skin = Texture'Button1ATex16';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex15';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_7:			if (lit)
							{
								Skin = Texture'Button1ATex18';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex17';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_8:			if (lit)
							{
								Skin = Texture'Button1ATex20';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex19';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_9:			if (lit)
							{
								Skin = Texture'Button1ATex22';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex21';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_Blank:			if (lit)
							{
								Skin = Texture'Button1ATex24';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex23';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
		case BT_Doors:			if (lit)
							{
								Skin = Texture'Button1ATex26';
								ScaleGlow = 3.0;
							}
							else
							{
								Skin = Texture'Button1ATex25';
								ScaleGlow = Default.ScaleGlow;
							}
							break;
	}
}

function BeginPlay()
{
	Super.BeginPlay();

	SetSkin(ButtonType, bLit);

	if ( Level.NetMode != NM_Standalone )
		rpcLocation = Location;
}

function Trigger(Actor Other, Pawn Instigator)
{
	if (bWaitForEvent)
		Timer();
}

function Timer()
{
	PlaySound(buttonSound2, SLOT_None);
	SetSkin(ButtonType, bLit);
	isPressed = False;
}

function Frob(Actor Frobber, Inventory frobWith)
{
	if (!isPressed)
	{
		isPressed = True;
		PlaySound(buttonSound1, SLOT_None);
		SetSkin(ButtonType, !bLit);
		if (!bWaitForEvent)
			SetTimer(buttonLitTime, False);

		Super.Frob(Frobber, frobWith);
	}
}

singular function SupportActor(Actor standingActor)
{
	// do nothing
}

function Bump(actor Other)
{
	// do nothing
}

simulated function Tick( float deltaTime )
{						  	
	if ( Level.NetMode != NM_Standalone )
	{
		if ( Role == ROLE_Authority )
		{
			// Was moving, now at rest
			if ( bIsMoving && ( Location == lastLoc ))
				rpcLocation = Location;

			bIsMoving = ( Location != lastLoc );
			lastLoc = Location;
		}
		else
		{
			// Our replicated location changed which means the button has come to rest
			if ( lastLoc != rpcLocation )
			{
				SetLocation( rpcLocation );
				lastLoc = rpcLocation;
			}
		}
	}
	Super.Tick( deltaTime );
}

defaultproperties
{
     ButtonType=BT_Blank
     buttonLitTime=0.500000
     buttonSound1=Sound'DeusExSounds.Generic.Beep1'
     bInvincible=True
     ItemName="Button"
     bPushable=False
     Physics=PHYS_None
     RemoteRole=ROLE_SimulatedProxy
     Mesh=LodMesh'CNN.Button1A'
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     bCollideWorld=False
     bBlockActors=False
     Mass=5.000000
     Buoyancy=2.000000
}