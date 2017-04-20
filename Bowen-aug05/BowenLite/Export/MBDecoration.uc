//================================================================================
// MBDecoration.
//================================================================================
class MBDecoration extends DeusExDecoration;

var(bowen) float RespawnTime;
var Vector originallocation;
var bool bSpawned;
var MiniBot Bot;

replication
{
	un?reliable if ( Role == 4 )
		originallocation,bSpawned;
}

function PostBeginPlay ()
{
	originallocation=Location;
}

function Activate (DeusExPlayer Activator)
{
	bHidden=True;
	SetCollision(False);
	Bot=Spawn(Class'MiniBot',Activator,,Location,Rotation);
	Bot.PlayerOwner=Activator;
	Bot.Health=HitPoints;
	Bot.HealthTorso=HitPoints;
	if (  !bSpawned )
	{
		SetTimer(RespawnTime,False);
	}
}

function Timer ()
{
	if ( Bot == None )
	{
		if ( bHidden )
		{
			SetLocation(originallocation);
			bHidden=False;
			SetCollision(True);
		}
	}
	else
	{
		SetTimer(RespawnTime / 10,False);
	}
}

defaultproperties
{
    RespawnTime=60.00
    HitPoints=5000
    bInvincible=True
    bExplosive=True
    explosionRadius=300.00
    RemoteRole=2
    Mesh=LodMesh'DeusExCharacters.SecurityBot4'
    bAlwaysRelevant=True
    CollisionRadius=25.00
    CollisionHeight=25.00
    bBlockActors=False
    bProjTarget=True
    Mass=30.00
    FamiliarName=""
    UnfamiliarName=""
}