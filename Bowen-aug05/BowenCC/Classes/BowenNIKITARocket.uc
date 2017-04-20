//=============================================================================
// BowenNIKITARocket. 	(c) 2003 JimBowen
//=============================================================================
class BowenNIKITARocket expands Rocket;

var AugmentationDisplayWindow win;
var gc gc;
var bowenviewportwindow vpw;
var bool bExploded, bDoneWin;
var rotator NewRotation;
var vector NewVelocity, NewLocation;

var(Bowen) sound LockedSound;

enum EIFF
{
	IFF_Hostile,
	IFF_Friendly,
	IFF_Neutral,
	IFF_None,
};

replication
{
	reliable if (Role == ROLE_Authority)
		bDoneWin, bExploded;

	unreliable if (Role == ROLE_Authority)
		NewRotation, NewVelocity, NewLocation;
}

simulated function HitWall (vector HitLocation, Actor Wall)
{
	if (vpw != None)
		vpw.Destroy();
	if (FireGen != None)
		FireGen.Destroy();
	if (SmokeGen != None)
		SmokeGen.Destroy();
	Super.HitWall (HitLocation, Wall);
}

auto simulated state flying
{
	simulated function tick(float deltatime)	
	{
		if(Role == ROLE_Authority || bNetOwner)	//dont do this on clients that didnt fire the rocket										
		{
			if(!bExploded)
			{
				if (bNetOwner)
				{
					if (FireGen != None)
						FireGen.Destroy();
					if (SmokeGen != None)
						SmokeGen.LifeSpan = 5;
					bDebris = False;
				}
				MakeWindow();
				SetDirection();
				SetRotation(NewRotation);
				Velocity = NewVelocity;
				//log("Nikita ticked");
			}
		}
		if(Role < ROLE_Authority && !bNetOwner)
		{
			SetRotation(NewRotation);
			Velocity = NewVelocity;
			SetLocation(NewLocation);
			SmokeGen.SetLocation(NewLocation);
			FireGen.SetLocation(NewLocation);
			//log("Nikita ticked on observing client, new rotation is: " @ NewRotation);
		}
		//log("Role = " @ Role @ ", bNetOwner = " @ bNetOwner); 
		Super.tick(DeltaTime);
	}
}

simulated function MakeWindow()	// adapted from DeusEx.AugmentationDisplayWindow.tick
{
	local String str;
	local float boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
	local float x, y, w, h, mult;
	local Vector loc;
	local float x2, y2, w2, h2, cx, cy;

		if ((Owner != None) && (Owner.IsA('DeusExPlayer')))
		{
			if ((Level.NetMode == NM_Client) || (Level.NetMode == NM_Standalone))
			{
				if (!bDoneWin)
				{	
					bDoneWin = True;
					win = DeusExRootWindow(DeusExPlayer(Owner).rootwindow).hud.augdisplay;
					gc = win.GetGC();
					vpw = BowenViewportWindow(win.NewChild(class'BowenViewportWindow'));
					vpw.projowner = Self;
				}
				else
				{
					vpw.AskParentForReconfigure();
					vpw.Lower();
					vpw.SetViewportActor(Self);
				}
				w2 = 512;
				h2 = 256;
				cx = (win.width/2) - 256;//+ win.margin;
				cy = (win.height/2) - 128;
				x2 = cx - w/2;
				y2 = cy - h/2;
				
				if (vpw != None)
					vpw.ConfigureChild(x2, y2, w2, h2);
			}			
		}
}

simulated function setdirection()
{
	NewRotation = (PlayerPawn(Owner).ViewRotation);
	NewVelocity = normal(vector(NewRotation))*speed;
	NewLocation = Location;
	//log("rotation to set (nikita) = " @ NewRotation);
}

simulated function destroyed()
{
	bExploded = True;
	if (vpw != None)
		vpw.Destroy();
	Super.Destroyed();
}
	
simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ShockRing ring;
   local SphereEffect sphere;
	local ExplosionLight light;
   local AnimatedSprite expeffect;

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
   if (light != None)
      light.RemoteRole = ROLE_None;

	if (blastRadius < 128)
	{
		expeffect = Spawn(class'ExplosionSmall',,, HitLocation);
		light.size = 2;
	}
	else if (blastRadius < 256)
	{
		expeffect = Spawn(class'ExplosionMedium',,, HitLocation);
		light.size = 4;
	}
	else
	{
		expeffect = Spawn(class'ExplosionLarge',,, HitLocation);
		light.size = 8;
	}

   if (expeffect != None)
      expeffect.RemoteRole = ROLE_None;

	// draw a pretty shock ring
   // For nano defense we are doing something else.
   if ((!bAggressiveExploded) || (Level.NetMode == NM_Standalone))
   {
   		if(!bNetOwner)
   		{
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(16384,0,0));
     		if (ring != None)
      		{
         		ring.RemoteRole = ROLE_None;
         		ring.size = blastRadius / 32.0;
      		}
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(0,0,0));
      		if (ring != None)
      		{
         		ring.RemoteRole = ROLE_None;
         		ring.size = blastRadius / 32.0;
      		}
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(0,16384,0));
      		if (ring != None)
      		{
         		ring.RemoteRole = ROLE_None;
         		ring.size = blastRadius / 32.0;
      		}
      	}
   }
   else
   {
      sphere = Spawn(class'SphereEffect',,, HitLocation, rot(16384,0,0));
      if (sphere != None)
      {
         sphere.RemoteRole = ROLE_None;
         sphere.size = blastRadius / 32.0;
      }
      sphere = Spawn(class'SphereEffect',,, HitLocation, rot(0,0,0));
      if (sphere != None)
      {
         sphere.RemoteRole = ROLE_None;
         sphere.size = blastRadius / 32.0;
      }
      sphere = Spawn(class'SphereEffect',,, HitLocation, rot(0,16384,0));
      if (sphere != None)
      {
         sphere.RemoteRole = ROLE_None;
         sphere.size = blastRadius / 32.0;
      }
   }
}


simulated function EIFF DoIff()
{
	local vector TargetLocation, StartTrace, EndTrace, TraceNormal, Direction;
	local actor Other;
	local EIFF Out;
		StartTrace = Location;
		EndTrace = Location;
		EndTrace += Velocity*MaxRange;
		Other = Trace(TargetLocation,TraceNormal,EndTrace,StartTrace,True);
		
		
		if(Other != None)
		{
			if(Other.IsA('ScriptedPawn'))
			{
				if(ScriptedPawn(Other).IsValidEnemy(Pawn(Owner)))
					Out = IFF_Hostile;
				else
					Out = IFF_Friendly;
			}

			else if (Other.IsA('DeusExPlayer'))
			{
				if (Other == Owner)
					Out = IFF_Friendly;
				else if (TeamDMGame(DeusExPlayer(Owner).DXGame) != None)	
				{
					if(DeusExPlayer(Other).PlayerReplicationInfo.team == DeusExPlayer(Owner).PlayerReplicationInfo.Team)
						Out = IFF_Friendly;
					else
						Out = IFF_Hostile;
				}
				else Out = IFF_Hostile;
			}
			else if (Other.IsA('levelInfo'))
				Out = IFF_None;
			else Out = IFF_Neutral;
		}
		else Out = IFF_None;
	
		if(Out == IFF_Hostile)
			Owner.AmbientSound = LockedSound;
		else
			Owner.AmbientSound = None;
	
	Return Out;
}

//---END-CLASS---

defaultproperties
{
     LockedSound=Sound'DeusExSounds.Generic.Beep4'
     mpBlastRadius=300.000000
     blastRadius=300.000000
     ItemName="NIKITA electro-optically guided missile"
     Damage=1000.000000
     bAlwaysRelevant=True
     NetPriority=3.000000
}
