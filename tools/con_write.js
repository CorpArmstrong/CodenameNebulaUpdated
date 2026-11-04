/*
 * con_write.js - write a .con from a short description, without ConEdit.
 * tools/con_format.js holds the file layout; tools/example_mod/ uses this.
 *
 *   conFile({missions: [72], audioPackage: 'Mission72'}, [
 *     con('MeetTech', 'LabTech', {radius: 200}, [
 *       say('LabTech', 'JCDenton', 'Hello.'),
 *       choice([['Who are you?', 'Who'], ['Bye.', 'Bye', {flags: [['Met', true]]}]]),
 *       at('Who', say('LabTech', 'JCDenton', 'Nobody.')),
 *       at('Bye', end()),
 *     ]),
 *   ])
 *
 * The owner and the speakers are BindNames. Options of con(): displayOnce, firstPerson,
 * nonInteractive (bark: set both), dataLink, frob (default on), bump (default on), radius,
 * flags: [[name, value], ...] that must hold for it to start.
 * info.speakChoices has the engine say a chosen line itself: it does so as actor JCDenton, so
 * only when the player's BindName is JCDenton. With any other BindName (ours is Tantalus) a
 * conversation holding such a choice fails CheckActors and a frob will not start it; leave it
 * off and write the player's line as the first speech after the label.
 * An End is added when the last event is not one. A label jumped to must exist: checked here,
 * since a bad one would only show in the game. Names in transfer() and hasItem() are looked
 * up in package DeusEx only, see CLAUDE.md.
 */
'use strict';
const {build, ET} = require('./con_format');

const TRUE = -1;
const boolOf = (v) => (v ? TRUE : 0);

// VB's Date: days since 1899-12-30, as a double.
function vbNow() {
  const b = Buffer.alloc(8);
  b.writeDoubleLE(Date.now() / 86400000 + 25569);
  return b.toString('hex');
}

const flagList = (a = []) => a.map(([name, value = true, expiration = 0]) => ({name, value: boolOf(value), expiration}));

const say = (speaker, to, speech) => ({kind: 'Speech', speaker, to, speech});
const choice = (choices, clearScreen = true) => ({kind: 'Choice', clearScreen, choices});
const setFlags = (...flags) => ({kind: 'SetFlag', flags: flagList(flags)});
const ifFlags = (flags, target) => ({kind: 'CheckFlag', flags: flagList(flags), target});
const hasItem = (object, failLabel) => ({kind: 'CheckObject', object, failLabel});
const transfer = (object, from, to, count = 1, failLabel = '') => ({kind: 'TransferObject', object, from, to, count, failLabel});
const camera = (position, transition = -1) => ({kind: 'MoveCamera', position, transition});
const jump = (target) => ({kind: 'Jump', target});
const random = (labels, opts = {}) => ({kind: 'Random', labels, ...opts});
const trigger = (tag) => ({kind: 'Trigger', tag});
const addGoal = (goal, text, primary = false) => ({kind: 'AddGoal', goal, text, primary});
const completeGoal = (goal) => ({kind: 'AddGoal', goal, completed: true});
const addNote = (text) => ({kind: 'AddNote', text});
const addSkillPoints = (points, message = '') => ({kind: 'AddSkillPoints', points, message});
const addCredits = (credits) => ({kind: 'AddCredits', credits});
const comment = (text) => ({kind: 'Comment', text});
const end = () => ({kind: 'End'});
const at = (label, event) => ({...event, label});

const con = (name, owner, opts, events) => ({name, owner, opts: opts || {}, events});

function conFile(info, conversations) {
  const tableOf = () => {
    const rows = new Map();
    const ref = (name) => { if (!rows.has(name)) rows.set(name, rows.size); return {id: rows.get(name), name}; };
    return {ref, rows: () => [...rows].map(([name, id]) => ({id, name}))};
  };
  const actors = tableOf(), flagTable = tableOf(), skills = tableOf(), objects = tableOf();
  const flags = (a) => a.map((f) => ({flag: flagTable.ref(f.name), value: f.value, expiration: f.expiration}));
  const stamp = vbNow(), author = info.author || 'con_write';

  const eventOf = (e, i, name) => {
    const base = {id: i, next: i + 1, type: ET[e.kind], label: e.label || ''};
    switch (e.kind) {
      case 'Speech': return {...base, speaker: actors.ref(e.speaker), speakingTo: actors.ref(e.to), speech: e.speech, audio: '', continued: 0, bold: 0, font: 0};
      case 'Choice': return {...base, slots: e.choices.length, clearScreen: boolOf(e.clearScreen), choices: e.choices.map(([text, label, o = {}], index) => ({
        index, text, displayAsSpeech: boolOf(info.speakChoices), label, audio: '', flags: flags(flagList(o.flags)),
        ...(o.skill ? {skill: skills.ref(o.skill), skillLevel: o.skillLevel || 0} : {}),
      }))};
      case 'SetFlag': return {...base, flags: flags(e.flags)};
      case 'CheckFlag': return {...base, flags: flags(e.flags), setLabel: e.target};
      case 'CheckObject': return {...base, object: objects.ref(e.object), failLabel: e.failLabel};
      case 'TransferObject': return {...base, object: objects.ref(e.object), count: e.count, from: actors.ref(e.from), to: actors.ref(e.to), failLabel: e.failLabel};
      case 'MoveCamera': return {...base, cameraType: 0, position: e.position, transition: e.transition};
      case 'Jump': return {...base, target: e.target, conId: e.conId === undefined ? -1 : e.conId};
      case 'Random': return {...base, labels: e.labels, cycle: boolOf(e.cycle), cycleOnce: boolOf(e.cycleOnce), cycleRandom: boolOf(e.cycleRandom)};
      case 'Trigger': return {...base, tag: e.tag};
      case 'AddGoal': return e.completed ? {...base, goal: e.goal, completed: TRUE} : {...base, goal: e.goal, completed: 0, text: e.text, primary: boolOf(e.primary)};
      case 'AddNote': return {...base, text: e.text};
      case 'AddSkillPoints': return {...base, points: e.points, message: e.message};
      case 'AddCredits': return {...base, credits: e.credits};
      case 'Comment': return {...base, text: e.text};
      case 'End': return base;
      default: throw new Error(`${name}: unknown event ${e.kind}`);
    }
  };

  const records = conversations.map((c, id) => {
    const o = c.opts;
    const list = c.events.slice();
    if (!list.length || list[list.length - 1].kind !== 'End') list.push(end());
    const labels = new Set(list.map((e) => e.label).filter(Boolean));
    const need = (l, what) => { if (l && !labels.has(l)) throw new Error(`${c.name}: ${what} goes to a label that does not exist: ${l}`); };
    list.forEach((e) => {
      if (e.kind === 'Choice') e.choices.forEach((x) => need(x[1], 'a choice'));
      if (e.kind === 'CheckFlag' || (e.kind === 'Jump' && e.conId === undefined)) need(e.target, e.kind);
      if (e.kind === 'CheckObject' || e.kind === 'TransferObject') need(e.failLabel, e.kind);
      if (e.kind === 'Random') e.labels.forEach((l) => need(l, 'a random'));
    });
    return {
      a: list.length, id, name: c.name, description: o.description || '', created: stamp, createdBy: author, modified: stamp, modifiedBy: author,
      owner: actors.ref(c.owner), dataLink: boolOf(o.dataLink), notes: '',
      displayOnce: boolOf(o.displayOnce), firstPerson: boolOf(o.firstPerson), nonInteractive: boolOf(o.nonInteractive), randomCamera: 0,
      canBeInterrupted: 0, cannotBeInterrupted: 0, invokeBump: boolOf(o.bump !== false && !o.dataLink), invokeFrob: boolOf(o.frob !== false && !o.dataLink),
      invokeSight: 0, invokeRadius: boolOf(o.radius), radius: o.radius || 0, flags: flags(flagList(o.flags)),
      events: list.map((e, i) => eventOf(e, i, c.name)),
    };
  });

  return build({
    version: 28, created: stamp, createdBy: author, modified: stamp, modifiedBy: author,
    audioPackage: info.audioPackage, notes: info.notes || '', missions: info.missions,
    actors: actors.rows(), flagTable: flagTable.rows(), skills: skills.rows(), objects: objects.rows(),
    nextConId: records.length, conversations: records,
  });
}

module.exports = {conFile, con, say, choice, setFlags, ifFlags, hasItem, transfer, camera, jump, random, trigger, addGoal, completeGoal, addNote, addSkillPoints, addCredits, comment, end, at};
