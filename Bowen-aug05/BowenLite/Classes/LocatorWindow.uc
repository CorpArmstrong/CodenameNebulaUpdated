//================================================
//  LocatorWindow --- Idea contributed by Batch_File
//================================================

Class LocatorWindow extends ActorDisplayWindow;

var name ValidClass[8];
var int NoLOSRange;

enum EIFF
{
	IFF_Hostile,
	IFF_Friendly,
	IFF_Neutral,
	IFF_None,
};

/**
* Nicked and hacked from parent class
**/

function bool bValidClass(Actor a)
{
	local int i;
	for (i=0;i<8;i++)
		if (a.IsA(ValidClass[i]))
		{
		//	GetPlayerPawn().clientmessage("found" @ a @ "member of" @ ValidClass[i]);
			return true;
		}
	return false;
}

function bool AddClass(name toAdd)
{
	local int i;
	for (i=0;i<7;i++)
		if (ValidClass[i] == '' || ValidClass[i] == toAdd)
		{
			ValidClass[i] = toAdd;
			return true;
		}
	return false;
}

function bool removeClass(name toDel)
{
	local int i;
	for (i=0;i<7;i++)
		if (ValidClass[i] == toDel)
		{
			ValidClass[i] = '';
			return true;
		}
	return false;
}


static simulated function String GetDisplayName(Actor actor, optional Bool bUseFamiliar)
{
	local String displayName;

	// Sanity check
	if (actor == None)
		return "";
		
	if (DeusExProjectile(actor) != None)
		return DeusExProjectile(actor).ItemName;
		
	// If we've spoken to this person already, use the 
	// Familiar Name
	if ((actor.FamiliarName != "") && ((actor.LastConEndTime > 0) || (bUseFamiliar)))
		displayName = actor.FamiliarName;

	if ((displayName == "") && (actor.UnfamiliarName != ""))
		displayName = actor.UnfamiliarName;

	if (displayName == "")
	{
		if (actor.IsA('DeusExDecoration'))
			displayName = DeusExDecoration(actor).itemName;
		else
			displayName = actor.BindName;
	}

	return displayName;
}

/*
function SetViewClass(Class<Actor> newViewClass)
{
	validClass[7] = newViewClass;
}

function Class<Actor> GetViewClass()
{
	return ValidClass[7];
}
*/
function DrawWindow(GC gc)
{
	local float xPos, yPos;
	local float centerX, centerY;
	local float topY, bottomY;
	local float leftX, rightX;
	local int i, j, k;
	local vector tVect;
	local vector cVect;
	local vector UseLoc;
	local PlayerPawnExt player;
	local Actor trackActor;
	local ScriptedPawn trackPawn;
	local bool bValid;
	local bool bPointValid;
	local name stateName;
	local float temp;
	local string str;
	local texture skins[9];
	local EIFF IFF;
	local color mainColor;
	local float oldRenderTime;
	local float barOffset;
	local float barValue;
	local float barWidth;
	local DeusExMover dxMover;
	local bool bHaveLOS;

	if (ViewClass != None)
		Super.DrawWindow(gc);
	else
		Super(Window).DrawWindow(gc);

//	if (viewClass == None)
//		return;

	player  = GetPlayerPawn();

	if (bShowMesh)
		gc.ClearZ();
		
//	player.ClientMessage("window exists");


	foreach player.AllActors(class'Actor', trackActor)
	{
		if(!bValidClass(trackActor) || trackActor == GetPlayerPawn())
			continue;
		if (trackActor.IsA('LocatorBeacon') && trackActor.Owner != GetPlayerPawn()) // can't see other players beacons
			continue; 
			
		if (trackActor.isA('LocatorBeacon'))
			UseLoc = LocatorBeacon(trackActor).ServerPosition;
		else
			UseLoc = trackActor.Location;
		
		bHaveLOS = (player.AICanSee(trackActor, 1, false, true, bShowArea) > 0); // need a better way to do this
		
		dxMover = DeusExMover(trackActor);
		cVect.X = trackActor.CollisionRadius;
		cVect.Y = trackActor.CollisionRadius;
		cVect.Z = trackActor.CollisionHeight;
		tVect = UseLoc;
		if (bShowEyes && (Pawn(trackActor) != None))
			tVect.Z += Pawn(trackActor).BaseEyeHeight;
		if (trackActor == player)
		{
			if (player.bBehindView)
				bPointValid = ConvertVectorToCoordinates(tVect, centerX, centerY);
			else
				bPointValid = FALSE;
		}
		else if (dxMover != None)
		{
			if (!bShowLineOfSight || bHaveLOS)
				bPointValid = ConvertVectorToCoordinates(tVect, centerX, centerY);
			else
				bPointValid = FALSE;
		}
		else
		{
			if (VSize(GetPlayerPawn().Location - UseLoc) < NoLOSRange
			|| !bShowLineOfSight || bHaveLOS || trackActor.IsA('LocatorBeacon'))
				bPointValid = ConvertVectorToCoordinates(tVect, centerX, centerY);
			else
				bPointValid = FALSE;
		}

		if (bPointValid)
		{
			bValid = FALSE;
			if (bShowArea)
			{
				for (i=-1; i<=1; i+=2)
				{
					for (j=-1; j<=1; j+=2)
					{
						for (k=-1; k<=1; k+=2)
						{
							tVect = cVect;
							tVect.X *= i;
							tVect.Y *= j;
							tVect.Z *= k;
							tVect.X += UseLoc.X;
							tVect.Y += UseLoc.Y;
							tVect.Z += UseLoc.Z;
							if (ConvertVectorToCoordinates(tVect, xPos, yPos))
							{
								if (!bValid)
								{
									leftX = xPos;
									rightX = xPos;
									topY = yPos;
									bottomY = yPos;
									bValid = TRUE;
								}
								else
								{
									Extend(xPos, leftX, rightX);
									Extend(yPos, topY, bottomY);
								}
							}
						}
					}
				}
			}

			if (!bValid)
			{
				leftX = centerX-10;
				rightX = centerX+10;
				topY = centerY-10;
				bottomY = centerY+10;
				bValid = TRUE;
			}

			gc.EnableDrawing(true);
			gc.SetStyle(DSTY_Translucent);

			IFF = doIFF(trackActor, DeusExPlayer(GetPlayerPawn()));
			switch IFF
			{
				case IFF_Friendly:
					if(bHaveLOS) mainColor = colr(0,255,0);
					else mainColor = colr(32,208,32);
					break;
				case IFF_Hostile:
					if(bHaveLOS) mainColor = colr(255,0,0);
					else mainColor = colr(208,32,32);
					break;
				case IFF_Neutral:
					if(bHaveLOS) mainColor = colr(255,255,255);
					else mainColor = colr(32,32,32);
					break;
				case IFF_None:
					mainColor = colr(0,0,0);
					break;
			}
			
			gc.SetTileColor(mainColor);
			
			gc.SetTileColorRGB(mainColor.R/4, mainColor.G/4, mainColor.B/4);
			gc.DrawBox(leftX, topY, 1+rightX-leftX, 1+bottomY-topY, 0, 0, 1, Texture'Solid');
			leftX += 1;
			rightX -= 1;
			topY += 1;
			bottomY -= 1;
			gc.SetTileColorRGB(mainColor.R*3/16, mainColor.G*3/16, mainColor.B*3/16);
			gc.DrawBox(leftX, topY, 1+rightX-leftX, 1+bottomY-topY, 0, 0, 1, Texture'Solid');
			leftX += 1;
			rightX -= 1;
			topY += 1;
			bottomY -= 1;
			gc.SetTileColorRGB(mainColor.R/8, mainColor.G/8, mainColor.B/8);
			gc.DrawBox(leftX, topY, 1+rightX-leftX, 1+bottomY-topY, 0, 0, 1, Texture'Solid');

			///////Start bowen addition//////
			
			if (trackActor.IsA('LocatorBeacon'))
			{
				gc.SetTileColorRGB(255, 0, 0);
				gc.DrawPattern(centerX, centerY-2, 1, 5, 0, 0, Texture'Solid');
				gc.DrawPattern(centerX-2, centerY, 5, 1, 0, 0, Texture'Solid');
			}
			else if (trackActor.InStasis())
			{
				gc.SetTileColorRGB(0, 255, 0);
				gc.DrawPattern(centerX, centerY-2, 1, 5, 0, 0, Texture'Solid');
				gc.DrawPattern(centerX-2, centerY, 5, 1, 0, 0, Texture'Solid');
			}
			else
			{
				gc.SetTileColorRGB(0, 0, 255);
				gc.DrawPattern(centerX, centerY-3, 1, 7, 0, 0, Texture'Solid');
				gc.DrawPattern(centerX-3, centerY, 7, 1, 0, 0, Texture'Solid');
			}

			//////End bowen addition//////
			
			str = "";

/*			gc.SetStyle(DSTY_Normal);

			if (trackActor.InStasis())
			{
				gc.SetTileColorRGB(0, 255, 0);
				gc.DrawPattern(centerX, centerY-2, 1, 5, 0, 0, Texture'Solid');
				gc.DrawPattern(centerX-2, centerY, 5, 1, 0, 0, Texture'Solid');
			}
			else
			{
				gc.SetTileColorRGB(255, 255, 255);
				gc.DrawPattern(centerX, centerY-3, 1, 7, 0, 0, Texture'Solid');
				gc.DrawPattern(centerX-3, centerY, 7, 1, 0, 0, Texture'Solid');
			}
*/
				
			barOffset = 0;

			if (LocatorBeacon(trackActor) != None)
			{
				gc.SetAlignments(HALIGN_Center, VALIGN_Top);
				gc.SetFont(Font'TechSmall');
				//gc.SetTextColorRGB(visibility*255, visibility*255, visibility*255);
				gc.SetTextColorRGB(0, 255, 0);
				gc.DrawText(leftX-40, bottomY+barOffset+5, 80+rightX-leftX, 280, LocatorBeacon(trackActor).PrintDetails()); 
			/*	if (trackActor.Base != None && !trackActor.Base.IsA('LocatorBeacon'))
					trackActor = trackActor.Base;*/
			}
			///////Start bowen addition//////
			if(DeusExPlayer(trackActor) != None)
			{
				gc.SetTextColor(mainColor);
				gc.SetAlignments(HALIGN_Center, VALIGN_Bottom);
				gc.SetFont(Font'TechSmall');
				gc.DrawText(leftX-40, topY-140, 80+rightX-leftX, 135, DeusExPlayer(trackActor).PlayerReplicationInfo.PlayerName);
			}
			else if(ProxDisc(trackActor) != None || ThrownProjectile(trackActor) != None)
			{
				if (!DeusExProjectile(trackActor).bStuck)
					continue;
		//		if(ProxDisc(trackActor).Team == GetPlayerPawn().PlayerReplicationInfo.Team)
		//			continue;
				gc.SetTextColor(mainColor);
				gc.SetAlignments(HALIGN_Center, VALIGN_Bottom);
				gc.SetFont(Font'TechSmall');
				if (DeusExPlayer(trackActor.Owner) != None) 
					gc.DrawText(leftX-40, topY-140, 80+rightX-leftX, 135, GetDisplayName(trackActor) @ "set by" @  DeusExPlayer(trackActor.Owner).PlayerReplicationInfo.PlayerName);
				else 
					gc.DrawText(leftX-40, topY-140, 80+rightX-leftX, 135, GetDisplayName(trackActor) @ "unowned");
			}
			else if (DeusExDecoration(trackActor) != None)
			{
				gc.SetTextColor(mainColor);
				gc.SetAlignments(HALIGN_Center, VALIGN_Bottom);
				gc.SetFont(Font'TechSmall');
				if (DeusExPlayer(trackActor.Owner) != None) 
					gc.DrawText(leftX-40, topY-140, 80+rightX-leftX, 135, GetDisplayName(trackActor) @ "owned by" @  DeusExPlayer(trackActor.Owner).PlayerReplicationInfo.PlayerName);
				else 
					gc.DrawText(leftX-40, topY-140, 80+rightX-leftX, 135, GetDisplayName(trackActor) @ "unowned");
			}
			else	///////End bowen addition//////
			{
				gc.SetTextColor(mainColor);
				gc.SetAlignments(HALIGN_Center, VALIGN_Bottom);
				gc.SetFont(Font'TechSmall');
				gc.DrawText(leftX-40, topY-140, 80+rightX-leftX, 135, GetDisplayName(trackActor));
			}
		}
	}
}

static simulated function EIFF DoIff(Actor Other, DeusExPlayer p, optional bool bRecursed)
{
	
	if(Other != None)
	{
		if(Other.IsA('ScriptedPawn'))
		{
			if(ScriptedPawn(Other).IsValidEnemy(p))
				return IFF_Hostile;
			else
				return IFF_Friendly;
		}
		else if (Other.IsA('DeusExPlayer'))
		{
			if (Other == p)
				return IFF_Friendly;
			else if (TeamDMGame(p.DXGame) != None)	
			{
				if(DeusExPlayer(Other).PlayerReplicationInfo.team == p.PlayerReplicationInfo.Team)
					return IFF_Friendly;
				else
					return IFF_Hostile;
			}
			else return IFF_Hostile;
		}
		else if (!bRecursed && DeusExPlayer(Other.Owner) != None) 
			return DoIFF(Other.Owner, p, True);
		else
			return IFF_Neutral;
	}
	
	return IFF_None;
}

static function color colr ( byte R, byte G, byte B )
{
	local color col;
	col.R = R;
	col.G = G;
	col.B = B;
	return col;
}


DefaultProperties
{
	NoLOSRange=1024
}