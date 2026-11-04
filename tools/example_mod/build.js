/*
 * build.js - generate a small mod from nothing: package LessonMod with text and conversations,
 * and the level 72_Interact that uses them. It has the devices of Steve Tack's tutorials: doors,
 * a lock, a nanokey, a keypad, a security console with a camera and a turret, computers,
 * information devices, items, an NPC to talk to and an enemy.
 *
 *   node tools/example_mod/build.js <out folder>
 *
 * <out>\LessonMod\... goes under the game's root (ucc make looks in ..\LessonMod\Classes), and
 * <out>\72_Interact.t3d is built like tools/t3d_example_bsp.js. See tools/example_mod/README.md
 * for the steps.
 */
const fs = require('fs');
const path = require('path');
const {PF, builder, box, ladder, mover, actor, map} = require('../t3d_write');
const C = require('../con_write');

const PACKAGES = ['CoreTexMetal', 'CoreTexConcrete', 'CoreTexGlass', 'CoreTexMisc'];
const WALLS = {top: 'ClenGrayMetal_B', bottom: 'DiamPlatSteel_A', side: 'DrtyCastCemnt_A'};
const OFFICE = {top: 'ClenGrayCemnt_B', bottom: 'ClenGrayCemnt_C', side: 'ClenGrayCemnt_D'};
const METAL = 'StanGrayMetal_A';
const TEXT = 'TextPackage="LessonMod"';

const light = (name, loc, brightness = 170, radius = 40, hue = 0, saturation = 255) =>
  actor('Light', name, loc, `LightBrightness=${brightness}\nLightRadius=${radius}\nLightHue=${hue}\nLightSaturation=${saturation}`);
const node = (name, x, y, z = 0) => actor('PathNode', name, [x, y, z + 15]);

// A hinged door across X, closed along the Y wall. Locks and keys are in its props.
const door = (cls, name, tag, y, tex, props) =>
  mover(cls, name, [-40, y, 56], [80, 8, 112], tex, [-40, 0, 0],
    `Tag=${tag}\nbIsDoor=True\nbHighlight=True\nNumKeys=2\nKeyRot(1)=(Yaw=16384)\nMoveTime=1.000000\n${props}`);

// Stock windows: the two big faces are drawn, added to what is behind them, so a dark texture
// is nearly invisible (07WindOpacStrek, average 10 of 255, is the usual one). The edges only collide.
const glassFaces = {faceFlags: {
  px: PF.Translucent | PF.Unlit, nx: PF.Translucent | PF.Unlit,
  py: PF.Invisible | PF.Semisolid, ny: PF.Invisible | PF.Semisolid, top: PF.Invisible | PF.Semisolid, bottom: PF.Invisible | PF.Semisolid,
}};
const pane = (name, y, tex, props = 'bBreakable=True') =>
  mover('BreakableGlass', name, [-412, y, 72], [2, 80, 96], {top: tex, bottom: tex, side: tex}, [0, 0, 0], props, glassFaces);

const parts = [
  builder(),

  box('Hall', 'CSG_Subtract', [0, 400, 128], [800, 800, 256], WALLS),
  box('Closet', 'CSG_Subtract', [-536, 300, 100], [224, 400, 200], OFFICE),
  box('WinA', 'CSG_Subtract', [-412, 180, 72], [24, 80, 96], METAL),
  box('WinB', 'CSG_Subtract', [-412, 300, 72], [24, 80, 96], METAL),
  box('WinC', 'CSG_Subtract', [-412, 420, 72], [24, 80, 96], METAL),
  box('DoorHoleA', 'CSG_Subtract', [0, 816, 56], [80, 32, 112], METAL),
  box('SecurityRoom', 'CSG_Subtract', [0, 1200, 112], [700, 736, 224], WALLS),
  box('DoorHoleB', 'CSG_Subtract', [0, 1584, 56], [80, 32, 112], METAL),
  box('Office', 'CSG_Subtract', [0, 1936, 112], [700, 704, 224], OFFICE),
  box('DoorHoleC', 'CSG_Subtract', [0, 2304, 56], [80, 32, 112], METAL),
  box('Vault', 'CSG_Subtract', [0, 2576, 112], [500, 512, 224], WALLS),

  // Up the east wall to a ledge.
  box('Ledge', 'CSG_Add', [340, 680, 96], [120, 240, 192], METAL),
  ladder('LadderEast', 396, 400, 96, 192),

  pane('WindowDark', 180, '07WindOpacStrek'),
  pane('WindowFrost', 300, 'FrosWhitGlass_A'),
  pane('WindowHard', 420, 'SafeGrenGlass_A', 'bBreakable=False'),

  door('DeusExMover', 'DoorKey', 'Door1', 816, METAL, 'bLocked=True\nbPickable=True\nlockStrength=0.100000\nKeyIDNeeded=LabKey\ndoorStrength=0.250000'),
  door('DeusExMover', 'DoorCode', 'Door2', 1584, METAL, 'bLocked=True\nbPickable=False\nbBreakable=False'),
  mover('DeusExMover', 'VaultDoor', [0, 2304, 56], [80, 16, 112], METAL, [0, 0, 0],
    'Tag=VaultDoor\nbFrobbable=False\nbBreakable=False\nbPickable=False\nNumKeys=2\nKeyPos(1)=(Z=108.000000)\nInitialState=TriggerToggle\nMoveTime=1.000000'),

  actor('DeusExLevelInfo', 'LevelInfoDX', [-300, 60, 48], 'MapName="72_Interact"\nMapAuthor="CNN example"\nMissionLocation="Example"\nmissionNumber=72\nConversationPackage="LessonMod"'),
  actor('PlayerStart', 'Start', [0, 100, 48], 'Rotation=(Yaw=16384)'),
  box('Desk', 'CSG_Add', [-320, 1936, 20], [40, 120, 40], METAL),
  light('HallA', [0, 300, 230]), light('HallB', [250, 600, 230]), light('HallC', [-250, 600, 230]), light('LadderLight', [300, 450, 180], 200, 32),
  light('ClosetLight', [-536, 300, 170], 255, 32, 90, 64),
  light('SecurityA', [0, 1000, 200]), light('SecurityB', [0, 1400, 200]),
  actor('TriggerLight', 'OfficeLight', [0, 1936, 200], 'Tag=OfficeLight\nInitialState=TriggerToggle\nbInitiallyOn=False\nbStatic=False\nbNoDelete=False\nbMovable=True\nLightType=LT_Steady\nLightBrightness=200\nLightRadius=48\nLightSaturation=255'),
  light('OfficeDim', [0, 1700, 200], 90, 32),
  light('VaultLight', [0, 2576, 200]),

  // Items to pick up in the hall, in a row.
  actor('WeaponCrowbar', 'Crowbar', [-100, 100, 16]),
  actor('Lockpick', 'Pick', [-60, 100, 8]),
  actor('Multitool', 'Tool', [-20, 100, 8]),
  actor('MedKit', 'Kit', [60, 100, 8]),
  actor('NanoKey', 'Key', [100, 100, 8], 'KeyID=LabKey\nDescription="Lab door key"\nSkinColor=SC_Level2'),
  actor('DataCube', 'Cube', [140, 100, 8], `textTag=72_DataCube01\n${TEXT}`),
  actor('BookClosed', 'Book', [180, 100, 8], `textTag=72_Book01\n${TEXT}`),
  actor('CrateBreakableMedGeneral', 'Crate', [-250, 150, 32]),

  // The NPC and the conversations (BindName joins them).
  actor('ScientistMale', 'Tech', [200, 500, 48], 'BindName="LabTech"\nFamiliarName="Dr. Lab"\nUnfamiliarName="Lab Tech"\nOrders=Standing\nbInvincible=True'),
  actor('DataLinkTrigger', 'Infolink', [0, 240, 40], 'datalinkTag=DL_Welcome\nCollisionRadius=120.000000\nCollisionHeight=60.000000'),

  // Security room: console -> camera, door, turret. The camera raises the turret by its Event.
  actor('SecurityCamera', 'Cam', [320, 1550, 190], 'Tag=Cam1\nEvent=Turret1\nRotation=(Pitch=-4096,Yaw=-24576)\nbSwing=True'),
  actor('AutoTurret', 'Turret', [-300, 1500, 205], 'Tag=Turret1\nbActive=False\nRotation=(Roll=32768)\nammoAmount=50'),
  actor('AlarmUnit', 'Alarm', [-340, 1500, 90], 'Rotation=(Yaw=0)'),
  actor('ComputerSecurity', 'Console', [-340, 1200, 60], `Rotation=(Yaw=0)\nuserList(0)=(userName="GUARD",password="ICE")\nViews(0)=(titleString="Security room",cameraTag=Cam1,turretTag=Turret1,doorTag=Door2)\nComputerNode=CN_MJ12Net\n${TEXT}`),
  actor('Keypad1', 'Keypad', [70, 1565, 64], 'Event=Door2\nvalidCode="0451"\nRotation=(Yaw=-16384)\nhackStrength=0.200000'),

  // Office: a computer opens the vault; a switch works the light.
  actor('LightSwitch', 'Switch', [-70, 1603, 64], 'Event=OfficeLight\nRotation=(Yaw=16384)'),
  actor('ComputerPersonal', 'Pc', [-322, 1936, 70], `Rotation=(Yaw=0)\nuserList(0)=(userName="TECH",password="LAB")\nspecialOptions(0)=(Text="Open vault",TriggerText="Vault door moved.",userName="TECH",TriggerEvent=VaultDoor)\n${TEXT}`),
  actor('ComputerPublic', 'Terminal', [330, 1936, 50], `Rotation=(Yaw=32768)\nbulletinTag=72_BulletinMenu\n${TEXT}`),

  // Vault: an enemy, by alliance.
  actor('MJ12Troop', 'Guard', [0, 2700, 48], 'Rotation=(Yaw=-16384)\nOrders=Standing\nAlliance=mj12\nInitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1.000000,bPermanent=True)\nBindName="VaultGuard"'),

  node('NodeHall', 0, 300), node('NodeHallEast', 200, 400), node('NodeDoorA', 0, 760), node('NodeSecurity', 0, 900), node('NodeSecurityN', 0, 1500),
  node('NodeOffice', 0, 1700), node('NodeOfficeN', 0, 2200), node('NodeVault', 0, 2400),
];

const conversations = C.conFile({missions: [72], audioPackage: 'Mission72', author: 'Claude'}, [
  C.con('MeetLabTech', 'LabTech', {}, [
    C.ifFlags([['MetLabTech']], 'Again'),
    C.say('LabTech', 'Tantalus', 'You must be the new inspector. Nobody told me you were coming.'),
    C.say('Tantalus', 'LabTech', 'Nobody tells anyone anything here.'),
    C.setFlags(['MetLabTech']),
    C.addGoal('FindVault', 'Find out what the vault guard is protecting.'),
    C.at('Again', C.say('LabTech', 'Tantalus', 'What do you need?')),
    C.at('Menu', C.choice([
      ['The door code?', 'Code'],
      ['Anything for the road?', 'Gift', {flags: [['LabTechGift', false]]}],
      ['Tell me about the vault.', 'Vault'],
      ['Later.', 'Bye'],
    ])),
    C.at('Code', C.say('Tantalus', 'LabTech', 'The door code?')),
    C.say('LabTech', 'Tantalus', 'Zero four five one. Same as every other door in this business.'),
    C.addNote('Door code from the lab tech: 0451'),
    C.jump('Menu'),
    C.at('Gift', C.say('Tantalus', 'LabTech', 'Anything for the road?')),
    C.say('LabTech', 'Tantalus', 'Take these. And a little something for your trouble.'),
    C.transfer('Multitool', 'LabTech', 'Tantalus', 2, 'Full'),
    C.addCredits(100),
    C.addSkillPoints(50, 'Made a friend'),
    C.setFlags(['LabTechGift']),
    C.jump('Menu'),
    C.at('Full', C.say('LabTech', 'Tantalus', 'Your pockets are full. Come back.')),
    C.jump('Menu'),
    C.at('Vault', C.say('Tantalus', 'LabTech', 'Tell me about the vault.')),
    C.say('LabTech', 'Tantalus', 'The office computer opens it. The guard is not as friendly as I am.'),
    C.completeGoal('FindVault'),
    C.jump('Menu'),
    C.at('Bye', C.say('Tantalus', 'LabTech', 'Later.')),
    C.end(),
  ]),
  // While a bark with the player in it plays, a frob on its owner is refused (DeusExPlayer.StartConversation).
  C.con('LabTechBark', 'LabTech', {firstPerson: true, nonInteractive: true, radius: 160, frob: false, bump: false, displayOnce: true, flags: [['MetLabTech', false]]}, [
    C.say('LabTech', 'Tantalus', 'Over here, please.'),
  ]),
  C.con('DL_Welcome', 'Tantalus', {dataLink: true, displayOnce: true}, [
    C.say('LabTech', 'Tantalus', 'Inspector, this is the lab. Pick up what you need and come talk to me.'),
  ]),
]);

const files = {
  '72_DataCube01.txt': '<P>The vault door answers to the office computer.\n<P>\n<P>User TECH, password LAB.\n',
  '72_Book01.txt': '<JC>A Short History of Doors</JC>\n<P>\n<P>Most of them open.\n',
  '72_Email01.txt': '<P>Tech,\n<P>\n<P>Stop leaving the code on datacubes.\n<P>\n<P>Security\n',
  '72_EmailMenu_TECH.txt': '<EMAIL=72_Email01,Codes,Security,TECH,>\n',
  '72_Bulletin01.txt': '<P>Welcome\n<P>\n<P>Non-authorized personnel will be asked politely.\n',
  '72_BulletinMenu.txt': '<COMMENT>Lab</COMMENT>\n<FILE=72_Bulletin01,Welcome>\n',
};

if (require.main === module) {
  const out = process.argv[2];
  if (!out) { console.log('usage: build.js <out folder>'); process.exit(2); }
  const pkg = path.join(out, 'LessonMod');
  ['Classes', 'Conversations', 'Text'].forEach((d) => fs.mkdirSync(path.join(pkg, d), {recursive: true}));
  fs.writeFileSync(path.join(pkg, 'Conversations', 'Mission72.con'), conversations);
  Object.entries(files).forEach(([n, t]) => fs.writeFileSync(path.join(pkg, 'Text', n), t.replace(/\n/g, '\r\n')));
  fs.writeFileSync(path.join(pkg, 'Classes', 'ImportConversations.uc'),
    'class ImportConversations expands Object\n\tabstract;\n\n#exec CONVERSATION IMPORT FILE="Conversations\\Mission72.con"\n');
  fs.writeFileSync(path.join(pkg, 'Classes', 'TextImport.uc'),
    'class TextImport expands Object\n\tabstract;\n\n' + Object.keys(files).map((n) => `#exec DEUSEXTEXT IMPORT FILE=Text\\${n}\n`).join(''));
  fs.writeFileSync(path.join(out, '72_Interact.t3d'), map(parts));
  console.log('load:', PACKAGES.join(' '));
}
