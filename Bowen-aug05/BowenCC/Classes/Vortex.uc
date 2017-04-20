//=============================================================================
// Vortex.
//=============================================================================
class Vortex extends Effects;

var (Bowen) float UpVel, Force, BlastRadius, mpBlastRadius, SpriteDensity, mpSpriteDensity, SwirlSpeed, mpLifeSpan;
var (Bowen) int NumExtraGibs;
var (Bowen) Sound SpawnSound, VortexSound;
var (Bowen) Texture ActiveTex, DeathTex;
var float SpriteTimer, ActiveTimer;
var bool bActive, bGibs;

var BHSpark Circle[48]; 
var vector PlaneNormal[48];
var Actor LastGibPawn;
var DummyDecoration DecKiller;

simulated function PreBeginPlay()
{
	PlaySpawnSound();

	if (Level.NetMode != NM_Standalone)
	{
		BlastRadius=mpBlastRadius;
		SpriteDensity=mpSpriteDensity;
		LifeSpan=mpLifeSpan;
	}
	if (!(Level.NetMode == NM_Client || Level.NetMode == NM_Standalone))
		DrawType = DT_None;
}

function PostBeginPlay()
{
	local TeleportInhibitor Inhibitor;
		
		SetTimer(0.5, True);
		DecKiller = Spawn(Class'DummyDecoration');
		DecKiller.ItemName="Vortex grenade";
		DecKiller.ItemArticle="a";
		DecKiller.LifeSpan=60;
		Inhibitor = Spawn(class'TeleportInhibitor',,,Location);
			Inhibitor.LifeSpan = LifeSpan;
			Inhibitor.EffectRadius = BlastRadius / 2;
		SetLocation (Location);
}

simulated function tick (float deltatime)
{
	local Actor A;
	local int i;
	local vector loc;
	local DeusExPlayer P;
	local int NumSwirls;
	
//	log("Role=" @ Role);
//	log("NM=" @ Level.NetMode);
	
		if (DeusExPlayer(Owner) == None)
			return;

		if (bActive)
		{
			foreach VisibleActors (class'Actor', A, BlastRadius * 1.05)
			{
				if (A.IsA('BHSpark') || A.IsA('OsirisPlasmaBall') || A.IsA('Inventory') || A == Self)
					continue;
				if (A.IsA('DeusExPlayer'))
				{
					if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
						if (DeusExPlayer(a).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team && a != Owner)
							Continue;
	
					if (DeusExPlayer(A).ReducedDamageType == 'All')
						continue;
				}

				if (A.IsA('PlasmaSpark'))
				{
				//	A.SetPhysics (PHYS_Flying);
					A.bCollideWorld=False;
					A.Velocity = -normal(A.Location - Location) * BlastRadius / VSize(A.Location - Location);
					A.Velocity -= Level.Default.ZoneGravity * DeltaTime;
					continue;
				}

				if(A.IsA('Projectile') && A.LifeSpan > 3)
					A.LifeSpan = 3;
					
				if ((A.IsA('DeusExDecoration') && DeusExDecoration(A).bPushable) || A.IsA('Pawn') || A.IsA('Projectile') || A.IsA('Carcass'))
				{
					if (A.Location.Z < Location.Z)
						A.Velocity -= Level.Default.ZoneGravity * DeltaTime;
					A.SetPhysics(PHYS_Falling);
				//	if (A.Location.Z > Location.Z - 3)
				//		A.Velocity.Z = UpVel;
					if (VSize(A.Location - Location) < BlastRadius / 4)
					{
						A.Velocity = -normal(A.Location - Location) * VSize(A.Velocity);
						if(A.IsA('DeusExPlayer'))
							DeusExPlayer(A).ClientFlash(500, vect(-10000,-1000,-100));
						else if (A.IsA('Projectile'))
							A.Destroy();
					}
					else if (VSize(A.Location - Location) < BlastRadius)
						A.Velocity -= normal(A.Location - Location) * Force * DeltaTime;
				}
			}
		
			if (Level.NetMode != NM_DedicatedServer || Level.NetMode == NM_Standalone)
			{	
				SpriteTimer += DeltaTime;
				
				if (SpriteTimer > 0.05)
				{
					SpriteTimer = 0;		

					for (i=0;i<SpriteDensity;i++)
					{
						loc = Location + VRand() * BlastRadius * FRand();
						Spawn(class'BHSpark',,, loc, rotator(-normal(loc - Location)));
					}
				}
			}	
		}
		else if (DrawScale < 2.5)
			DrawScale += DeltaTime;

		if (Level.NetMode == NM_Standalone)
			NumSwirls=48;
		else
			NumSwirls=24;

		if (Level.NetMode != NM_DedicatedServer || Level.NetMode == NM_Standalone)
		{	
			for (i=0;i<NumSwirls;i++)
			{
				if (PlaneNormal[i] == vect(0,0,0))
					PlaneNormal[i] = (VRand()) cross (Location - Circle[i].Location);
	
				if (Circle[i] == None)
				{
					Circle[i] = Spawn(class'BHSpark',,, Location + VRand() * (BlastRadius/2) * FRand());
					if (Circle[i] != None)
					{
						Circle[i].LifeSpan = 1.08*LifeSpan + FRand();
						Circle[i].RemoteRole = ROLE_None;
						Circle[i].Texture = Texture'BowenCust.Effects.YellowGlow';
						Circle[i].DrawScale = 0.9;
						Circle[i].SetCollision(False, False);
						Circle[i].bAlwaysRelevant=True;
					}
				}
				if (Circle[i] != None)
				{
					Circle[i].SetRotation (rotator(PlaneNormal[i] cross (Location - Circle[i].Location)));
					Circle[i].Velocity = SwirlSpeed * normal(PlaneNormal[i] cross (Location - Circle[i].Location));
				//	log ("PlaneNormal:" @ PlaneNormal[i]);
				//	log ("Velocity:" @ PlaneNormal[i] cross (Location - Circle[i].Location));
				}
			}
			
		}

		if (!bActive)
		{
			ActiveTimer += DeltaTime;
			foreach VisibleActors (class'DeusExPlayer', P, 4*BlastRadius)
				P.ClientFlash(100, vect(-10000,-1000,-100));
		}
	
		if (ActiveTimer > 2.25 && !bActive)
		{
			bActive = True;
			if (Level.NetMode == NM_Client || Level.NetMode == NM_Standalone)
				AmbientSound = VortexSound;
		}
			
}

function touch (actor Other)
{
	if (!bActive || Level.NetMode == NM_Client)
		return;

	if (Other.IsA('DeusExPlayer'))
	{
		if (DeusExPlayer(Other).ReducedDamageType == 'All')
			return;

		if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
			if (DeusExPlayer(Other).PlayerReplicationInfo.Team == DeusExPlayer(Owner).PlayerReplicationInfo.Team && Other != Owner)
				return;
	}

	if (Other.IsA('Pawn') && !Other.IsInState('Dying'))
		if(Other != LastGibPawn)
		{
			SpawnGibs();
			LastGibPawn = Other;
		}
			
	if (Other.IsA('DeusExPlayer'))
	{
		DeusExPlayer(Other).MyProjKiller = DecKiller;
		if (Role == ROLE_Authority)
			Other.TakeDamage(65535, Pawn(Owner), Other.Location, vect(0,0,0), 'Exploded');
	}
	else if (!Other.IsA('Inventory'))
		Other.Destroy();
}

function Destroyed()
{
	local BlastSphere Sph;
	
		Sph = Spawn(class'BlastSphere',,,Location);
		Sph.Size = 300;
		Sph.RemoteRole = ROLE_simulatedProxy;
		Sph.Skin = Texture;
		Sph.LifeSpan = 1;

		Super.Destroyed();
}

simulated function SpawnGibs()
{
	local int i;
	local FleshFragment F;

		for (i=0;i<NumExtraGibs;i++)
		{
			F = Spawn(class'FleshFragment',,,Location + VRand() * BlastRadius * 0.5 *FRand());
			if (F != None)
				F.CalcVelocity(VRand(),600);
		}
}

function PlaySpawnSound()
{
	local float rad;

	if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer) || (Level.NetMode == NM_DedicatedServer))
	{
		rad = Max(blastRadius*4, 1024);
		PlaySound(SpawnSound, SLOT_None, 2.0,, rad);
	}
}
//---END-CLASS---

defaultproperties
{
     UpVel=100.000000
     Force=300.000000
     blastRadius=1000.000000
     mpBlastRadius=2000.000000
     SpriteDensity=100.000000
     mpSpriteDensity=40.000000
     SwirlSpeed=1000.000000
     mpLifeSpan=10.000000
     NumExtraGibs=20
     SpawnSound=Sound'BowenCust.Vortex.VortexStart'
     VortexSound=Sound'BowenCust.Vortex.wind'
     RemoteRole=ROLE_DumbProxy
     LifeSpan=30.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'BowenCust.Vortex.VB_a00'
     DrawScale=0.250000
     bAlwaysRelevant=True
     SoundRadius=128
     SoundVolume=192
     CollisionRadius=50.000000
     CollisionHeight=50.000000
     bCollideActors=True
     bProjTarget=True
}
