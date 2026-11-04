/*
 * t3d_example_bsp.js - a small level showing the BSP brush kinds of t3d_write.js:
 * a hall with cylinder pillars, stairs, a ramp, a ladder tower and a balcony, a pool,
 * a semisolid pipe and a masked grate; a corridor to a rotunda under a sky zone, with a
 * glass window into a closet; a guard patrolling hall to rotunda.
 *
 *   node tools/t3d_example_bsp.js Lesson.t3d
 *
 * Then in UnrealEd, by tools/cnn_edcmd.ps1:
 *   OBJ LOAD FILE=..\..\..\Textures\<package>.utx PACKAGE=<package>   for each of PACKAGES
 *   MAP IMPORTADD FILE=Lesson.t3d, MAP REBUILD, LIGHT APPLY, PATHS DEFINE,
 *   MAP SAVE FILE=71_BspExample.dx
 */
const fs = require('fs');
const {PF, builder, box, prism, wedge, stairs, sheet, zonePortal, waterSurface, mover, actor, map} = require('./t3d_write');

const PACKAGES = ['CoreTexMetal', 'CoreTexConcrete', 'CoreTexGlass', 'CoreTexSky', 'CoreTexWater'];
const HALL = {top: 'ClenGrayMetal_B', bottom: 'DiamPlatSteel_A', side: 'DrtyCastCemnt_A'};
const ROUND = {top: 'ClenGrayCemnt_B', bottom: 'ClenGrayCemnt_C', side: 'ClenGrayCemnt_D'};
const METAL = 'StanGrayMetal_A';
const nav = (z = 0) => z + 15; // see t3d_write.js: nodes stand 15 above the floor

const light = (name, loc, brightness = 160, radius = 48, hue = 0, saturation = 255) =>
    actor('Light', name, loc, `LightBrightness=${brightness}\nLightRadius=${radius}\nLightHue=${hue}\nLightSaturation=${saturation}`);
const patrol = (name, tag, next, loc) => actor('PatrolPoint', name, loc, `Tag=${tag}\nNextpatrol=${next}\npausetime=1`);

const parts = [
    builder(),

    // Rooms, carved out of the solid world.
    box('Hall', 'CSG_Subtract', [0, 0, 192], [1024, 1024, 384], HALL),
    box('Corridor', 'CSG_Subtract', [0, -600, 64], [128, 200, 128], HALL),
    prism('Rotunda', 'CSG_Subtract', [0, -900, 128], 16, 256, 256, ROUND, {faceFlags: {top: PF.FakeBackdrop}}),
    box('Closet', 'CSG_Subtract', [192, -580, 64], [192, 120, 128], ROUND),
    box('WindowHole', 'CSG_Subtract', [80, -600, 72], [32, 80, 80], METAL),
    box('Pool', 'CSG_Subtract', [-300, -300, -64], [192, 192, 128], {top: '', bottom: 'ClenGrayCemnt_B', side: 'ClenGrayCemnt_B'}),

    // Solids added back into them.
    prism('PillarA', 'CSG_Add', [200, -200, 192], 12, 32, 384, METAL),
    prism('PillarB', 'CSG_Add', [-100, -200, 192], 12, 32, 384, METAL),
    box('Balcony', 'CSG_Add', [0, 384, 64], [1024, 256, 128], METAL),
    stairs('Step', 'CSG_Add', {x: 0, y: 0, z: 0, width: 128}, 8, METAL),
    wedge('Ramp', 'CSG_Add', [350, 128, 64], [128, 256, 128], METAL),
    // A ladder is any solid surface of a texture in group Ladder; t3d_write's ladder() adds rungs.
    box('Tower', 'CSG_Add', [-448, 0, 128], [128, 128, 256], {top: METAL, bottom: METAL, side: METAL, px: 'LadrBrwnMetal'}),

    // Brushes that do not cut the world as solids.
    box('Pipe', 'CSG_Add', [0, -350, 340], [1024, 16, 16], METAL, {flags: PF.Semisolid}),
    sheet('Grate', [175, 256, 152], 'XZ', 150, 48, 'metalgrate_a', PF.Masked | PF.NotSolid | PF.TwoSided),
    waterSurface('PoolSurface', [-300, -300, -16], 192, 192, 'bluewater'),
    actor('WaterZone', 'PoolZone', [-300, -300, -70]),
    // Past the window: at Y -625 the window and closet make a way round it and the zone leaks.
    zonePortal('RotundaDoor', [0, -645, 64], 128, 128, 'XZ'),
    actor('ZoneInfo', 'RotundaZone', [0, -900, 200], 'ZoneName="Rotunda"'),

    // A window into the closet, which has no other way in.
    mover('BreakableGlass', 'Window', [80, -600, 72], [2, 80, 80], 'LiteGrenGlass_A', [0, 0, 0], 'bBreakable=True', {flags: PF.Translucent}),

    // A sky zone away from the level. The rotunda's ceiling is drawn with it (FakeBackdrop).
    box('SkyBox', 'CSG_Subtract', [6000, 6000, 0], [1024, 1024, 1024],
        {top: 'ClenCloudBank_B', bottom: 'ClenCloudBank_B', side: 'FlufBlueCloud_B'}, {flags: PF.Unlit}),
    actor('SkyZoneInfo', 'Sky', [6000, 6000, 0]),

    actor('DeusExLevelInfo', 'LevelInfoDX', [-450, -450, 48], 'MapName="71_BspExample"\nMapAuthor="CNN example"\nMissionLocation="Example"\nmissionNumber=71'),
    actor('PlayerStart', 'Start', [-300, 150, 48]),
    light('HallA', [0, 0, 340]), light('HallB', [-300, -300, 340]), light('HallC', [300, 300, 340]),
    light('Balcony', [0, 384, 300], 120, 32, 30, 128),
    light('Hallway', [0, -600, 110], 128, 16, 30, 128),
    light('RotundaL', [0, -900, 200], 180, 48),
    light('ClosetL', [192, -580, 110], 200, 24, 10, 64),

    actor('PathNode', 'NodeHall', [-200, 100, nav()]),
    actor('PathNode', 'NodeStairsFoot', [0, -50, nav()]),
    actor('PathNode', 'NodeStairsTop', [0, 300, nav(128)]),
    actor('PathNode', 'NodeRampFoot', [350, -60, nav()]),
    actor('PathNode', 'NodeRampTop', [350, 300, nav(128)]),
    actor('PathNode', 'NodeTowerFoot', [-300, 0, nav()]),
    patrol('PatrolHall', 'PP1', 'PP2', [50, -300, nav()]),
    patrol('PatrolHallway', 'PP2', 'PP3', [0, -600, nav()]),
    patrol('PatrolRotunda', 'PP3', 'PP1', [0, -900, nav()]),
    actor('Male1', 'Guard', [50, -250, 48], 'Orders=Patrolling\nOrderTag=PP1\nbAlwaysPatrol=True\nBindName="ExampleGuard"\nFamiliarName="Guard"\nUnfamiliarName="Guard"'),
];

if (require.main === module) {
    fs.writeFileSync(process.argv[2] || 'BspExample.t3d', map(parts));
    console.log('load:', PACKAGES.join(' '));
}
