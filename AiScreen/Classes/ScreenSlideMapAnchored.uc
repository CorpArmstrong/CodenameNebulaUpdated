// ============================================================================
// ScreenSlideMapAnchored
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlideMap anchored at a given actor.
// ============================================================================


class ScreenSlideMapAnchored extends ScreenSlideMap;


// ============================================================================
// Properties
// ============================================================================

var() Actor ViewportAnchor;
var() float ViewportAnchorPositionHorz;
var() float ViewportAnchorPositionVert;
var() bool  ViewportDirectional;
var() float ViewportScale;


// ============================================================================
// Variables
// ============================================================================

var vector LocationAnchorAck;
var rotator RotationAnchorAck;

var coords CoordsAnchor;
var int OffsetTopAnchor;
var int OffsetLeftAnchor;
var float ScaleViewport;


// ============================================================================
// Update
// ============================================================================

simulated function Update() {

  local GameReplicationInfo InfoGame;
  local PlayerReplicationInfo InfoPlayer;
  local int IndexInfo;
  local vector VectorNormal;
  local vector VectorNormalProj;
  local vector VectorAnchorHorz;
  local vector VectorAnchorHorzProj;
  local vector VectorAnchorVert;
  local vector VectorAnchorVertProj;

  Super.Update();

  LocationAnchorAck = ViewportAnchor.Location;
  RotationAnchorAck = ViewportAnchor.Rotation;

  switch (CoordHorz) {
    case CoordSelection_X:  CoordsAnchor.XAxis = vect(1.0, 0.0, 0.0);  break;
    case CoordSelection_Y:  CoordsAnchor.XAxis = vect(0.0, 1.0, 0.0);  break;
    case CoordSelection_Z:  CoordsAnchor.XAxis = vect(0.0, 0.0, 1.0);  break;
    }

  switch (CoordVert) {  
    case CoordSelection_X:  CoordsAnchor.YAxis = vect(1.0, 0.0, 0.0);  break;
    case CoordSelection_Y:  CoordsAnchor.YAxis = vect(0.0, 1.0, 0.0);  break;
    case CoordSelection_Z:  CoordsAnchor.YAxis = vect(0.0, 0.0, 1.0);  break;
    }

  OffsetTopAnchor  = ClientHeight * ViewportAnchorPositionVert;
  OffsetLeftAnchor = ClientWidth  * ViewportAnchorPositionHorz;

  CoordsAnchor.Origin = LocationAnchorAck;
  
  if (ViewportDirectional) {
    if (CoordHorz == CoordVert)
      return;

    VectorNormal     = (CoordsAnchor.YAxis cross CoordsAnchor.XAxis) >> RotationAnchorAck >> rot(0, 16384, 0);
    VectorAnchorHorz =  CoordsAnchor.XAxis                           >> RotationAnchorAck >> rot(0, 16384, 0);
    VectorAnchorVert =  CoordsAnchor.YAxis                           >> RotationAnchorAck >> rot(0, 16384, 0);
  
    VectorNormalProj     = (VectorNormal     dot CoordsAnchor.XAxis) * CoordsAnchor.XAxis +
                           (VectorNormal     dot CoordsAnchor.YAxis) * CoordsAnchor.YAxis;
    VectorAnchorHorzProj = (VectorAnchorHorz dot CoordsAnchor.XAxis) * CoordsAnchor.XAxis +
                           (VectorAnchorHorz dot CoordsAnchor.YAxis) * CoordsAnchor.YAxis;
    VectorAnchorVertProj = (VectorAnchorVert dot CoordsAnchor.XAxis) * CoordsAnchor.XAxis +
                           (VectorAnchorVert dot CoordsAnchor.YAxis) * CoordsAnchor.YAxis;
  
    CoordsAnchor.XAxis = Normal(VectorAnchorHorzProj * (1 - VectorAnchorHorz dot VectorNormal) -
                                VectorNormalProj     *     (VectorAnchorHorz dot VectorNormal));
    CoordsAnchor.YAxis = Normal(VectorAnchorVertProj * (1 - VectorAnchorVert dot VectorNormal) -
                                VectorNormalProj     *     (VectorAnchorVert dot VectorNormal));

    if (ViewportScale == 0.0)
      ScaleViewport = 1.0 / 16.0;
    else
      ScaleViewport = ViewportScale;
    }

  else {
    if (ViewportScale > 0.0)
      ScaleViewport = ViewportScale;
    else
      if (Map == None)
        ScaleViewport = 1.0 / 16.0;
      else
        ScaleViewport = float(Map.USize) / (MapRight - MapLeft);
    }

  CoordsAnchor.XAxis *= ScaleViewport;
  CoordsAnchor.YAxis *= ScaleViewport;
  }


// ============================================================================
// CalcOffset
// ============================================================================

simulated function bool CalcOffset(vector VectorItem, optional out int OffsetLeftItem,
                                                      optional out int OffsetTopItem) {

  local float CoordDepthItem;

  CoordDepthItem = Component(VectorItem - LocationAnchorAck, CoordDepth);

  if (CoordDepthMin < CoordDepthMax && CoordDepthItem != Clamp(CoordDepthItem, CoordDepthMin, CoordDepthMax))
    return false;

  OffsetLeftItem = (VectorItem - CoordsAnchor.Origin) dot CoordsAnchor.XAxis + OffsetLeftAnchor;
  OffsetTopItem  = (VectorItem - CoordsAnchor.Origin) dot CoordsAnchor.YAxis + OffsetTopAnchor;

  return (OffsetLeftItem == Clamp(OffsetLeftItem, 0, ClientWidth)) &&
         (OffsetTopItem  == Clamp(OffsetTopItem,  0, ClientHeight));
  }


// ============================================================================
// DrawMap
// ============================================================================

simulated function DrawMap(ScriptedTexture TextureCanvas, int Left, int Top) {

  if (Map == None)
    return;

  TextureCanvas.DrawTile(Left, Top, ClientWidth, ClientHeight,
                         (CoordsAnchor.Origin.X - MapLeft) * ScaleViewport - OffsetLeftAnchor,
                         (CoordsAnchor.Origin.Y - MapTop)  * ScaleViewport - OffsetTopAnchor,
                         ClientWidth  / ScaleViewport / (MapRight  - MapLeft) * Map.USize,
                         ClientHeight / ScaleViewport / (MapBottom - MapTop)  * Map.VSize,
                         Map, Map.bMasked);
  }


// ============================================================================
// Destroyed
// ============================================================================

simulated event Destroyed() {

  if (TextureBackgroundAck != None)
    TextureBackgroundAck.AnimNext = TextureBackgroundNext;
  if (TextureIconsAck != None)
    TextureIconsAck.AnimNext = TextureIconsNext;

  Super.Destroyed();
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    ViewportAnchorPositionHorz=0.50
    ViewportAnchorPositionVert=0.50
}
