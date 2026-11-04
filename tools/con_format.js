#!/usr/bin/env node
/*
 * con_format.js - read and write Deus Ex .con conversation files in full.
 *
 * The layout is taken from the SDK's ConSys headers (Headers\DxHeaders.zip, field
 * order of the event classes) and checked by reading to the last byte of every
 * .con in the game and the mod. ConEdit is a VB program, so a string is
 * [int32 length][bytes] and every number and boolean is 4 bytes (true is -1).
 *
 * parse(buffer) -> {version, created, createdBy, modified, modifiedBy, audioPackage,
 *   notes, missions, actors, flags, skills, objects, nextConId, conversations: [...]}
 * build(file) is the reverse; build(parse(x)) gives x back byte for byte.
 *
 *   node tools/con_format.js <file.con>            summary, or the error position
 *   node tools/con_format.js <file.con> --json     everything
 *   node tools/con_format.js --check <dir>         round trip every .con in a folder
 */
'use strict';
const fs = require('fs');
const path = require('path');

const MAGIC = 'Deus Ex Conversation File\x1a';
const ET = {
  Speech: 0, Choice: 1, SetFlag: 2, CheckFlag: 3, CheckObject: 4, TransferObject: 5, MoveCamera: 6, Animation: 7, Trade: 8,
  Jump: 9, Random: 10, Trigger: 11, AddGoal: 12, AddNote: 13, AddSkillPoints: 14, AddCredits: 15, CheckPersona: 16, Comment: 17, End: 18,
};
const ET_NAME = Object.keys(ET);

class In {
  constructor(buf) { this.b = buf; this.p = 0; }
  int() { const v = this.b.readInt32LE(this.p); this.p += 4; return v; }
  dbl() { const v = this.b.slice(this.p, this.p + 8); this.p += 8; return v.toString('hex'); }
  str() {
    const n = this.int();
    if (n < 0 || this.p + n > this.b.length) throw new Error(`bad string length ${n} at 0x${(this.p - 4).toString(16)}`);
    const s = this.b.toString('latin1', this.p, this.p + n); this.p += n; return s;
  }
  ref() { return {id: this.int(), name: this.str()}; }
}

class Out {
  constructor() { this.parts = []; }
  int(v) { const b = Buffer.alloc(4); b.writeInt32LE(v | 0); this.parts.push(b); }
  dbl(hex) { this.parts.push(Buffer.from(hex, 'hex')); }
  str(s) { const b = Buffer.from(s, 'latin1'); this.int(b.length); this.parts.push(b); }
  ref(r) { this.int(r.id); this.str(r.name); }
  raw(b) { this.parts.push(b); }
  done() { return Buffer.concat(this.parts); }
}

const FLAGREF = {
  read: (r) => { const n = r.int(), a = []; for (let i = 0; i < n; i++) a.push({flag: r.ref(), value: r.int(), expiration: r.int()}); return a; },
  write: (w, a) => { w.int(a.length); a.forEach((f) => { w.ref(f.flag); w.int(f.value); w.int(f.expiration); }); },
};

// One entry per event type: the fields in file order. i int, s string, r table reference, f flag list.
const BODY = {
  [ET.Speech]: [['speaker', 'r'], ['speakingTo', 'r'], ['speech', 's'], ['audio', 's'], ['continued', 'i'], ['bold', 'i'], ['font', 'i']],
  [ET.Choice]: [['slots', 'i'], ['clearScreen', 'i'], ['choices', 'c']],
  [ET.SetFlag]: [['flags', 'f']],
  [ET.CheckFlag]: [['flags', 'f'], ['setLabel', 's']],
  [ET.CheckObject]: [['object', 'r'], ['failLabel', 's']],
  [ET.TransferObject]: [['object', 'r'], ['count', 'i'], ['from', 'r'], ['to', 'r'], ['failLabel', 's']],
  [ET.MoveCamera]: [['cameraType', 'i'], ['position', 'i'], ['transition', 'i']],
  [ET.Animation]: [['owner', 'r'], ['sequence', 's'], ['playMode', 'i'], ['playLength', 'i'], ['finishAnim', 'i']],
  [ET.Jump]: [['target', 's'], ['conId', 'i']],
  [ET.Random]: [['labels', 'l'], ['cycle', 'i'], ['cycleOnce', 'i'], ['cycleRandom', 'i']],
  [ET.Trigger]: [['tag', 's']],
  [ET.AddGoal]: [['goal', 's'], ['completed', 'i'], ['text', 's', (e) => !e.completed], ['primary', 'i', (e) => !e.completed]],
  [ET.AddNote]: [['text', 's']],
  [ET.AddSkillPoints]: [['points', 'i'], ['message', 's']],
  [ET.AddCredits]: [['credits', 'i']],
  [ET.CheckPersona]: [['persona', 'i'], ['condition', 'i'], ['value', 'i'], ['target', 's']],
  [ET.Comment]: [['text', 's']],
  [ET.End]: [],
};

function readChoices(r) {
  const n = r.int(), a = [];
  for (let i = 0; i < n; i++) {
    const c = {index: r.int(), text: r.str(), displayAsSpeech: r.int()};
    const skill = r.int();  // -1: no skill needed
    if (skill !== -1) { c.skill = {id: skill, name: r.str()}; c.skillLevel = r.int(); }
    c.label = r.str(); c.audio = r.str(); c.flags = FLAGREF.read(r);
    a.push(c);
  }
  return a;
}
function writeChoices(w, a) {
  w.int(a.length);
  a.forEach((c) => { w.int(c.index); w.str(c.text); w.int(c.displayAsSpeech);
    if (c.skill) { w.ref(c.skill); w.int(c.skillLevel); } else w.int(-1);
    w.str(c.label); w.str(c.audio); FLAGREF.write(w, c.flags); });
}

function readEvent(r) {
  const at = r.p;
  const e = {id: r.int(), next: r.int(), type: r.int(), label: r.str()};
  const body = BODY[e.type];
  if (!body) throw new Error(`unknown event type ${e.type} at 0x${at.toString(16)}`);
  e.kind = ET_NAME[e.type];
  for (const [name, t, when] of body) {
    if (when && !when(e)) continue;
    if (t === 'i') e[name] = r.int();
    else if (t === 's') e[name] = r.str();
    else if (t === 'r') e[name] = r.ref();
    else if (t === 'f') e[name] = FLAGREF.read(r);
    else if (t === 'c') e[name] = readChoices(r);
    else if (t === 'l') { const n = r.int(); e[name] = []; for (let i = 0; i < n; i++) e[name].push(r.str()); }
  }
  return e;
}
function writeEvent(w, e) {
  w.int(e.id); w.int(e.next); w.int(e.type); w.str(e.label);
  for (const [name, t, when] of BODY[e.type]) {
    if (when && !when(e)) continue;
    if (t === 'i') w.int(e[name]);
    else if (t === 's') w.str(e[name]);
    else if (t === 'r') w.ref(e[name]);
    else if (t === 'f') FLAGREF.write(w, e[name]);
    else if (t === 'c') writeChoices(w, e[name]);
    else if (t === 'l') { w.int(e[name].length); e[name].forEach((s) => w.str(s)); }
  }
}

function readTable(r) { const n = r.int(), a = []; for (let i = 0; i < n; i++) a.push(r.ref()); return a; }
function writeTable(w, a) { w.int(a.length); a.forEach((x) => w.ref(x)); }

const CON_BOOLS = ['displayOnce', 'firstPerson', 'nonInteractive', 'randomCamera', 'canBeInterrupted', 'cannotBeInterrupted',
  'invokeBump', 'invokeFrob', 'invokeSight', 'invokeRadius'];

function readCon(r) {
  const c = {a: r.int(), id: r.int(), name: r.str(), description: r.str(), created: r.dbl(), createdBy: r.str(), modified: r.dbl(), modifiedBy: r.str(), owner: r.ref(), dataLink: r.int(), notes: r.str()};
  CON_BOOLS.forEach((k) => { c[k] = r.int(); });
  c.radius = r.int();
  c.flags = FLAGREF.read(r);
  const n = r.int();
  c.events = [];
  for (let i = 0; i < n; i++) c.events.push(readEvent(r));
  return c;
}
function writeCon(w, c) {
  w.int(c.a); w.int(c.id); w.str(c.name); w.str(c.description); w.dbl(c.created); w.str(c.createdBy); w.dbl(c.modified); w.str(c.modifiedBy); w.ref(c.owner); w.int(c.dataLink); w.str(c.notes);
  CON_BOOLS.forEach((k) => w.int(c[k]));
  w.int(c.radius);
  FLAGREF.write(w, c.flags);
  w.int(c.events.length);
  c.events.forEach((e) => writeEvent(w, e));
}

function parse(buf) {
  if (buf.toString('latin1', 0, MAGIC.length) !== MAGIC) throw new Error('not a .con file');
  const r = new In(buf); r.p = MAGIC.length;
  const f = {version: r.int(), created: r.dbl(), createdBy: r.str(), modified: r.dbl(), modifiedBy: r.str(), audioPackage: r.str(), notes: r.str()};
  const nm = r.int(); f.missions = []; for (let i = 0; i < nm; i++) f.missions.push(r.int());
  f.tableSize = r.int();
  const start = r.p;
  f.actors = readTable(r); f.flagTable = readTable(r); f.skills = readTable(r); f.objects = readTable(r);
  if (r.p - start !== f.tableSize) throw new Error(`tables took ${r.p - start} bytes, header says ${f.tableSize}`);
  f.nextConId = r.int();
  const n = r.int(); f.conversations = [];
  for (let i = 0; i < n; i++) {
    try { f.conversations.push(readCon(r)); } catch (e) { e.message += ` (conversation ${i})`; throw e; }
  }
  // ConEdit does not truncate on saving: what follows is the end of an older, longer save.
  f.staleTail = buf.slice(r.p).toString('hex');
  return f;
}

function build(f) {
  const t = new Out();
  writeTable(t, f.actors); writeTable(t, f.flagTable); writeTable(t, f.skills); writeTable(t, f.objects);
  const tables = t.done();
  const w = new Out();
  w.raw(Buffer.from(MAGIC, 'latin1'));
  w.int(f.version); w.dbl(f.created); w.str(f.createdBy); w.dbl(f.modified); w.str(f.modifiedBy); w.str(f.audioPackage); w.str(f.notes);
  w.int(f.missions.length); f.missions.forEach((m) => w.int(m));
  w.int(tables.length); w.raw(tables);
  w.int(f.nextConId);
  w.int(f.conversations.length);
  f.conversations.forEach((c) => writeCon(w, c));
  if (f.staleTail) w.dbl(f.staleTail);
  return w.done();
}

module.exports = {parse, build, ET, ET_NAME};

if (require.main === module) {
  const args = process.argv.slice(2);
  if (args[0] === '--check') {
    let bad = 0;
    for (const n of fs.readdirSync(args[1]).filter((x) => /\.con$/i.test(x))) {
      const buf = fs.readFileSync(path.join(args[1], n));
      try {
        const same = build(parse(buf)).equals(buf);
        if (!same) { bad++; console.log(n, 'parsed, but the rebuild differs'); }
      } catch (e) { bad++; console.log(n, e.message); }
    }
    console.log(bad ? `${bad} bad` : 'all round trip');
    process.exit(bad ? 1 : 0);
  }
  const f = parse(fs.readFileSync(args[0]));
  if (args[1] === '--json') console.log(JSON.stringify(f, null, 1));
  else {
    console.log(`version ${f.version}, by ${f.createdBy}, audio ${f.audioPackage}, missions ${f.missions}; ${f.conversations.length} conversations`);
    f.conversations.forEach((c) => console.log(`  ${c.owner.name}.${c.name}: ${c.events.length} events`));
  }
}
