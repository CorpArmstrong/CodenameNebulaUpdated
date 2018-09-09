//=============================================================================
// Button1B.
//=============================================================================
class Button1B extends DeusExDecoration;

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
    BT_Blank
};

var() EButtonType ButtonType;
var() float buttonLitTime;
var() sound buttonSound1;
var() sound buttonSound2;
var() bool bLit;
var() bool bWaitForEvent;
var bool isPressed;

var Vector lastLoc, rpcLocation;
var bool bIsMoving;

replication
{
    reliable if (Role == ROLE_Authority)
        rpcLocation;
}

function SetSkin(EButtonType type, bool lit)
{
    switch (type)
    {
        case BT_Up:
            if (lit)
            {
                Skin = Texture'Button1BTex2';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex1';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_Down:
            if (lit)
            {
                Skin = Texture'Button1BTex4';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex3';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_1:
            if (lit)
            {
                Skin = Texture'Button1BTex6';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex5';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_2:
            if (lit)
            {
                Skin = Texture'Button1BTex8';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex7';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_3:
            if (lit)
            {
                Skin = Texture'Button1BTex10';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex9';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_4:
            if (lit)
            {
                Skin = Texture'Button1BTex12';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex11';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_5:
            if (lit)
            {
                Skin = Texture'Button1BTex14';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex13';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_6:
            if (lit)
            {
                Skin = Texture'Button1BTex16';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex15';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_7:
            if (lit)
            {
                Skin = Texture'Button1BTex18';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex17';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_8:
            if (lit)
            {
                Skin = Texture'Button1BTex20';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex19';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_9:
            if (lit)
            {
                Skin = Texture'Button1BTex22';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex21';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case BT_Blank:
            if (lit)
            {
                Skin = Texture'Button1BTex24';
                ScaleGlow = 3.0;
            }
            else
            {
                Skin = Texture'Button1BTex23';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
    }
}

function BeginPlay()
{
    Super.BeginPlay();
    SetSkin(ButtonType, bLit);

    if (Level.NetMode != NM_Standalone)
    {
        rpcLocation = Location;
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    if (bWaitForEvent)
    {
        Timer();
    }
}

function Timer()
{
    PlaySound(buttonSound2, SLOT_None);
    SetSkin(ButtonType, bLit);
    isPressed = false;
}

function Frob(Actor Frobber, Inventory frobWith)
{
    if (!isPressed)
    {
        isPressed = true;

        PlaySound(buttonSound1, SLOT_None);
        SetSkin(ButtonType, !bLit);

        if (!bWaitForEvent)
        {
            SetTimer(buttonLitTime, false);
        }

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

simulated function Tick(float deltaTime)
{
    if (Level.NetMode != NM_Standalone)
    {
        if (Role == ROLE_Authority)
        {
            // Was moving, now at rest
            if (bIsMoving && (Location == lastLoc))
            {
                rpcLocation = Location;
            }

            bIsMoving = (Location != lastLoc);
            lastLoc = Location;
        }
        else
        {
            // Our replicated location changed which means the button has come to rest
            if (lastLoc != rpcLocation)
            {
                SetLocation(rpcLocation);
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
    bInvincible=true
    ItemName="Button"
    bPushable=false
    Physics=PHYS_None
    RemoteRole=ROLE_SimulatedProxy
    Mesh=LodMesh'CNN.Button1B'
    CollisionRadius=2.000000
    CollisionHeight=2.000000
    bCollideWorld=false
    bBlockActors=false
    Mass=5.000000
    Buoyancy=2.000000
}
