//=============================================================================
// CNNEntryDoorMesh.
//
// One leaf of L2's SketchUp double doors (Entry_Doors_Double), as a mesh in
// place of its mover. Nothing opens these doors -- a sealed dark box is
// behind them -- but the mover brushes cost the most: their broken BSP draws
// a black slab well in front of the door (the same hull that stopped the
// player ~100 units short), and lit dynamically they took the frame from
// 8 ms to 30 ms. So the movers are taken out of the world, and each leaf is
// a mesh, lit per vertex, behind a row of CNNDoorBlocker cylinders.
//
// Built from the brushes by tools/brush_to_mesh.js: vertices are in world
// axes around the middle of the leaf, so this actor keeps Rotation 0 and
// stands there. Its Location must stay in the doorway: an actor whose
// Location is out of the drawn part of the level (behind a player walking
// up to the door, say) is not drawn at all.
//=============================================================================
class CNNEntryDoorMesh extends Actor;
#exec MESH IMPORT MESH=EntryDoorA ANIVFILE=Models\EntryDoorA_a.3d DATAFILE=Models\EntryDoorA_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=EntryDoorA X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=EntryDoorA STRENGTH=0.0
#exec MESH SEQUENCE MESH=EntryDoorA SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=EntryDoorA SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=EntryDoorA MESH=EntryDoorA
#exec MESHMAP SCALE MESHMAP=EntryDoorA X=0.015625 Y=0.015625 Z=0.015625

#exec MESH IMPORT MESH=EntryDoorB ANIVFILE=Models\EntryDoorB_a.3d DATAFILE=Models\EntryDoorB_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=EntryDoorB X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=EntryDoorB STRENGTH=0.0
#exec MESH SEQUENCE MESH=EntryDoorB SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=EntryDoorB SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=EntryDoorB MESH=EntryDoorB
#exec MESHMAP SCALE MESHMAP=EntryDoorB X=0.015625 Y=0.015625 Z=0.015625

var Mover door;

// ----------------------------------------------------------------------
// ReplaceDoors()
//
// Swap every mover tagged doorTag for its mesh and blockers. Runs on each
// level load; the meshes are saved with the level, so a load finds them.
// ----------------------------------------------------------------------

static function ReplaceDoors(Actor context, name doorTag)
{
    local Mover m;
    local CNNEntryDoorMesh shown, each;
    local vector middle, offset;
    local float halfWidth, x;

    foreach context.AllActors(class'Mover', m, doorTag)
    {
        shown = none;
        foreach context.AllActors(class'CNNEntryDoorMesh', each)
            if (each.door == m)
                shown = each;
        if (shown != none)
            continue;

        // The two leaves differ; the maps name them the same everywhere.
        // Offsets of the leaf's middle as printed by brush_to_mesh.js. Where
        // the leaves overlap they would flicker, so this one sits 1 unit back.
        if (m.Name == 'DeusExMover36')
        {
            middle = vect(49, -7, -33);
            halfWidth = 87.6;
        }
        else
        {
            middle = vect(79, -8, -33);
            halfWidth = 85.4;
        }
        middle += m.Location;

        shown = context.Spawn(class'CNNEntryDoorMesh',,, middle, rot(0,0,0));
        shown.door = m;
        if (m.Name == 'DeusExMover36')
            shown.Mesh = LodMesh'CNN.EntryDoorB';

        // The leaf spans X; cylinders 24 apart leave no gap a player fits in.
        for (x = -halfWidth + 12; x <= halfWidth - 12 + 0.5; x += 24)
        {
            offset.X = x;
            context.Spawn(class'CNNDoorBlocker',,, middle + offset);
        }

        m.SetCollision(false, false, false);
        m.bDynamicLightMover = false;
        m.SetLocation(m.Location - vect(0, 0, 32768));
    }
}

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=LodMesh'CNN.EntryDoorA'
    MultiSkins(0)=Texture'Airfield.Metal.AF_LiftMetl_A'
    bStatic=False
    bCollideActors=False
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False
    RemoteRole=ROLE_None
}
