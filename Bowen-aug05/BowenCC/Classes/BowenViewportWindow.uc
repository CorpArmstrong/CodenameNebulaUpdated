//=============================================================================
// BowenViewportWindow. 	(c) 2003 JimBowen  
// (but also with a f***load copied from AugmentationDisplayWindow, for the night vision effect)
//=============================================================================
class BowenViewportWindow expands ViewportWindow;

var bowennikitarocket projowner;
var(Bowen) Texture WinOverlayTex;
var(Bowen) Texture HostileTex, FriendlyTex, NeutralTex, NoneTex;
var float TestTime;

var(Bowen) Color colBackground;
var(Bowen) Color colBorder;
var(Bowen) Color colHeaderText;
var(Bowen) Color colText;

var bool bVisionActive;
var(Bowen) int visionLevel;
var(Bowen) float visionLevelValue;
var int activeCount;

var(Bowen) float margin;
var(Bowen) float corner;

var Actor VisionBlinder; //So the same thing doesn't blind me twice.

var int VisionTargetStatus; //For picking see through wall texture
const VISIONENEMY = 1;
const VISIONALLY = 2;
const VISIONNEUTRAL = 0;

var (Bowen) String msgLightAmpActive;
var (Bowen) String msgIRAmpActive;

var DeusExPlayer Player;

event InitWindow()
{
/*	local PictureWindow pic;
	local float x2, y2, w2, h2, cx, cy;
	local float x, y, w, h;

		pic = PictureWindow(NewChild(class'PictureWindow'));
		if (pic != None)
		{
			pic.AskParentForReconfigure();
			pic.Lower();
			w2 = width/3;
			h2 = height/2.3;
			cx = width/4;
			cy = height/2;
			x2 = cx - w;
			y2 = cy - h;
			pic.ConfigureChild(x2, y2, w2, h2);
			pic.SetBackground(WinOverlayTex);
			pic.SetBackGroundStyle(DSTY_Masked);
			pic.SetBackgroundStretching(True);
		}*/
			
		Super.InitWindow();
		bTickEnabled = True;
}

function tick (float deltatime)
{
	local int IFF;
	
		IFF = ProjOwner.DoIff();
		
		if (IFF == 0)
			WinOverlayTex = HostileTex;
		else if (IFF == 1)
			WinOverlayTex = FriendlyTex;
		else if (IFF == 2)
			WinOverlayTex = NeutralTex;
		else
			WinOverlayTex = NoneTex;
	
	Player = DeusExPlayer(ProjOwner.Owner);
		
	if(ProjOwner.bExploded)
		Destroy();
}

event DrawWindow(GC gc)
{	
	// Draw visionaug effects
//	DrawVisionAugmentation(gc); -- screw visionaug effects.

	// Draw window background
	gc.SetStyle(DSTY_Translucent);
	gc.DrawTexture(224, 96, 64, 64, 0, 0, WinOverlayTex); //was Texture'BowenCust.Weapons.Recticle_a00'
}


// --------------------------------
/*
// ----------------------------------------------------------------------
// DrawVisionAugmentation()
// ----------------------------------------------------------------------

function DrawVisionAugmentation(GC gc)
{
	local Vector loc;
	local float boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
	local float dist, x, y, w, h;
   local float BrightDot;
	local Actor A;
   local float DrawGlow;
   local float RadianView;
   local float OldFlash, NewFlash;
   local vector OldFog, NewFog;
	local Texture oldSkins[9];

	boxW = width/2;
	boxH = height/2;
	boxCX = width/2;
	boxCY = height/2;
	boxTLX = boxCX - boxW/2;
	boxTLY = boxCY - boxH/2;
	boxBRX = boxCX + boxW/2;
	boxBRY = boxCY + boxH/2;

	// at level one and higher, enhance heat sources (FLIR)
	// use DrawActor to enhance NPC visibility
	if (visionLevel >= 1)
	{
		// shift the entire screen to dark red (except for the middle box)
      if (player.Level.Netmode == NM_Standalone)
      {
         gc.SetStyle(DSTY_Modulated);
         gc.DrawPattern(0, 0, width, boxTLY, 0, 0, Texture'ConWindowBackground');
         gc.DrawPattern(0, boxBRY, width, height-boxBRY, 0, 0, Texture'ConWindowBackground');
         gc.DrawPattern(0, boxTLY, boxTLX, boxH, 0, 0, Texture'ConWindowBackground');
         gc.DrawPattern(boxBRX, boxTLY, width-boxBRX, boxH, 0, 0, Texture'ConWindowBackground');
         gc.DrawPattern(0, 0, width, boxTLY, 0, 0, Texture'SolidRed');
         gc.DrawPattern(0, boxBRY, width, height-boxBRY, 0, 0, Texture'SolidRed');
         gc.DrawPattern(0, boxTLY, boxTLX, boxH, 0, 0, Texture'SolidRed');
         gc.DrawPattern(boxBRX, boxTLY, width-boxBRX, boxH, 0, 0, Texture'SolidRed');
         gc.SetStyle(DSTY_Translucent);
      }

      // DEUS_EX AMSD In multiplayer, draw green here so that we can draw red actors over it
      if (player.Level.Netmode != NM_Standalone)
      {
         gc.SetStyle(DSTY_Modulated);
         gc.DrawPattern(0, 0, width, height, 0, 0, Texture'VisionBlue');
         gc.DrawPattern(0, 0, width, height, 0, 0, Texture'VisionBlue');
         gc.SetStyle(DSTY_Translucent);
      }
      

		loc = ProjOwner.Location;

      // DEUS_EX AMSD In multiplayer, in order to not let you snipe people hiding in the dark across the map, but not get
      // bad feedback from coloring everything green, we have to make the red non translucent so that scale glow darkens it,
      // instead of fading it out.
      //if (Player.Level.Netmode != NM_Standalone)
         //gc.SetStyle(DSTY_Normal);

      foreach ProjOwner.AllActors(class'Actor', A)
      {
         if (A.bVisionImportant)
         {
            if (IsHeatSource(A) || ( (Player.Level.Netmode != NM_Standalone) && ((A.IsA('AutoTurret')) || (A.IsA('AutoTurretGun')) || (A.IsA('SecurityCamera')) ) ))
            {
               dist = VSize(A.Location - loc);
               //If within range of vision aug bit
               if ( ( ((Player.Level.Netmode != NM_Standalone) && (dist <= (visionLevelvalue / 2))) ||
                      ((Player.Level.Netmode == NM_Standalone) && (dist <= (visionLevelValue)))        ) && (IsHeatSource(A)))
               {           
                  VisionTargetStatus = GetVisionTargetStatus(A);               
                  SetSkins(A, oldSkins);
                  gc.DrawActor(A, False, False, True, 1.0, 2.0, None);
                  ResetSkins(A, oldSkins);
               }
               else if ((Player.Level.Netmode != NM_Standalone) && (GetVisionTargetStatus(A) == VISIONENEMY) && (A.Style == STY_Translucent))
               {
                  //DEUS_EX AMSD In multiplayer, if looking at a cloaked enemy player within range (greater than see through walls)
                  //(If within walls radius he'd already have been seen.               
                  if ( (dist <= (visionLevelvalue)) && (ProjOwner.FastTrace(ProjOwner.Location, A.Location)) )
                  {
                     VisionTargetStatus = GetVisionTargetStatus(A);               
                     SetSkins(A, oldSkins);
                     gc.DrawActor(A, False, False, True, 1.0, 2.0, None);
                     ResetSkins(A, oldSkins);
                  }
               }
               else if (ProjOwner.FastTrace(ProjOwner.Location, A.Location))
               {
                  VisionTargetStatus = GetVisionTargetStatus(A);               
                  SetSkins(A, oldSkins);
                  
                  if ((Player.Level.NetMode == NM_Standalone) || (dist < VisionLevelValue * 1.5) || (VisionTargetStatus != VISIONENEMY))
                  {
                     DrawGlow = 2.0;
                  }
                  else
                  {
                     // Fadeoff with distance square
                     DrawGlow = 2.0 / ((dist / (VisionLevelValue * 1.5)) * (dist / (VisionLevelValue * 1.5)));
                     // Don't make the actor harder to see than without the aug.
                     //DrawGlow = FMax(DrawGlow,A.ScaleGlow);
                     // Set a minimum.
                     DrawGlow = FMax(DrawGlow,0.15);
                  }                  
                  gc.DrawActor(A, False, False, True, 1.0, DrawGlow, None);
                  ResetSkins(A, oldSkins);
               }
            }
            else if ( (A != VisionBlinder) && (Player.Level.NetMode != NM_Standalone) && (A.IsA('ExplosionLight')) && (ProjOwner.FastTrace(ProjOwner.Location, A.Location)) )
            {
               BrightDot = Normal(Vector(ProjOwner.Rotation)) dot Normal(A.Location - ProjOwner.Location);
               dist = VSize(A.Location - ProjOwner.Location);
               
               if (dist > 3000)
                  DrawGlow = 0;
               else if (dist < 300)
                  DrawGlow = 1;
               else
                  DrawGlow = ( 3000 - dist ) / ( 3000 - 300 );
               
               // Calculate view angle in radians.
               RadianView = (90 / 180) * 3.141593;
               
               if ((BrightDot >= Cos(RadianView)) && (DrawGlow > 0.2) && (BrightDot * DrawGlow * 0.9 > 0.2))  //DEUS_EX AMSD .75 is approximately at our view angle edge.
               {
                  VisionBlinder = A;
                  NewFlash = 10.0 * BrightDot * DrawGlow;
                  NewFog = vect(1000,1000,900) * BrightDot * DrawGlow * 0.9;
                  OldFlash = player.DesiredFlashScale;
                  OldFog = player.DesiredFlashFog * 1000;
                  
                  // Don't add increase the player's flash above the current newflash.
                  NewFlash = FMax(0,NewFlash - OldFlash);
                  NewFog.X = FMax(0,NewFog.X - OldFog.X);
                  NewFog.Y = FMax(0,NewFog.Y - OldFog.Y);
                  NewFog.Z = FMax(0,NewFog.Z - OldFog.Z);
                  player.ClientFlash(NewFlash,NewFog);
                  player.IncreaseClientFlashLength(4.0*BrightDot*DrawGlow*BrightDot);
               }
            }
         }
      }

      // draw text label
      if (player.Level.Netmode == NM_Standalone)
      {
         gc.GetTextExtent(0, w, h, msgIRAmpActive);
         x = boxTLX + margin;
         y = boxTLY - margin - h;
         gc.SetTextColor(colHeaderText);
         gc.DrawText(x, y, w, h, msgIRAmpActive);
      }
	}

	// shift the middle of the screen green (NV) and increase the contrast
   // DEUS_EX AMSD In singleplayer, draw this here
   // In multiplayer, drawn earlier so you can still see through walls with it.
   if (player.Level.Netmode == NM_Standalone)
   {
      gc.SetStyle(DSTY_Modulated);
      gc.DrawPattern(boxTLX, boxTLY, boxW, boxH, 0, 0, Texture'SolidGreen');
      gc.DrawPattern(boxTLX, boxTLY, boxW, boxH, 0, 0, Texture'SolidGreen');
   }
   gc.SetStyle(DSTY_Normal);

	if (player.Level.NetMode == NM_Standalone)
      DrawDropShadowBox(gc, boxTLX, boxTLY, boxW, boxH);

	// draw text label
   if (player.Level.Netmode == NM_Standalone)
   {
      gc.GetTextExtent(0, w, h, msgLightAmpActive);
      x = boxTLX + margin;
      y = boxTLY + margin;
      gc.SetTextColor(colHeaderText);
      gc.DrawText(x, y, w, h, msgLightAmpActive);
   }
}



// ----------------------------------------------------------------------
// IsHeatSource()
// ----------------------------------------------------------------------

function bool IsHeatSource(Actor A)
{
   if ((A.bHidden) && (Player.Level.NetMode != NM_Standalone))
      return False;
   if (A.IsA('Pawn'))
   {
      if (A.IsA('ScriptedPawn'))
         return True;
      else if ( (A.IsA('DeusExPlayer')) && (A != Player) )//DEUS_EX AMSD For multiplayer.
         return True;
      return False;
   }
	else if (A.IsA('DeusExCarcass'))
		return True;   
	else if (A.IsA('FleshFragment'))
		return True;
   else
		return False;
}

// ----------------------------------------------------------------------
// VisionTargetStatus()
// ----------------------------------------------------------------------

function int GetVisionTargetStatus(Actor Target)
{
   local DeusExPlayer PlayerTarget;
   local TeamDMGame TeamGame;

   if (Target == None)
      return VISIONNEUTRAL;
   
   if (player.Level.NetMode == NM_Standalone)
      return VISIONNEUTRAL;

   if (target.IsA('DeusExPlayer'))
   {     
      if (target == player)
         return VISIONNEUTRAL;
      
      TeamGame = TeamDMGame(player.DXGame);
      // In deathmatch, all players are hostile.
      if (TeamGame == None)
         return VISIONENEMY;
      
      PlayerTarget = DeusExPlayer(Target);
      
      if (TeamGame.ArePlayersAllied(PlayerTarget,Player))
         return VISIONALLY;
      else
         return VISIONENEMY;
   }
   else if ( (target.IsA('AutoTurretGun')) || (target.IsA('AutoTurret')) )
   {
      if (target.IsA('AutoTurretGun'))
         return GetVisionTargetStatus(target.Owner);
      else if ((AutoTurret(Target).bDisabled))
         return VISIONNEUTRAL;
      else if (AutoTurret(Target).safetarget == Player) 
         return VISIONALLY;
      else if ((Player.DXGame.IsA('TeamDMGame')) && (AutoTurret(Target).team == -1))
         return VISIONNEUTRAL;
      else if ( (!Player.DXGame.IsA('TeamDMGame')) || (Player.PlayerReplicationInfo.Team != AutoTurret(Target).team) )
          return VISIONENEMY;
      else if (Player.PlayerReplicationInfo.Team == AutoTurret(Target).team)
         return VISIONALLY;
      else
         return VISIONNEUTRAL;
   }
   else if (target.IsA('SecurityCamera'))
   {
      if ( !SecurityCamera(target).bActive )
         return VISIONNEUTRAL;
      else if ( SecurityCamera(target).team == -1 )
         return VISIONNEUTRAL;
      else if (((Player.DXGame.IsA('TeamDMGame')) && (SecurityCamera(target).team==player.PlayerReplicationInfo.team)) ||
         ( (Player.DXGame.IsA('DeathMatchGame')) && (SecurityCamera(target).team==player.PlayerReplicationInfo.PlayerID)))
         return VISIONALLY;
      else
         return VISIONENEMY;
   }
   else
      return VISIONNEUTRAL;
}

// ----------------------------------------------------------------------
// SetSkins()
// 
// copied from ActorDisplayWindow
// ----------------------------------------------------------------------

function SetSkins(Actor actor, out Texture oldSkins[9])
{
	local int     i;
	local texture curSkin;

	for (i=0; i<8; i++)
		oldSkins[i] = actor.MultiSkins[i];
	oldSkins[i] = actor.Skin;

	for (i=0; i<8; i++)
	{
		curSkin = actor.GetMeshTexture(i);
		actor.MultiSkins[i] = GetGridTexture(curSkin);
	}
	actor.Skin = GetGridTexture(oldSkins[i]);
}

// ----------------------------------------------------------------------
// ResetSkins()
// 
// copied from ActorDisplayWindow
// ----------------------------------------------------------------------

function ResetSkins(Actor actor, Texture oldSkins[9])
{
	local int i;

	for (i=0; i<8; i++)
		actor.MultiSkins[i] = oldSkins[i];
	actor.Skin = oldSkins[i];
}

// ----------------------------------------------------------------------
// GetGridTexture()
//
// modified from ActorDisplayWindow
// ----------------------------------------------------------------------

function Texture GetGridTexture(Texture tex)
{
	if (tex == None)
		return Texture'BlackMaskTex';
	else if (tex == Texture'BlackMaskTex')
		return Texture'BlackMaskTex';
	else if (tex == Texture'GrayMaskTex')
		return Texture'BlackMaskTex';
	else if (tex == Texture'PinkMaskTex')
		return Texture'BlackMaskTex';
	else if (VisionTargetStatus == VISIONENEMY)         
      return Texture'Virus_SFX';
   else if (VisionTargetStatus == VISIONALLY)
		return Texture'Wepn_Prifle_SFX';
   else if (VisionTargetStatus == VISIONNEUTRAL)
      return Texture'WhiteStatic';
   else
      return Texture'WhiteStatic';
}

// ----------------------------------------------------------------------
// DrawDropShadowBox()
// ----------------------------------------------------------------------

function DrawDropShadowBox(GC gc, float x, float y, float w, float h)
{
	local Color oldColor;

	gc.GetTileColor(oldColor);
	gc.SetTileColorRGB(0,0,0);
	gc.DrawBox(x, y+h+1, w+2, 1, 0, 0, 1, Texture'Solid');
	gc.DrawBox(x+w+1, y, 1, h+2, 0, 0, 1, Texture'Solid');
	gc.SetTileColor(colBorder);
	gc.DrawBox(x-1, y-1, w+2, h+2, 0, 0, 1, Texture'Solid');
	gc.SetTileColor(oldColor);
}
*/

//---END-CLASS---

defaultproperties
{
     WinOverlayTex=Texture'BowenCust.Weapons.RecticleNN'
     HostileTex=Texture'BowenCust.Weapons.RecticleH'
     FriendlyTex=Texture'BowenCust.Weapons.RecticleF'
     NeutralTex=Texture'BowenCust.Weapons.RecticleN'
     NoneTex=Texture'BowenCust.Weapons.RecticleNN'
     colBackground=(R=128,G=128,B=128)
     colBorder=(R=128,G=128,B=128)
     colHeaderText=(R=255,G=255,B=255)
     colText=(R=255,G=255,B=255)
     visionLevel=1
     visionLevelValue=1000000.000000
     margin=4.000000
     corner=9.000000
     msgLightAmpActive="LightAmp Active"
     msgIRAmpActive="IRAmp Active"
}
